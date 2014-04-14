//
//  RCMatchDuck.h
//  RunGame
//
//  Created by xuzepei on 3/14/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface RCMatchDuck : CCSprite {
    
}

@property(assign)int type;
@property(nonatomic,retain)CCAnimation* flyAnimation;

+ (id)duck:(int)type;

@end
