//
//  RCPipe.h
//  RunGame
//
//  Created by xuzepei on 2/7/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface RCPipe : CCSprite {
    
}

@property(nonatomic,assign)BOOL isPassed;
@property(nonatomic,assign)int type;
@property(nonatomic,assign)BOOL up;
@property(nonatomic,assign)BOOL right;
@property(nonatomic,assign)RCPipe* bottomPipe;
@property(nonatomic,assign)BOOL isAngry;
@property(nonatomic,assign)BOOL isRotated;

+ (id)pipe:(int)type;
- (CGRect)frame;
- (BOOL)isBottom;
- (void)setAction:(BOOL)isAngry isRotated:(BOOL)isRotated;

@end
