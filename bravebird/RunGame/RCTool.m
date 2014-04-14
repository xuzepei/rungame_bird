//
//  RCTool.m
//  BeatMole
//
//  Created by xuzepei on 5/23/13.
//
//

#import "RCTool.h"
#import "CCAnimation+Helper.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "AppDelegate.h"
#import "Reachability.h"
#import "SimpleAudioEngine.h"
#import "AESCrypt.h"
#import "GCHelper.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation RCTool

+ (NSString*)getUserDocumentDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)md5:(NSString *)str
{
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}

+ (NSString *)getIpAddress
{
	
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

+ (NSString*)base64forData:(NSData*)theData
{
	const uint8_t* input = (const uint8_t*)[theData bytes];
	NSInteger length = [theData length];
	
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
	
	NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
		NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
			
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
		
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
	
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

+ (UIWindow*)frontWindow
{
	UIApplication *app = [UIApplication sharedApplication];
    NSArray* windows = [app windows];
    
    for(int i = [windows count] - 1; i >= 0; i--)
    {
        UIWindow *frontWindow = [windows objectAtIndex:i];
        //NSLog(@"window class:%@",[frontWindow class]);
        //        if(![frontWindow isKindOfClass:[MTStatusBarOverlay class]])
        return frontWindow;
    }
    
	return nil;
}

+ (void)resizeSprite:(CCSprite*)sprite toWidth:(float)width toHeight:(float)height
{
    sprite.scaleX = width / sprite.contentSize.width;
    sprite.scaleY = height / sprite.contentSize.height;
}

+ (float)getWidthScale
{
    return WIN_SIZE.width / 320.0;
}

+ (float)getHeightScale
{
    return WIN_SIZE.height / 568.0;
}

+ (float)getValueByWidthScale:(float)value
{
    return WIN_SIZE.width*value / 320.0;
}

+ (float)getValueByHeightScale:(float)value
{
    return WIN_SIZE.height*value / 568.0;
}

+ (int)randomByType:(int)type
{
    int array[10];
    
    if(RDM_BG == type)
    {
        int temp[10] = {0,0,0,0,0,1,1,1,1,1};
        memcpy(array,temp,10*sizeof(int));
    }
    else if(RDM_PIPE == type){
        
        if([RCTool isOpenAll])
        {
            int temp[10] = {0,0,0,0,0,0,0,0,1,2};
            memcpy(array,temp,10*sizeof(int));
        }
        else
        {
            int temp[10] = {4,4,4,4,4,4,4,4,5,6};
            memcpy(array,temp,10*sizeof(int));
        }
    }
    else if(RDM_ANGRY_PIPE == type)
    {
        if([RCTool isOpenAll])
        {
            int temp[10] = {0,0,0,0,0,0,0,0,3,3};
            memcpy(array,temp,10*sizeof(int));
        }
        else
        {
            int temp[10] = {0,0,0,0,0,0,0,0,7,7};
            memcpy(array,temp,10*sizeof(int));
        }
    }
    else if(RDM_DUCK == type){
        int temp[10] = {0,0,0,0,0,1,1,0,2,2};
        memcpy(array,temp,10*sizeof(int));
    }
    else if(RDM_LAND == type){
        int temp[10] = {0,0,0,0,0,0,0,0,0,0};
        memcpy(array,temp,10*sizeof(int));
    }
    
    int size = sizeof(array)/sizeof(int);
    
    //随机排序数组
    for (NSUInteger i = 0; i < size; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = size - i;
        int n = (arc4random() % nElements) + i;
        
        int temp = array[n];
        array[n] = array[i];
        array[i] = temp;
    }
    
    int rand = arc4random()%size;
    rand = array[rand];
    return rand;
}

+ (UIImage*)screenshotWithStartNode:(CCNode*)startNode
{
    [CCDirector sharedDirector].nextDeltaTimeZero = YES;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CCRenderTexture* rtx =
    [CCRenderTexture renderTextureWithWidth:winSize.width
                                     height:winSize.height];
    [rtx begin];
    [startNode visit];
    [rtx end];
    
    return [rtx getUIImage];
}

+ (BOOL)isOpenAll
{
    return NO;
}

#pragma mark - 兼容iOS6和iPhone5

+ (CGSize)getScreenSize
{
    return [[UIScreen mainScreen] bounds].size;
}

+ (CGRect)getScreenRect
{
    return [[UIScreen mainScreen] bounds];
}

+ (BOOL)isIphone5
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize size = [[UIScreen mainScreen] bounds].size;
        if(568 == size.height)
        {
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)isIpad
{
	UIDevice* device = [UIDevice currentDevice];
	if(device.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
	{
		return NO;
	}
	else if(device.userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		return YES;
	}
	
	return NO;
}

+ (BOOL)isIpadMini
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    if([platform length])
    {
        if([platform isEqualToString:@"iPad2,5"] || [platform isEqualToString:@"iPad2,6"] || [platform isEqualToString:@"iPad2,7"])
            return YES;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [UIScreen mainScreen].scale == 1)
        {
            // old iPad
            
            return YES;
        }
    }
    
    return NO;
}

+ (RCNavigationController*)getRootNavigationController
{
    AppController* appDelegate =(AppController*)[UIApplication sharedApplication].delegate;
    return appDelegate.navigationController;
}

+ (void)showAlert:(NSString*)aTitle message:(NSString*)message
{
	if(0 == [aTitle length] || 0 == [message length])
		return;
	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: aTitle
													message: message
												   delegate: self
										  cancelButtonTitle: @"OK"
										  otherButtonTitles: nil];
    alert.tag = 110;
	[alert show];
	[alert release];
	
    
}

