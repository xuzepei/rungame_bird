//
//  RCPauseLayer.m
//  RunGame
//
//  Created by xuzepei on 9/25/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCPauseLayer.h"
#import "RCMenuItemSprite.h"

@implementation RCPauseLayer

- (id)init
{
    if(self = [super init])
    {
        CGSize winSize = WIN_SIZE;
        ccColor4B bgColor = {0,0,0,160};
        CCLayerColor* bgColorLayer = [CCLayerColor layerWithColor:bgColor width:winSize.width height:winSize.height*5];
        [self addChild:bgColorLayer z:0];
        
        [RCTool addCacheFrame:@"images_block.plist"];
        
        [self initButtons];
    }
    
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    
    [super dealloc];
}

- (void)initButtons
{
    CGSize winSize = WIN_SIZE;
    
    CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"play_button.png"];
    CCMenuItemSprite* menuItem = [RCMenuItemSprite itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedResumeButton:)];
    
    CCMenu* menu = [CCMenu menuWithItems:menuItem, nil];
    menu.anchorPoint = ccp(0,1);
    menu.position = ccp(30, winSize.height - 30);
    [self addChild: menu z:50];
    
    sprite = [CCSprite spriteWithSpriteFrameName:@"menu_button.png"];
    menuItem = [RCMenuItemSprite itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedMenuButton:)];
    menu = [CCMenu menuWithItems:menuItem, nil];
    //menu.anchorPoint = ccp(0,1);
    menu.position = ccp(winSize.width/2.0, winSize.height/2.0);
    [self addChild: menu z:50];
    
}

- (void)clickedMenuButton:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickedBackButton:)])
    {
        [self.delegate clickedBackButton:nil];
        [self removeFromParentAndCleanup:YES];
    }
}

- (void)clickedResumeButton:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickedResumeButton:)])
    {
        [self.delegate clickedResumeButton:nil];
        [self removeFromParentAndCleanup:YES];
    }
}

- (void)clickedRestartButton:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickedRestartButton:)])
    {
        [self.delegate clickedRestartButton:nil];
        [self removeFromParentAndCleanup:YES];
    }
}

@end
