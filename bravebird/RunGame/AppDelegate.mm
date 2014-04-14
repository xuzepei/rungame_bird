//
//  AppDelegate.mm
//  RunGame
//
//  Created by xuzepei on 9/13/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "AppDelegate.h"
#import "RCNavigationController.h"
#import "RCHomeScene.h"
#import "GCHelper.h"
#import "Reachability.h"
#import "RCHttpRequest.h"


@implementation AppController
@synthesize window=window_, director=director_;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize xmlData;
@synthesize parserXML;

//定义需要从xml中解析的元素
static NSString *kTitleStr     = @"title";
static NSString *kContentStr   = @"content";
static NSString *kLinkStr  = @"link";
static NSString *kCancelStr = @"cancelTitle";
static NSString *kSureStr = @"sureTitle";


+ (void)initialize{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //	NSNumber *n = [[NSNumber alloc] initWithFloat:1.0];
    
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithObjectsAndKeys:@"YES", @"soundOn",@"NO",@"isPlayed",@"player",@"playerName",@"311f1a51f47b45b9",@"admobId",@"a1531a02d8c15b9",@"fullscreenAdmobId",nil];
	[defaults registerDefaults:appDefaults];
	[appDefaults release];
    //	[n release];
}

/**
 *得到本机现在用的语言
 * en:英文  zh-Hans:简体中文   zh-Hant:繁体中文    ja:日本  ......
 */
- (NSString*)getPreferredLanguage
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    NSLog(@"Preferred Language:%@", preferredLang);
    return preferredLang;
}


- (BOOL) connected
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    BOOL v = !(networkStatus == NotReachable);
    [pool release];
    return v;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self getAdId];
    
    UIApplication* app = [UIApplication sharedApplication];
	app.applicationIconBadgeNumber = 0;
	[app registerForRemoteNotificationTypes:
	 (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllAds:) name:@"REMOVE_ALL_ADS" object:nil];
    
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    
	// Enable multiple touches
	[glView setMultipleTouchEnabled:YES];
    
	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	director_.wantsFullScreenLayout = YES;
	
	// Display FSP and SPF
	//[director_ setDisplayStats:YES];
	
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director_ setView:glView];
    //glView.alpha = 0.0;
	
	// for rotation and other messages
	[director_ setDelegate:self];
	
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
	//	[director setProjection:kCCDirectorProjection3D];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	//[director_ pushScene: [IntroLayer scene]];
    
	// Create a Navigation Controller with the Director
    
	_navigationController = [[RCNavigationController alloc] initWithRootViewController:director_];
	_navigationController.navigationBarHidden = YES;
	
	[window_ setRootViewController:_navigationController];
	[window_ makeKeyAndVisible];
    
    [director_ runWithScene:[RCHomeScene scene]];



	return YES;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