+ (CGFloat)systemVersion
{
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    return systemVersion;
}

+ (AppController*)getAppDelegate;
{
    UIApplication *app = [UIApplication sharedApplication];
    return (AppController*)app.delegate;
}


+ (void)addCacheFrame:(NSString*)plistFile
{
    if(0 == [plistFile length])
        return;
    
    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [frameCache addSpriteFramesWithFile:plistFile];
}

+ (void)removeCacheFrame:(NSString*)plistFile
{
    if(0 == [plistFile length])
        return;
    
    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [frameCache removeSpriteFramesFromFile:plistFile];
}

#pragma mark - Get Random Number

+ (float)randFloat:(float)max min:(float)min
{
    float temp = (float)arc4random()/UINT_MAX;
    return min + (max-min)*temp;
}

#pragma mark - Settings

+ (void)setBKVolume:(CGFloat)volume
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    [temp setFloat:volume forKey:@"bk_volume"];
    [temp synchronize];
}

+ (CGFloat)getBKVolume
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    NSNumber* value = [temp objectForKey:@"bk_volume"];
    if(value)
        return [value floatValue];
    
    return 0.5;
}

+ (void)setEffectVolume:(CGFloat)volume
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    [temp setFloat:volume forKey:@"effect_volume"];
    [temp synchronize];
}

+ (CGFloat)getEffectVolume
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    NSNumber* value = [temp objectForKey:@"effect_volume"];
    if(value)
        return [value floatValue];
    
    return 1.0;
}

#pragma mark - Network

+ (BOOL)isReachableViaWiFi
{
	Reachability* wifiReach = [Reachability reachabilityForLocalWiFi];
	[wifiReach startNotifier];
	NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
	switch (netStatus)
    {
        case NotReachable:
        {
            return NO;
        }
        case ReachableViaWWAN:
        {
            return NO;
        }
        case ReachableViaWiFi:
        {
			return YES;
		}
		default:
			return NO;
	}
	return NO;
}

+ (BOOL)isReachableViaInternet
{
	Reachability* internetReach = [Reachability reachabilityForInternetConnection];
	[internetReach startNotifier];
	NetworkStatus netStatus = [internetReach currentReachabilityStatus];
	switch (netStatus)
    {
        case NotReachable:
        {
            return NO;
        }
        case ReachableViaWWAN:
        {
            return YES;
        }
        case ReachableViaWiFi:
        {
			return YES;
		}
		default:
			return NO;
	}
	
	return NO;
}

