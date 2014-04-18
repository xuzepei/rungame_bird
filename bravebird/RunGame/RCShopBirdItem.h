//
//  RCShopBirdItem.h
//  RunGame
//
//  Created by xuzepei on 4/16/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "RCMenuItemSprite.h"

@interface RCShopBirdItem : CCLayerColor<UIAlertViewDelegate> {
    
}

@property(nonatomic,retain)CCSprite* sprite;
@property(nonatomic,retain)RCMenuItemSprite* button;
@property(assign)int type;

- (void)initWithType:(int)type;
- (void)updateButton;

@end