// getting a call, pause the game
- (void)applicationWillResignActive:(UIApplication *)application
{
	if( [_navigationController visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //推送设置
    UIApplication* app = [UIApplication sharedApplication];
	app.applicationIconBadgeNumber = 0;
    
    
	if( [_navigationController visibleViewController] == director_ )
		[director_ resume];
    
    [[GCHelper sharedInstance] authenticateLocalUser];
    
    //程序内购买
    if([self checkEnableIAP])
    {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [self requestProductData];
    }

}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
     [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    
	if( [_navigationController visibleViewController] == director_ )
		[director_ stopAnimation];
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
	if( [_navigationController visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
    
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    //处理内存警告
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
- (void)applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    
	[window_ release];
    self.navigationController = nil;
    
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    
    self.adMobAd = nil;
    self.adInterstitial = nil;
    
    self.adView = nil;
    self.interstitial = nil;
    
    if (receivedData) {
        [receivedData release];
    }
    [xmlData release];
	[parserXML release];
	[dataToParse release];
	[workingArray release];
	[workingEntry release];
	[workingPropertyString release];
	[elementsToParse release];
    self.xmlData = nil;
	self.parserXML = nil;
	self.dataToParse = nil;
	self.workingArray = nil;
	self.workingEntry = nil;
	self.workingPropertyString = nil;
	self.elementsToParse = nil;
    
    self.products = nil;
    self.removeAdProduct = nil;
    
    self.bannerAdId = nil;
    self.fullScreenAdId = nil;
    
	[super dealloc];
}

#pragma mark -

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RunGame" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RunGame.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


#pragma mark - AdMob

- (void)initAdMob
{
	if(NO == [RCTool isIpad])
	{
		_adMobAd = [[GADBannerView alloc]
                    initWithFrame:CGRectMake(0.0,0,
                                             320.0f,
                                             50.0f)];
	}
	else
	{
        _adMobAd = [[GADBannerView alloc]
                    initWithFrame:CGRectMake(0.0,0,
                                             728.0f,
                                             90.0f)];
	}
	
	
	
	_adMobAd.adUnitID = self.bannerAdId;
	_adMobAd.delegate = self;
	_adMobAd.alpha = 0.0;
	_adMobAd.rootViewController = [RCTool getRootNavigationController].topViewController;
	[_adMobAd loadRequest:[GADRequest request]];
	
}

- (void)getAD:(id)agrument
{
	NSLog(@"getAD");
	
	if(_adMobAd && _adMobAd.alpha == 0.0 && nil == _adMobAd.superview)
	{
		[_adMobAd removeFromSuperview];
		_adMobAd.delegate = nil;
		[_adMobAd release];
		_adMobAd = nil;
	}
	
	[self initAdMob];
}

#pragma mark -
#pragma mark GADBannerDelegate methods

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
	NSLog(@"adViewDidReceiveAd");
	
    if(nil == _adMobAd.superview && _adMobAd.alpha == 0.0)
    {
        _adMobAd.alpha = 1.0;
        CGRect rect = _adMobAd.frame;
        rect.origin.x = ([RCTool getScreenSize].width - rect.size.width)/2.0;
        rect.origin.y = 0;
        _adMobAd.frame = rect;
        
        [[RCTool getRootNavigationController].topViewController.view addSubview: _adMobAd];
        
        self.isAdMobVisible = NO;
    }
}

- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error
{
	NSLog(@"didFailToReceiveAdWithError");
    
    self.isAdMobVisible = NO;
    
    [RCTool sendStatisticInfo:ADMOD_FAILED_EVENT];
    
    [self performSelector:@selector(getAD:) withObject:nil afterDelay:10.0];

}

- (void)getAdInterstitial
{
    if(nil == self.adInterstitial)
    {
        _adInterstitial = [[GADInterstitial alloc] init];
        _adInterstitial.adUnitID = self.fullScreenAdId;
        _adInterstitial.delegate = self;
    }
    
    [_adInterstitial loadRequest:[GADRequest request]];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
    NSLog(@"interstitialDidReceiveAd");
}

- (void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"%s",__FUNCTION__);
    [RCTool sendStatisticInfo:ADMOD_FAILED_EVENT];
    
    [self performSelector:@selector(getAdInterstitial) withObject:nil afterDelay:10.0];

}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    self.adInterstitial = nil;
    [self getAdInterstitial];
}

- (void)showInterstitialAd:(id)argument
{
    if(self.adInterstitial)
    {
        [self.adInterstitial presentFromRootViewController:[RCTool getRootNavigationController].topViewController];
    }
    else if(self.interstitial && self.interstitial.loaded)
    {
        [self.interstitial presentFromViewController:[RCTool getRootNavigationController].topViewController];
    }
}

#pragma mark - iAd

- (void)initAdView
{
    if(nil == _adView)
        _adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    _adView.delegate = self;
    CGRect rect = _adView.frame;
    rect.origin.y = [RCTool getScreenSize].height;
    _adView.frame = rect;
    
    self.isAdViewVisible = NO;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"iAd,bannerViewDidLoadAd");
    
    [[RCTool getRootNavigationController].topViewController.view addSubview:_adView];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"iAd,didFailToReceiveAdWithError");
    
    [RCTool sendStatisticInfo:IAD_FAILED_EVENT];
    
    self.isAdViewVisible = NO;
    [self.adView removeFromSuperview];
    self.adView = nil;
    
    //如果iAd失败，则调用admob
    [self performSelector:@selector(getAD:) withObject:nil afterDelay:3];
}

- (void)initInterstitial
{
    if(NO == [RCTool isIpad])
        return;
    
    if(nil == _interstitial)
    {
        _interstitial = [[ADInterstitialAd alloc] init];
        _interstitial.delegate = self;
    }

}

