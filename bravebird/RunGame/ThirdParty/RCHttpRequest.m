//
//  RCHttpRequest.m
//  rsscoffee
//
//  Created by xuzepei on 09-9-8.
//  Copyright 2009 SanguoTech Co.,Ltd. All rights reserved.
//

//下载父类，用做继承

#import "RCHttpRequest.h"


@implementation RCHttpRequest
@synthesize _receivedData;
@synthesize _isConnecting;
@synthesize _delegate;
@synthesize _statusCode;
@synthesize _contentType;
@synthesize _requestType;
@synthesize _requestingURL;
@synthesize _token;
@synthesize _expectedContentLength;
@synthesize _currentLength;
@synthesize _urlConnection;
@synthesize _resultSelector;

+ (RCHttpRequest*)sharedInstance
{
    static RCHttpRequest* sharedInstance = nil;
    if(nil == sharedInstance)
    {
        @synchronized([RCHttpRequest class])
        {
            if (nil == sharedInstance)
            {
                sharedInstance = [[RCHttpRequest alloc] init];
            }
        }
    }
    
    return sharedInstance;
}

- (id)init
{
	if(self = [super init])
	{
		_receivedData = [[NSMutableData alloc] init];
		_isConnecting = NO;
		_contentType = CT_UNKNOWN;
		_requestType = 0;
		_expectedContentLength = 0;
		_currentLength = 0;
	}
	
	return self;
}

- (void)dealloc
{
    if (_timeOutTimer) {
        [_timeOutTimer invalidate];
        [_timeOutTimer release];
        _timeOutTimer = nil;
    }
    
	_isConnecting = NO;
    if(_receivedData)
    {
        [_receivedData release];
        _receivedData = nil;
    }
    
	self._delegate = nil;
    
    if(_requestingURL)
    {
        [_requestingURL release];
        _requestingURL =nil;
    }
    
    if(_token)
    {
        [_token release];
        _token =nil;
    }
    
	self._urlConnection = nil;
	
	[super dealloc];
}

- (void)cancel
{
    if (_timeOutTimer) {
        [_timeOutTimer invalidate];
        [_timeOutTimer release];
        _timeOutTimer = nil;
    }
    
    if(_urlConnection)
    {
        [_urlConnection cancel];
        [self connection:_urlConnection didFailWithError:nil];
    }
    
    _isConnecting = NO;
    self._receivedData = nil;
	self._urlConnection = nil;
}

- (BOOL)request:(NSString*)urlString delegate:(id)delegate resultSelector:(SEL)resultSelector token:(id)token
{
    if(0 == [urlString length] || _isConnecting)
        return NO;
    
    self._resultSelector = resultSelector;
	self._delegate = delegate;
	self._token = token;
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	self._requestingURL = urlString;
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	[request setURL:[NSURL URLWithString: urlString]];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setTimeoutInterval: TIME_OUT];
	[request setHTTPShouldHandleCookies:FALSE];
	[request setHTTPMethod:@"GET"];
    
    NSLog(@"request:%@",_requestingURL);
	
    BOOL isSuccess = YES;
    
    NSURLConnection * urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
	if (urlConnection)
	{
        self._urlConnection = urlConnection;
        
		_isConnecting = YES;
		[_receivedData setLength: 0];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
        //		if([_delegate respondsToSelector: @selector(willStartHttpRequest:)])
        //			[_delegate willStartHttpRequest:nil];
	}
    else
    {
        isSuccess = NO;
    }
    
    [urlConnection release];
    
    return isSuccess;
}


- (BOOL)post:(NSString*)urlString delegate:(id)delegate resultSelector:(SEL)resultSelector token:(id)token
{
    if(0 == [urlString length] || _isConnecting)
        return NO;
    
    self._resultSelector = resultSelector;
	self._delegate = delegate;
	self._token = token;
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	self._requestingURL = urlString;
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	[request setURL:[NSURL URLWithString: urlString]];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setTimeoutInterval: TIME_OUT];
	[request setHTTPShouldHandleCookies:FALSE];
	[request setHTTPMethod:@"POST"];
    
    NSString* body = (NSString*)_token;
    if([body length])
    {
        [request setHTTPBody: [body dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSLog(@"post:%@",_requestingURL);
	
    BOOL isSuccess = YES;
    
    NSURLConnection * urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
	if (urlConnection)
	{
        self._urlConnection = urlConnection;
        
		_isConnecting = YES;
		[_receivedData setLength: 0];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
        //		if([_delegate respondsToSelector: @selector(willStartHttpRequest:)])
        //			[_delegate willStartHttpRequest:nil];
	}
    else
    {
        isSuccess = NO;
    }
    
    [urlConnection release];
    
    return isSuccess;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	self._statusCode = [(NSHTTPURLResponse*)response statusCode];
	NSDictionary* header = [(NSHTTPURLResponse*)response allHeaderFields];
	NSString *content_type = [header valueForKey:@"Content-Type"];
	_contentType = CT_UNKNOWN;
	if (content_type)
	{
		if ([content_type rangeOfString:@"xml"].location != NSNotFound)
			_contentType = CT_XML;
		else if ([content_type rangeOfString:@"json"].location != NSNotFound)
			_contentType = CT_JSON;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (_receivedData == nil) {
        _receivedData = [[NSMutableData alloc] initWithCapacity:0];
    }
    [_receivedData appendData: data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"connectionDidFinishLoading:%d",_statusCode);
    
	if(200 == _statusCode)
	{
        NSString* jsonString = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
        
		_isConnecting = NO;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[_receivedData setLength:0];
        
        if(_resultSelector && [_delegate respondsToSelector:_resultSelector])
        {
            [_delegate performSelector:_resultSelector withObject:jsonString];
        }
        else
        {
            SEL selector = @selector(finishedRequest:token:);
            if(_delegate && [_delegate respondsToSelector:selector])
                [_delegate finishedRequest:jsonString token:_token];
        }
        
        [jsonString release];
        
	}
	else
	{
		_isConnecting = NO;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[_receivedData setLength:0];
		
        if(_resultSelector && [_delegate respondsToSelector:_resultSelector])
        {
            [_delegate performSelector:_resultSelector withObject:nil];
        }
        else
        {
            SEL selector = @selector(finishedRequest:token:);
            if(_delegate && [_delegate respondsToSelector:selector])
                [_delegate finishedRequest:nil token:nil];
        }
	}
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	NSLog(@"didFailWithError");
    
	_isConnecting = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[_receivedData setLength: 0];
    
    if(_resultSelector && [_delegate respondsToSelector:_resultSelector])
    {
        [_delegate performSelector:_resultSelector withObject:nil];
    }
    else
    {
        SEL selector = @selector(finishedRequest:token:);
        if(_delegate && [_delegate respondsToSelector:selector])
            [_delegate finishedRequest:nil token:nil];
    }
}


@end