#pragma mark - Play Sound

+ (void)preloadEffectSound:(NSString*)soundName
{
    if(0 == [soundName length])
        return;
    
    [[SimpleAudioEngine sharedEngine] preloadEffect:soundName];
}

+ (void)unloadEffectSound:(NSString*)soundName
{
    if(0 == [soundName length])
        return;
    
    [[SimpleAudioEngine sharedEngine] unloadEffect:soundName];
}

+ (void)playEffectSound:(NSString*)soundName
{
    if(0 == [soundName length])
        return;
    
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:[RCTool getEffectVolume]];
    
    [[SimpleAudioEngine sharedEngine] playEffect:soundName];
}

+ (void)playBgSound:(NSString*)soundName
{
    if(0 == [soundName length])
        return;
    
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:[RCTool getBKVolume]];
    
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:soundName loop:YES];
}

+ (void)pauseBgSound
{
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
}

+ (void)resumeBgSound
{
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
}

#pragma mark - Record

+ (int)getRecordByType:(int)type
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* key = [NSString stringWithFormat:@"RT_%d",type];
    if(type == RT_SCORE || type == RT_BEST)
    {
        NSString* leaderboardId = [RCTool md5:LEADERBOARD_SCORES_ID];
        key = [NSString stringWithFormat:@"RT_%d_%@",type,leaderboardId];
    }
    
    
    NSString* encryptedString = [defaults objectForKey:key];
    if(0 == [encryptedString length])
        return 0;
    
    NSString* password = ENCRYPT_PASSWORD;
    if(RT_COIN == type)
        password = ENCRYPT_PASSWORD_FOR_COIN;
    else if(RT_PLAYTIMES == type)
        password = ENCRYPT_PASSWORD_FOR_PLAYTIMES;
    
//    NSLog(@"----%@,%lld",[RCTool decryptString:encryptedString password:password],[[RCTool decryptString:encryptedString password:password] longLongValue]);
    return [[RCTool decryptString:encryptedString password:password] longLongValue];
}

+ (void)setRecordByType:(int)type value:(int64_t)value
{
    NSString* key = [NSString stringWithFormat:@"RT_%d",type];
    if(type == RT_SCORE || type == RT_BEST)
    {
        NSString* leaderboardId = [RCTool md5:LEADERBOARD_SCORES_ID];
        key = [NSString stringWithFormat:@"RT_%d_%@",type,leaderboardId];
    }
    
    NSString* password = ENCRYPT_PASSWORD;
    if(RT_COIN == type)
        password = ENCRYPT_PASSWORD_FOR_COIN;
    else if(RT_PLAYTIMES == type)
        password = ENCRYPT_PASSWORD_FOR_PLAYTIMES;
    
    NSString* encryptedString = [RCTool encryptString:[NSString stringWithFormat:@"%lld",value] password:password];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encryptedString forKey:key];
    [defaults synchronize];
}

#pragma mark - Achievement

+ (BOOL)checkAchievementByType:(int)type
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"AT_%d",type];
    int value = [[defaults objectForKey:key] intValue];
    switch (type) {
        case AT_ESCAPE:
        {
            if(value)
                return YES;
            
            break;
        }
        case AT_SHOOTER:
        {
            if(value > 30)
                return YES;
            
            break;
        }
        case AT_MARATHON:
        {
            //value = [RCTool getRecordByType:RT_DISTANCE];
            if(value > 42195)
                return YES;
            
            break;
        }
        case AT_CAKE:
        {
            if(value > 2000)
                return YES;
            
            break;
        }
        case AT_KUNGFU:
        {
            if(value > 300)
                return YES;
            
            break;
        }
        case AT_MILLIONAIRE:
        {
            if(value >= 50000)
                return YES;
            else
            {
                //value = [RCTool getRecordByType:RT_MONEY];
                if(value >= 20000)
                    return YES;
            }
            
            break;
        }
        default:
            break;
    }
    
    return NO;
}

