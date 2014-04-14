//
//  RCHomeScene.h
//  BeatMole
//
//  Created by xuzepei on 5/28/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <GameKit/GameKit.h>
#import "GCHelper.h"
#import "RCLabelAtlas.h"
#import "RCCoin.h"
#import "RCRank.h"


@interface RCHomeScene : CCLayer<GKLeaderboardViewControllerDelegate,GKGameCenterControllerDelegate,UIActionSheetDelegate> {
    
}

@property(nonatomic,retain)CCSprite* bgSprite;
@property(nonatomic,retain)CCSprite* duckSprite;
@property(nonatomic,retain)CCSprite* titleSprite;
@property(nonatomic,retain)CCMenu* startButton;
@property(nonatomic,retain)CCMenu* scoreButton;
@property(nonatomic,retain)CCMenu* rateButton;
@property(nonatomic,retain)CCMenu* leaderboardButton;
@property(nonatomic,retain)CCMenu* shopButton;
@property(nonatomic,retain)CCMenu* settingsButton;
@property(nonatomic,retain)CCSprite* medalSprite;
@property(nonatomic,retain)RCCoin* coinSprite;
@property(nonatomic,retain)RCLabelAtlas* coinLabel;
@property(assign)long gc_rank;
@property(nonatomic,retain)RCRank* rankSprite;



+ (id)scene;
+ (RCHomeScene*)sharedInstance;

@end
