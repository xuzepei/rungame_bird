//
//  RCMatchGameBackground.h
//  RunGame
//
//  Created by xuzepei on 3/12/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCPipe.h"
#import "RCCoin.h"
#import "RCMatchGameScene.h"

@interface RCMatchGameBackground : CCLayer {
    
}

@property(nonatomic,retain)CCSpriteBatchNode* batch;
@property(nonatomic,retain)CCArray* speedFactors;
@property(nonatomic,retain)NSMutableArray* pipeArray;
@property(assign)float scrollSpeed;
@property(assign)BOOL running;
@property(assign)RCMatchGameScene* gameScene;

- (void)addPipe:(RCPipe*)pipe;

@end