+ (void)setAchievementByType:(int)type value:(int)value
{
    NSString* key = [NSString stringWithFormat:@"AT_%d",type];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    int temp = [[defaults objectForKey:key] intValue];
    switch (type) {
        case AT_ESCAPE:
        {
            temp = value;
            break;
        }
        case AT_SHOOTER:
        {
            if(temp <= 30)
            {
                temp += value;
            }
            
            break;
        }
        case AT_MARATHON:
        {
            break;
        }
        case AT_CAKE:
        {
            if(temp <= 2000)
            {
                if(-1 == value)
                {
                    temp = 0;
                }
                else
                    temp = value;
            }
            break;
        }
        case AT_KUNGFU:
        {
            if(temp <= 300)
            {
                if(-1 == value)
                {
                    temp = 0;
                }
                else
                    temp += value;
            }
            
            break;
        }
        case AT_MILLIONAIRE:
        {
            if(temp <= 50000)
            {
                temp += value;
            }
            break;
        }
        default:
            break;
    }
    
    [defaults setObject:[NSNumber numberWithInt:temp] forKey:key];
    [defaults synchronize];
}

#pragma mark - Core Data

+ (NSPersistentStoreCoordinator*)getPersistentStoreCoordinator
{
	AppController* appDelegate = (AppController*)[[UIApplication sharedApplication] delegate];
	return [appDelegate persistentStoreCoordinator];
}

+ (NSManagedObjectContext*)getManagedObjectContext
{
	AppController* appDelegate = (AppController*)[[UIApplication sharedApplication] delegate];
	return [appDelegate managedObjectContext];
}

+ (NSManagedObjectID*)getExistingEntityObjectIDForName:(NSString*)entityName
											 predicate:(NSPredicate*)predicate
									   sortDescriptors:(NSArray*)sortDescriptors
											   context:(NSManagedObjectContext*)context

