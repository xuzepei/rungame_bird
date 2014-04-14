//
//  RCMatchGameScene.h
//  RunGame
//
//  Created by xuzepei on 3/11/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLES-Render.h"
#import "Box2D.h"
#import "RCDuck.h"
#import "MyContactListener.h"
#import "RCPipe.h"
#import "RCMatchDuck.h"

@class RCMatchGameBackground;
@interface RCMatchGameScene : CCLayer {
    
    GLESDebugDraw* _debugDraw;
    
    b2World* _world;
    b2Body* _groundBody;
    b2Fixture* _groundFixture;
    
    MyContactListener* _contactListener;
    
}

@property(nonatomic,retain)RCDuck* duck;
@property(nonatomic,retain)RCDuck* duck1;
@property(nonatomic,retain)RCMatchDuck* matchDuck;
@property(nonatomic,retain)NSMutableArray* pipeArray;
@property(assign)CGFloat pipeSpeed;
@property(nonatomic,retain)RCMatchGameBackground* parallaxBg;
@property(nonatomic,retain)CCSprite* readySprite;
@property(nonatomic,retain)CCSprite* tapSprite;

@property(nonatomic,assign)BOOL isReady;
@property(assign)int matchReady;
@property(assign)BOOL isPlaying;
@property(assign)BOOL isWinned;

@property(nonatomic,assign)NSUInteger score;
@property(nonatomic,retain)CCLabelAtlas* scoreLabel;

@property(assign)int shakeLength;
@property(assign)int shakeIntensity;
@property(nonatomic,assign)BOOL shouldBeShaking;
@property(nonatomic,retain)NSArray* pipePositions;

@property(assign)int roleNum;
@property(assign)int roleType;
@property(assign)int matchRoleType;

+ (id)scene;
+ (RCMatchGameScene*)sharedInstance;

@end