- (void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd
{
    NSLog(@"iAd,interstitialAdDidLoad");
}

- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd
{
    NSLog(@"iAd,interstitialAdDidUnload");
    self.interstitial = nil;
}

- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    [RCTool sendStatisticInfo:IAD_FAILED_EVENT];
    
    NSLog(@"iAd,interstitialAd <%@> recieved error <%@>", interstitialAd, error);
    self.interstitial = nil;
    
    //尝试调用Admob的全屏广告
    [self getAdInterstitial];
}

#pragma mark - Push Notification

- (void)sendProviderDeviceToken:(NSData*)devToken
{
	if(nil == devToken)
		return;
    
    NSString* temp = [devToken description];
	NSString* token = [temp stringByTrimmingCharactersInSet:
					   [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	NSLog(@"token:%@",token);
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSLog(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	NSLog(@"%@",[userInfo valueForKeyPath:@"aps.alert"]);
	
	UIApplication* app = [UIApplication sharedApplication];
	if(app.applicationIconBadgeNumber)
		app.applicationIconBadgeNumber = 0;
	else
	{
		NSString* message = [userInfo valueForKeyPath:@"aps.alert"];
		if([message length])
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Brave Bird"
															message: message delegate: self
												  cancelButtonTitle: @"Ok"
												  otherButtonTitles: nil];
			[alert show];
			[alert release];
		}
	}
}

- (void)onMethod:(NSString*)method response:(NSDictionary*)data
{
    NSLog(@"onMethod:%@", method);
    NSLog(@"data:%@", [data description]);
}


#pragma mark - Match Game

- (void)matchStarted{
    CCLOG(@"Match started");
    
}

- (void)matchEnded:(id)token{
    CCLOG(@"Match Ended");
}


- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID{
    
    DataPacket *packet = (DataPacket*)[data bytes];
    
    CCLOG(@"Received data from player:%@",playerID);
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:packet->type] forKey:@"type"];
    
    if(PMT_TAP == packet->type)
    {
        [dict setObject:[NSNumber numberWithInt:packet->count] forKey:@"count"];
    }
    else if(PMT_PIPES == packet->type)
    {
        [dict setObject:[NSNumber numberWithInt:packet->type] forKey:@"type"];
        
        NSMutableArray* array = [[NSMutableArray alloc] init];
        for(int i=0; i<200; i++)
        {
            float value = packet->a[i];
            if(value)
            {
                [array addObject:[NSNumber numberWithFloat:value]];
            }
        }
        
        [dict setObject:array forKey:@"positions"];
        [array release];
    }
    else if(PMT_ROLE == packet->type)
    {
        [dict setObject:[NSNumber numberWithInt:packet->count] forKey:@"count"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVED_DATA_NOTIFICATION object:nil userInfo:dict];
    [dict release];
}

#pragma mark - 

- (void)getAdId
{
    if ([RCTool isReachableViaInternet]) {
        NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
        NSArray* languages = [defs objectForKey:@"AppleLanguages"];
        NSString* preferredLang = [languages objectAtIndex:0];
        NSLog(@"Preferred Language:%@", preferredLang);
        
        NSString *coutryCode = preferredLang;
        if (![coutryCode isEqualToString:@"en"] && ![coutryCode isEqualToString:@"ko"] && ![coutryCode isEqualToString:@"zh-Hans"] && ![coutryCode isEqualToString:@"fr"] && ![coutryCode isEqualToString:@"zh-Hant"] && ![coutryCode isEqualToString:@"pt"] && ![coutryCode isEqualToString:@"pt-PT"] && ![coutryCode isEqualToString:@"ja"] && ![coutryCode isEqualToString:@"ko "] && ![coutryCode isEqualToString:@"es"] && ![coutryCode isEqualToString:@"de"] && ![coutryCode isEqualToString:@"it"] && ![coutryCode isEqualToString:@"ru"]) {
            coutryCode=@"en";
        }
        
        NSString *hostString = [NSString stringWithFormat:@"%@%@.xml",adHostName,coutryCode];
        NSURL *url=[[NSURL alloc] initWithString:hostString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [url release];
        [NSURLConnection sendAsynchronousRequest:request
         // the NSOperationQueue upon which the handler block will be dispatched:
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   // back on the main thread, check for errors, if no errors start the parsing
                                   //
                                   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                   
                                   // here we check for any returned NSError from the server, "and" we also check for any http response errors
                                   if (error != nil) {
                                       //[self handleError:error];
                                   }
                                   else {
                                       //NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                       //NSLog(@"%@",str);
                                       // Update the UI and start parsing the data,
                                       // Spawn an NSOperation to parse the earthquake data so that the UI is not
                                       // blocked while the application parses the XML data.
                                       //初始化用来临时存储从xml中读取到的字符串
                                       self.workingPropertyString = [NSMutableString string];
                                       
                                       //初始化用来存储解析后的xml文件
                                       self.workingArray = [NSMutableArray array];
                                       
                                       //将xml文件转换成data类型
                                       self.xmlData = data;
                                       
                                       //初始化待解析的xml
                                       self.parserXML = [[NSXMLParser alloc] initWithData:xmlData];
                                       
                                       //初始化需要从xml中解析的元素
                                       self.elementsToParse = [NSArray arrayWithObjects:kTitleStr, kContentStr, kLinkStr, kCancelStr,kSureStr, nil];
                                       
                                       
                                       //设置xml解析代理为self
                                       [parserXML setDelegate:self];
                                       
                                       //开始解析
                                       BOOL success = [parserXML parse];//调用解析的代理方法
                                       if (success) {
                                           NSLog(@"jie xi chenggong");
                                       }else{
                                           NSLog(@"jie xi shibai");
                                       }
                                   }
                               }];
        
        //初始化广告ID
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.bannerAdId = @"";
        self.fullScreenAdId = [defaults objectForKey:@"fullScreenAdId"];

        //获取Banner广告ID
        NSString* urlString = bannerAdhost;
        if([RCTool isIpadMini] || [RCTool isIpad])
            urlString = BANNER_AD_URL_FOR_IPAD;
        
        RCHttpRequest* temp = [RCHttpRequest sharedInstance];
        [temp request:urlString delegate:self resultSelector:@selector(finishedBannerAdInfoRequest:) token:nil];
}
}

