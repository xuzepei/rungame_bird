//
//  RCCoin.h
//  RunGame
//
//  Created by xuzepei on 3/2/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface RCCoin : CCSprite {
    
}

@property(nonatomic,retain)CCAnimation* rotateAnimation;

+ (id)coin;
- (void)rotate;


@end
