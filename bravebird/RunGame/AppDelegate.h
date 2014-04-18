//
//  AppDelegate.h
//  RunGame
//
//  Created by xuzepei on 9/13/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "GADBannerView.h"
#import "GADInterstitial.h"
#import "GCHelper.h"
#import <iAd/iAd.h>
#import "AppRecord.h"
#import <StoreKit/StoreKit.h>

#define adHostName @"http://m4r.download4ios.com/flyingbirdyuan/tuiguang/"
#define bannerAdhost @"http://m4r.download4ios.com/flyingbirdyuan/1.txt"
#define fullscreenADhost @"http://m4r.download4ios.com/flyingbirdyuan/2.txt"
#define BANNER_AD_URL_FOR_IPAD @"http://m4r.download4ios.com/bravebird/v41/3.txt"


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@class RCNavigationController;
@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate,GADBannerViewDelegate,GADInterstitialDelegate,GCHelperDelegate,ADBannerViewDelegate,ADInterstitialAdDelegate,NSXMLParserDelegate,NSURLConnectionDataDelegate,UIAlertViewDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver>
{
	UIWindow *window_;
	CCDirectorIOS	*director_;							// weak ref
    
    NSMutableData *receivedData;

    NSData *xmlData;
    NSXMLParser *parserXML;
    NSData          *dataToParse;
    NSMutableArray  *workingArray;
    NSMutableString *workingPropertyString;
    NSArray         *elementsToParse;
    BOOL            storingCharacterData;
    AppRecord       *workingEntry;
    AppRecord *currentEntry;
    

}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) CCDirectorIOS *director;
@property (nonatomic,retain)RCNavigationController* navigationController;

//CoreData
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) GADBannerView *adMobAd;
@property (assign)BOOL isAdMobVisible;
@property (nonatomic, retain) GADInterstitial *adInterstitial;

@property (nonatomic, retain) ADBannerView *adView;
@property (assign)BOOL isAdViewVisible;
@property (nonatomic, retain) ADInterstitialAd* interstitial;

@property (nonatomic,strong) NSString* bannerAdId;
@property (nonatomic,strong) NSString* fullScreenAdId;

@property (nonatomic,retain) NSXMLParser *parserXML;
@property (nonatomic,retain) NSData *xmlData;
@property (nonatomic,retain) NSData          *dataToParse;
@property (nonatomic,retain) NSMutableArray  *workingArray;
@property (nonatomic,retain) NSMutableString *workingPropertyString;
@property (nonatomic,retain) NSArray         *elementsToParse;
@property (nonatomic,retain) AppRecord       *workingEntry;

@property(nonatomic,retain)NSArray* products;
@property(nonatomic,retain)SKProduct* removeAdProduct;
@property(nonatomic,retain)SKProduct* buyCoinsProduct;
@property(assign)BOOL isPaying;
@property(assign)BOOL isLoading;

- (void)saveContext;
- (NSURL*)applicationDocumentsDirectory;
- (void)showInterstitialAd:(id)argument;

@end