{
	if(0 == [entityName length] || nil == context)
		return nil;
	
    if(nil == context)
        context = [RCTool getManagedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	
	//sortDescriptors 是必传属性
	NSArray *temp = [NSArray arrayWithArray: sortDescriptors];
	[fetchRequest setSortDescriptors:temp];
	
	
	//set predicate
	[fetchRequest setPredicate:predicate];
	
	//设置返回类型
	[fetchRequest setResultType:NSManagedObjectIDResultType];
	
	
	//	NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
	//															initWithFetchRequest:fetchRequest
	//															managedObjectContext:context
	//															sectionNameKeyPath:nil
	//															cacheName:@"Root"];
	//
	//	//[context tryLock];
	//	[fetchedResultsController performFetch:nil];
	//	//[context unlock];
	
	NSArray* objectIDs = [context executeFetchRequest:fetchRequest error:nil];
	
	[fetchRequest release];
	
	if(objectIDs && [objectIDs count])
		return [objectIDs lastObject];
	else
		return nil;
}

+ (NSArray*)getExistingEntityObjectsForName:(NSString*)entityName
								  predicate:(NSPredicate*)predicate
							sortDescriptors:(NSArray*)sortDescriptors
{
	if(0 == [entityName length])
		return nil;
	
	NSManagedObjectContext* context = [RCTool getManagedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	
	//sortDescriptors 是必传属性
	NSArray *temp = [NSArray arrayWithArray: sortDescriptors];
	[fetchRequest setSortDescriptors:temp];
	
	
	//set predicate
	[fetchRequest setPredicate:predicate];
	
	//设置返回类型
	[fetchRequest setResultType:NSManagedObjectResultType];
	
	NSArray* objects = [context executeFetchRequest:fetchRequest error:nil];
	
	[fetchRequest release];
	
	return objects;
}

+ (id)insertEntityObjectForName:(NSString*)entityName
		   managedObjectContext:(NSManagedObjectContext*)managedObjectContext;
{
	if(0 == [entityName length] || nil == managedObjectContext)
		return nil;
	
	NSManagedObjectContext* context = managedObjectContext;
	id entityObject = [NSEntityDescription insertNewObjectForEntityForName:entityName
													inManagedObjectContext:context];
	
	
	return entityObject;
	
}

+ (id)insertEntityObjectForID:(NSManagedObjectID*)objectID
		 managedObjectContext:(NSManagedObjectContext*)managedObjectContext;
{
	if(nil == objectID || nil == managedObjectContext)
		return nil;
	
	return [managedObjectContext objectWithID:objectID];
}

+ (void)saveCoreData
{
	AppController* appDelegate = (AppController*)[[UIApplication sharedApplication] delegate];
	NSError *error = nil;
    if ([appDelegate managedObjectContext] != nil)
	{
        if ([[appDelegate managedObjectContext] hasChanges] && ![[appDelegate managedObjectContext] save:&error])
		{
            
        }
    }
}

+ (void)deleteOldData
{
    //NSPredicate* predicate = [NSPredicate predicateWithFormat:@"isHidden == NO"];
    //    NSArray* translations = [RCTool getExistingEntityObjectsForName:@"Translation" predicate:nil sortDescriptors:nil];
    //    NSManagedObjectContext* context = [RCTool getManagedObjectContext];
    //    for(Translation* translation in translations)
    //    {
    //        [context deleteObject:translation];
    //    }
    //    [RCTool saveCoreData];
    //
    //    NSString* recorDirectoryPath = [NSString stringWithFormat:@"%@/record",[RCTool getUserDocumentDirectoryPath]];
    //    [RCTool removeFile:recorDirectoryPath];
    //
    //    NSString* ttsDirectoryPath = [[RCTool getUserDocumentDirectoryPath] stringByAppendingString:@"/tts"];
    //    [RCTool removeFile:ttsDirectoryPath];
}


+ (NSString*)encryptString:(NSString*)string password:(NSString*)password
{
    if(0 == [string length])
        return @"";
    
    return [AESCrypt encrypt:string password:password];
}

+ (NSString*)decryptString:(NSString*)string password:(NSString*)password
{
    if(0 == [string length])
        return @"";
    
    return [AESCrypt decrypt:string password:password];
}

#pragma mark - Ad

+ (void)showAd:(BOOL)b
{
    AppController* appDelegate =(AppController*)[UIApplication sharedApplication].delegate;
    if(appDelegate.adMobAd && appDelegate.adMobAd.superview)
    {
        if(b)
        {
            if([RCTool getRecordByType:RT_BEST] <= 2)
                return;
            
            CGRect temp = appDelegate.adMobAd.frame;
            if(temp.origin.y == [RCTool getScreenSize].height - appDelegate.adMobAd.frame.size.height)
                return;
            
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = appDelegate.adMobAd.frame;
                rect.origin.y = 0;
                appDelegate.adMobAd.frame = rect;
            }completion:^(BOOL finished) {
                appDelegate.isAdMobVisible = YES;
            }];
        }
        else
        {
//            CGRect temp = appDelegate.adMobAd.frame;
//            if(temp.origin.y == [RCTool getScreenSize].height)
//                return;
//            
//            [UIView animateWithDuration:0.3 animations:^{
//                CGRect rect = appDelegate.adMobAd.frame;
//                rect.origin.y = [RCTool getScreenSize].height;
//                appDelegate.adMobAd.frame = rect;
//            }completion:^(BOOL finished) {
//                appDelegate.isAdMobVisible = NO;
//            }];
        }
    }
    
    if(appDelegate.isAdMobVisible)
        return;
    
    if(appDelegate.adView && appDelegate.adView.superview)
    {
        if(b)
        {
            if([RCTool getRecordByType:RT_BEST] <= 2)
                return;
            
            CGRect temp = appDelegate.adView.frame;
            if(temp.origin.y == [RCTool getScreenSize].height - appDelegate.adView.frame.size.height)
                return;
            
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = appDelegate.adView.frame;
                rect.origin.y = 0;
                appDelegate.adView.frame = rect;
            }completion:^(BOOL finished) {
                appDelegate.isAdViewVisible = YES;
            }];
        }
        else
        {
//            CGRect temp = appDelegate.adView.frame;
//            if(temp.origin.y == [RCTool getScreenSize].height)
//                return;
//            
//            [UIView animateWithDuration:0.3 animations:^{
//                CGRect rect = appDelegate.adView.frame;
//                rect.origin.y = [RCTool getScreenSize].height;
//                appDelegate.adView.frame = rect;
//            }completion:^(BOOL finished) {
//                appDelegate.isAdViewVisible = NO;
//            }];
        }
    }
}