- (void)finishedBannerAdInfoRequest:(NSString*)xmlString
{
    if([xmlString length])
        self.bannerAdId = xmlString;
    
    NSLog(@"bannerAdId:%@",self.bannerAdId);
    
    if([self.bannerAdId length])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.bannerAdId forKey:@"bannerAdId"];
        [defaults synchronize];
    }
    
    //获取全屏广告ID
    NSString* urlString = fullscreenADhost;
    RCHttpRequest* temp = [RCHttpRequest sharedInstance];
    [temp request:urlString delegate:self resultSelector:@selector(finishedFullScreenAdInfoRequest:) token:nil];
    
    BOOL b = [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_ads"];
    if(b)
    {
        return;
    }
    
    [self initAdMob];
}

- (void)finishedFullScreenAdInfoRequest:(NSString*)xmlString
{
    if([xmlString length])
        self.fullScreenAdId = xmlString;
    
    NSLog(@"fullScreenAdId:%@",self.fullScreenAdId);
    
    if([self.fullScreenAdId length])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.fullScreenAdId forKey:@"fullScreenAdId"];
        [defaults synchronize];
    }

    BOOL b = [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_ads"];
    if(b)
    {
        return;
    }
    
    [self getAdInterstitial];
}

#pragma mark URLConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"get the whole response");
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{

}





- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //[connection release];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //[connection release];
    NSLog(@"Connection failed! Error - %@ %@",[error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);//NSErrorFailingURLStringKey
}


//遍例xml的节点
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    // entry: { id (link), im:name (app name), im:image (variable height) }
    //判断elementName与images是否相等
    if ([elementName isEqualToString:@"root"])
	{
        //相等的话,重新初始化workingEntry
		self.workingEntry = [[[AppRecord alloc] init] autorelease];
    }
	//查询指定对象是否存在，我们需要保存的那四个对象，开头定义的四个static
    storingCharacterData = [self.elementsToParse containsObject:elementName];
}

