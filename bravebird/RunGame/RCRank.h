//
//  RCRank.h
//  RunGame
//
//  Created by xuzepei on 3/6/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol RCRankDelegate <NSObject>

- (void)clickedRankButton:(id)sender;

@end

@interface RCRank : CCSprite<CCTargetedTouchDelegate> {
    
    
}

@property(assign)id delegate;
@property(nonatomic,retain)CCLabelBMFont* label;
@property(assign)CGSize clickableSize;

- (void)move;
- (void)updateRank:(int64_t)rank;

@end
