//
//  RCDuck.h
//  RunGame
//
//  Created by xuzepei on 2/3/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "RCBox2dSprite.h"

@interface RCDuck : RCBox2dSprite {
    
    int _velocitiesX[5];
    int _velocitiesY[5];
    
}

@property(nonatomic,retain)CCAnimation* flyAnimation;
@property(nonatomic,assign)BOOL isOver;
@property(nonatomic,assign)BOOL isHitted;
@property(nonatomic,assign)int score;
@property(nonatomic,assign)int64_t flapTimes; //防作弊
@property(nonatomic,assign)BOOL isNewScore;
@property(nonatomic,assign)int numVelocities;
@property(nonatomic,assign)int nextVelocity;
@property(nonatomic,assign)int type;

+ (id)duck:(int)type;
- (BOOL)needCheckCollision;
- (void)flap;
- (void)flyUpDown;
- (void)fly;
- (CGRect)frame;
- (void)pass;
- (void)hit;
- (void)over;


@end
