//
//  GCHelper.h
//  BeatMole
//
//  Created by xuzepei on 8/12/13.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "GKMatchmakerViewController+LandscapeOnly.h"

@protocol GCHelperDelegate <NSObject>

@optional
- (void)matchStarted;
- (void)matchEnded:(id)token;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;


@end

@interface GCHelper : NSObject<GKMatchmakerViewControllerDelegate,GKMatchDelegate>

@property(assign)BOOL userAuthenticated;
@property(assign, readonly)BOOL gameCenterAvailable;
@property(nonatomic,retain)GKScore* myScore;

@property(nonatomic,retain)UIViewController *presentingViewController;
@property(nonatomic,retain)GKMatch *match;
@property(assign)id<GCHelperDelegate> delegate;
@property(assign)BOOL matchStarted;

+ (GCHelper*)sharedInstance;
- (void)authenticateLocalUser;
- (BOOL)reportScore:(int64_t)score;
- (BOOL)reportPlayTimes:(int64_t)times;
- (BOOL)reportGoldCoinNum:(int64_t)t;
- (void)getPlayerInfo;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController
                       delegate:(id<GCHelperDelegate>)delegate;
- (void)sendData:(id)data type:(int)type;

@end
