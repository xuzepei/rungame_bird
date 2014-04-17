//
//  RCShopLayer.h
//  RunGame
//
//  Created by xuzepei on 4/14/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "RCMenuItemSprite2.h"
#import "CCItemsScroller.h"
#import "CCSelectableItem.h"
#import "RCShopBirdItem.h"
#import "RCShopWorldItem.h"

@protocol RCShopLayerDelegate <NSObject>

- (void)clickedResetButton:(id)token;

@end

@interface RCShopLayer : CCLayer{
    
}

@property(nonatomic,retain)CCLabelTTF* coinLabel;
@property(assign)id delegate;
@property(nonatomic,retain)CCSprite* bgSprite;

@property(nonatomic,retain)RCMenuItemSprite2* birdMenuItem;
@property(nonatomic,retain)RCMenuItemSprite2* worldMenuItem;
@property(assign)int selected_tab_index;

@property(nonatomic,retain)NSMutableArray* birdsArray;
@property(nonatomic,retain)NSMutableArray* worldArray;

@end
