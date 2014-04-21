//
//  RCTool.h
//  BeatMole
//
//  Created by xuzepei on 5/23/13.
//
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@class RCMainViewController;
@class RCNavigationController;
@interface RCTool : NSObject

+ (NSString*)getUserDocumentDirectoryPath;
+ (NSString *)md5:(NSString *)str;
+ (NSString *)getIpAddress;
+ (NSString*)base64forData:(NSData*)theData;
+ (CGSize)getScreenSize;
+ (CGRect)getScreenRect;
+ (BOOL)isIphone5;
+ (BOOL)isIpad;
+ (BOOL)isIpadMini;
+ (BOOL)isOpenAll;
+ (UIWindow*)frontWindow;
+ (RCNavigationController*)getRootNavigationController;
+ (void)showAlert:(NSString*)aTitle message:(NSString*)message;
+ (CGFloat)systemVersion;
+ (AppController*)getAppDelegate;
+ (NSString*)getAdId;
+ (NSString*)getScreenAdId;

+ (void)addCacheFrame:(NSString*)plistFile;
+ (void)removeCacheFrame:(NSString*)plistFile;

+ (void)resizeSprite:(CCSprite*)sprite toWidth:(float)width toHeight:(float)height;
+ (float)getWidthScale;
+ (float)getHeightScale;
+ (float)getValueByWidthScale:(float)value;
+ (float)getValueByHeightScale:(float)value;


+ (int)randomByType:(int)type;
+ (UIImage*)screenshotWithStartNode:(CCNode*)startNode;

+ (BOOL)isRealDevice;

+ (NSDictionary*)parseToDictionary:(NSString*)jsonString;

#pragma mark - Get Random Number

+ (float)randFloat:(float)max min:(float)min;

#pragma mark - Settings

+ (void)setBKVolume:(CGFloat)volume;
+ (CGFloat)getBKVolume;

+ (void)setEffectVolume:(CGFloat)volume;
+ (CGFloat)getEffectVolume;

#pragma mark - Network
+ (BOOL)isReachableViaWiFi;
+ (BOOL)isReachableViaInternet;

#pragma mark - Play Sound
+ (void)preloadEffectSound:(NSString*)soundName;
+ (void)unloadEffectSound:(NSString*)soundName;
+ (void)playEffectSound:(NSString*)soundName;

+ (void)playBgSound:(NSString*)soundName;
+ (void)pauseBgSound;
+ (void)resumeBgSound;

#pragma mark - Record

+ (int)getRecordByType:(int)type;
+ (void)setRecordByType:(int)type value:(int64_t)value;

#pragma mark - Achievement
+ (BOOL)checkAchievementByType:(int)type;
+ (void)setAchievementByType:(int)type value:(int)value;

#pragma mark - Core Data

+ (NSPersistentStoreCoordinator*)getPersistentStoreCoordinator;
+ (NSManagedObjectContext*)getManagedObjectContext;
+ (NSManagedObjectID*)getExistingEntityObjectIDForName:(NSString*)entityName
											 predicate:(NSPredicate*)predicate
									   sortDescriptors:(NSArray*)sortDescriptors
											   context:(NSManagedObjectContext*)context;

+ (NSArray*)getExistingEntityObjectsForName:(NSString*)entityName
								  predicate:(NSPredicate*)predicate
							sortDescriptors:(NSArray*)sortDescriptors;

+ (id)insertEntityObjectForName:(NSString*)entityName
		   managedObjectContext:(NSManagedObjectContext*)managedObjectContext;

+ (id)insertEntityObjectForID:(NSManagedObjectID*)objectID
		 managedObjectContext:(NSManagedObjectContext*)managedObjectContext;

+ (void)saveCoreData;

+ (void)deleteOldData;

+ (NSString*)encryptString:(NSString*)string password:(NSString*)password;
+ (NSString*)decryptString:(NSString*)string password:(NSString*)password;

#pragma mark - Ad

+ (void)showAd:(BOOL)b;
+ (void)showInterstitialAd;

#pragma mark - Play Times

+ (void)addPlayTimes;
+ (int)getPlayTimes;

#pragma mark - UMeng

+ (void)sendStatisticInfo:(NSString*)eventName;

#pragma mark - Angry Pipe
+ (BOOL)hasChance:(int)x y:(int)y;
+ (BOOL)isAngry;
+ (BOOL)isRotated;

#pragma mark - 获取匹配赛管道布置地图
+ (NSArray*)createPipesPosition;

#pragma mark - 获取角色状态

+ (int)getBirdStatusByType:(int)type;
+ (void)setBirdStatus:(int)status type:(int)type;

+ (int)getWorldStatusByType:(int)type;
+ (void)setWorldStatus:(int)status type:(int)type;

+ (int)getCurrentBirdType;
+ (int)getCurrentWorldType;

+ (NSDictionary*)getBirdInfo:(int)type;
+ (NSDictionary*)getWorldInfo:(int)type;

@end