//节点有值则调用此方法
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
{
    if (storingCharacterData)
    {
		//string添加到workingPropertyString中
        [self.workingPropertyString appendString:string];
    }
}
//当遇到结束标记时，进入此句
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
	//判断workingEntry是否为空
	if (self.workingEntry)
	{
        if (storingCharacterData)
        {
			//NSString的方法，去掉字符串前后的空格
			NSString *trimmedString = [self.workingPropertyString stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            //将字符串置空
			[self.workingPropertyString setString:@""];
			//根据元素名，进行相应的存储
			if ([elementName isEqualToString:kTitleStr])
            {
                self.workingEntry.title = trimmedString;
            }
            else if ([elementName isEqualToString:kContentStr])
            {
                self.workingEntry.content = trimmedString;
            }
            else if ([elementName isEqualToString:kLinkStr])
            {
                self.workingEntry.link = trimmedString;
            }
            else if ([elementName isEqualToString:kCancelStr])
            {
                self.workingEntry.cancelTitle= trimmedString;
            }
			else if ([elementName isEqualToString:kSureStr])
            {
                self.workingEntry.sureTitle= trimmedString;
            }
		}
	}
	//遇到images时，将本次解析的数据存入数组workingArray中，AppRecord对象置空
    if ([elementName isEqualToString:@"root"])
	{
        currentEntry = self.workingEntry;
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:currentEntry.title
                                                        message:currentEntry.content
                                                       delegate:self cancelButtonTitle:currentEntry.cancelTitle otherButtonTitles:currentEntry.sureTitle, nil];
        [alert show];
        [alert release];
        
		[self.workingArray addObject:self.workingEntry];
		self.workingEntry = nil;
		//用于检测数组中是否已保存，实际使用时可去掉，保存的是AppRecord的地址
		NSLog(@"%@",workingArray);
	}
}


#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:currentEntry.link]];
    }
}

- (void)removeAllAds:(NSNotification*)notifi
{
    //去除广告
    if(self.adMobAd && self.adMobAd.superview)
    {
        [self.adMobAd removeFromSuperview];
        self.adMobAd = nil;
    }

    if(self.adView && self.adView.superview)
    {
        [self.adView removeFromSuperview];
        self.adView = nil;
    }
    self.adInterstitial = nil;
    self.interstitial = nil;
}

#pragma mark - In App Purchase

- (BOOL)checkEnableIAP
{
    if([SKPaymentQueue canMakePayments])
    {
        return YES;
    }
    
    return NO;
}

- (void)requestProductData
{
    if(self.isLoading)
        return;
    
    self.isLoading = YES;
    SKProductsRequest *request= [[[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects:REMOVE_AD_ID,nil]] autorelease];
    request.delegate = self;
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    self.isLoading = NO;
    
    self.products = response.products;
    
    for(SKProduct* product in self.products)
    {
        if([product.productIdentifier isEqualToString:REMOVE_AD_ID])
        {
            self.removeAdProduct = product;
            break;
        }
    }
}

- (void)buyProduct
{
    [self buyProduct:self.removeAdProduct];
}

- (void)buyProduct:(SKProduct*)product
{
    if(self.isPaying)
        return;
    
    if(nil == product)
    {
        if([self checkEnableIAP] && nil == self.removeAdProduct)
            [self requestProductData];
        
        [RCTool showAlert:@"Hint" message:@"No product for purchase!"];
        return;
    }
    
    if(NO == [self checkEnableIAP])
    {
        [RCTool showAlert:@"Hint" message:@"Please enable In-App Purchase first!"];
        return;
    }
    
    //[RCTool showIndicator:@"Loading..." view:self.view];
    self.isPaying = YES;
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restoreProduct
{
    if(self.isPaying)
        return;
    
    self.isPaying = YES;
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    self.isPaying = NO;
    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished");
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    self.isPaying = NO;
    NSLog(@"restoreCompletedTransactionsFailedWithError");
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
            {
                break;
            }
            default:
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"completeTransaction");
    
    self.isPaying = NO;
    
    if(transaction.transactionState == SKPaymentTransactionStatePurchased)
    {
        if(transaction.transactionReceipt)
        {
            if([transaction.payment.productIdentifier isEqualToString:REMOVE_AD_ID])
            {
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"remove_ads"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"REMOVE_ALL_ADS" object:nil];
                    
                    [RCTool showAlert:@"Purchase Successfully" message:@"The advertisement has been removed."];
                }
            }
        }
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"restoreTransaction");
    
    self.isPaying = NO;
    
    if([transaction.payment.productIdentifier isEqualToString:REMOVE_AD_ID])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"remove_ads"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"REMOVE_ALL_ADS" object:nil];
        
        [RCTool showAlert:@"Restore Purchase Successfully" message:@"The advertisement has been removed."];
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"failedTransaction");
    
    self.isPaying = NO;
    
    if(transaction.error.code != SKErrorPaymentCancelled){
        // Optionally, display an error here.
        
        NSString* temp = [NSString stringWithFormat:@"%@",[transaction.error localizedDescription]];
        [RCTool showAlert:@"Payment Failed" message:temp];
    }
    
    NSLog(@"transaction.error.code:%d",transaction.error.code);
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

@end

