//
//  RCGameScene.h
//  RunGame
//
//  Created by xuzepei on 9/13/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLES-Render.h"
#import "Box2D.h"
#import "RCDuck.h"
#import "MyContactListener.h"
#import "RCPipe.h"

@class RCGameSceneParallaxBackground;
@interface RCGameScene : CCLayer {
    
    GLESDebugDraw* _debugDraw;
    
    b2World* _world;
    b2Body* _groundBody;
    b2Fixture* _groundFixture;
    
    MyContactListener* _contactListener;
    
}

@property(nonatomic,retain)RCDuck* duck;
@property(nonatomic,retain)NSMutableArray* pipeArray;
@property(assign)CGFloat pipeSpeed;
@property(nonatomic,retain)RCGameSceneParallaxBackground* parallaxBg;
@property(nonatomic,retain)CCSprite* readySprite;
@property(nonatomic,retain)CCSprite* tapSprite;

@property(nonatomic,retain)NSTimer* longTouchTimer;

@property(nonatomic,assign)BOOL isReady;

@property(nonatomic,assign)NSUInteger score;
@property(nonatomic,retain)CCLabelAtlas* scoreLabel;

@property(assign)int shakeLength;
@property(assign)int shakeIntensity;
@property(nonatomic,assign)BOOL shouldBeShaking;

+ (id)scene;
+ (RCGameScene*)sharedInstance;


@end
