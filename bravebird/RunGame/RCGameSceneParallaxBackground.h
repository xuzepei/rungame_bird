//
//  RCGameSceneParallaxBackground.h
//  RunGame
//
//  Created by xuzepei on 9/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCPipe.h"
#import "RCCoin.h"

@interface RCGameSceneParallaxBackground : CCLayer {
    
}

@property(nonatomic,retain)CCSpriteBatchNode* batch;
@property(nonatomic,retain)CCArray* speedFactors;
@property(nonatomic,retain)NSMutableArray* pipeArray;
@property(assign)float scrollSpeed;
@property(assign)BOOL running;

- (void)addPipe:(RCPipe*)pipe;

@end