+ (void)showInterstitialAd
{
    AppController* appDelegate =(AppController*)[UIApplication sharedApplication].delegate;
    [appDelegate showInterstitialAd:nil];
}

#pragma mark - Play Times

+ (void)addPlayTimes
{
    int64_t oldPlayTimes = [RCTool getRecordByType:RT_PLAYTIMES];
    oldPlayTimes += 1;
    [RCTool setRecordByType:RT_PLAYTIMES value:oldPlayTimes];
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* date = [userDefaults objectForKey:@"date"];
    if(nil == date)
    {
        int count = [[userDefaults objectForKey:@"play_count"] intValue];
        count++;
        [userDefaults setObject:[NSNumber numberWithDouble:now] forKey:@"date"];
        [userDefaults setObject:[NSNumber numberWithInt:count] forKey:@"play_count"];
        [userDefaults synchronize];
    }
    else
    {
        NSTimeInterval last = [date doubleValue];
        if(last + 24*60*60 >= now)
        {
            int count = [[userDefaults objectForKey:@"play_count"] intValue];
            count++;
            [userDefaults setObject:[NSNumber numberWithInt:count] forKey:@"play_count"];
            [userDefaults synchronize];
        }
        else
        {
            int count = 1;
            [userDefaults setObject:[NSNumber numberWithDouble:now] forKey:@"date"];
            [userDefaults setObject:[NSNumber numberWithInt:count] forKey:@"play_count"];
            [userDefaults synchronize];
        }
    }
    
    
}

+ (int)getPlayTimes
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [[userDefaults objectForKey:@"play_count"] intValue];
}

#pragma mark - UMeng

+ (void)sendStatisticInfo:(NSString*)eventName
{
    if(0 == [eventName length])
        return;

}

#pragma mark - Angry Pipe

+ (BOOL)hasChance:(int)x y:(int)y
{
    if(x >= y)
        return YES;
    
    NSMutableArray* array = [[[NSMutableArray alloc] init] autorelease];
    for(int i = 0; i < y; i++)
    {
        int value = 0;
        if(i < x)
            value = 1;
        [array addObject:[NSNumber numberWithInt:value]];
    }
    
    //随机排序数组
    int i = [array count];
    while(--i > 0) {
        int j = arc4random() % (i+1);
        [array exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
    
    int rand = arc4random()%[array count];
    NSNumber* number = [array objectAtIndex:rand];
    if(1 == [number intValue])
        return YES;
    
    return NO;
}

+ (BOOL)isAngry
{
    BOOL isAngry = NO;
    int score = [RCTool getRecordByType:RT_SCORE];
    if(score >= 30)
    {
        isAngry = [RCTool hasChance:1 y:6];
    }
    else if(score >= 3)
    {
        isAngry = [RCTool hasChance:1 y:10];
    }
    
    return isAngry;
}

+ (BOOL)isRotated
{
    BOOL b = NO;
    int score = [RCTool getRecordByType:RT_SCORE];
    if(score >= 30)
    {
        b = [RCTool hasChance:1 y:10];
    }
    else if(score >= 20)
    {
        b = [RCTool hasChance:1 y:20];
    }

    return b;
}

#pragma mark - 获取匹配赛管道布置地图

+ (NSArray*)createPipesPosition
{
    NSMutableArray* array = [[[NSMutableArray alloc] init] autorelease];
    
    CGFloat random_height = 568 - PIPE_MIN_HEIGHT*2 - PIPE_TOPBOTTOM_INTERVAL - FLOOR_HEIGHT;
    
    for(int i = 0; i<200; i++)
    {
       float value = [RCTool randFloat:random_height min:0];
        [array addObject:[NSNumber numberWithFloat:value]];
    }

    return array;
}

@end
