//
//  RCShopWorldItem.h
//  RunGame
//
//  Created by xuzepei on 4/17/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "RCMenuItemSprite.h"

@interface RCShopWorldItem : CCLayerColor {
    
}

@property(nonatomic,retain)CCSprite* sprite;
@property(nonatomic,retain)RCMenuItemSprite* button;
@property(assign)int type;

- (void)initWithType:(int)type;
- (void)updateButton;

@end
