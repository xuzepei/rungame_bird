//
//  RCShopBirdItem.m
//  RunGame
//
//  Created by xuzepei on 4/16/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "RCShopBirdItem.h"
#import "CCAnimation+Helper.h"

@implementation RCShopBirdItem

- (void)initWithType:(int)type;
{

    //self.isTouchEnabled = YES;
    
    self.type = type;

    [RCTool addCacheFrame:@"images_block.plist"];
    
    [self initBg];
    
    [self initButtons];
    
    [self initBird];
    
    [self initLabels];
}

- (void)dealloc
{
    self.sprite = nil;
    self.button = nil;
    
    [super dealloc];
}

- (void)initBg
{
//    NSString* imageName = @"shop_bg.png";
//    CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName];
//    self.bgSprite = [CCSprite spriteWithSpriteFrame:spriteFrame];
//    
//    self.bgSprite.scale = 0.9;
//    self.bgSprite.anchorPoint = ccp(0.5,1);
//    self.bgSprite.position = ccp(WIN_SIZE.width/2.0,WIN_SIZE.height - 50);
//    [self addChild:self.bgSprite z:0];
}

#pragma mark -  Buttons

- (void)initButtons
{
    NSString* imageName = @"buy_button.png";
    int status = [RCTool getBirdStatusByType:self.type];
    if(0 == status)
        imageName = @"unuse_button.png";
    else if(1 == status)
        imageName = @"use_button.png";
    
    CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:imageName];
    sprite.scale = 0.8;
    self.button = [RCMenuItemSprite itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedButton:)];
    self.button.tag = self.type;
    
    CCMenu* menu = [CCMenu menuWithItems:self.button, nil];
    CGFloat offset_x = 256;
    CGFloat offset_y = 44;
    if([RCTool isIpadMini])
    {
        offset_x = 512;
        offset_y = 88;
    }
    menu.position = ccp(offset_x, offset_y);
    [self addChild: menu z:50];
}

- (void)clickedButton:(id)sender
{
    NSLog(@"clickedButton");
    CCMenuItemSprite* itemSprite = (CCMenuItemSprite*)sender;
    NSLog(@"bird item,tag:%d",itemSprite.tag);
    
    int status = [RCTool getBirdStatusByType:itemSprite.tag];
    if(-1 == status)
    {
        NSLog(@"need buy!");
        
        [RCTool setBirdStatus:0 type:itemSprite.tag];
        [self updateButton];
    }
    else if(0 == status)
    {
        [RCTool setBirdStatus:1 type:itemSprite.tag];
        [self updateButton];
        
        for(int i = 0; i < BIRDS_NUM; i++)
        {
            if(i != itemSprite.tag)
            {
                int status = [RCTool getBirdStatusByType:i];
                if(1 == status)
                    [RCTool setBirdStatus:0 type:i];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:BUTTON_STATUS_CHANGE_NOTIFICATION object:nil userInfo:nil];
    }
}

- (void)updateButton
{
    NSString* imageName = @"buy_button.png";
    int status = [RCTool getBirdStatusByType:self.type];
    if(0 == status)
        imageName = @"unuse_button.png";
    else if(1 == status)
        imageName = @"use_button.png";
    
    if(self.button)
    {
        CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:imageName];
        sprite.scale = 0.8;
        [self.button setNormalImage:sprite];
    }
}

- (void)initBird
{
    NSArray* indexArray = [NSArray arrayWithObjects:@"0",@"1",@"2",nil];
    NSString* frameName = [NSString stringWithFormat:@"fly_0_"];
    CCAnimation* flyAnimation = [CCAnimation animationWithFrame:frameName indexArray:indexArray delay:0.15];
    
    NSString* imageName = @"fly_0_0.png";
    CCSprite* duckSprite = [CCSprite spriteWithSpriteFrameName:imageName];
    CGFloat offset_x = 30.0f;
    if([RCTool isIpadMini])
        offset_x = 50.0f;
    duckSprite.position = ccp(offset_x,self.contentSize.height/2.0 -3);
        
    [self addChild:duckSprite z:20];
    
    id fly = [CCAnimate actionWithAnimation:flyAnimation];
    id moveUp = [CCMoveBy actionWithDuration:0.8 position:ccp(0,[RCTool getValueByHeightScale:5])];
    id moveDown = [CCMoveBy actionWithDuration:0.8 position:ccp(0,[RCTool getValueByHeightScale:-5])];

    id sequence = [CCSequence actions:moveUp,moveDown,nil];
    
    CCRepeatForever* repeat1 = [CCRepeatForever actionWithAction:sequence];
    CCRepeatForever* repeat2 = [CCRepeatForever actionWithAction:fly];
    [duckSprite runAction:repeat1];
    [duckSprite runAction:repeat2];
}

- (void)initLabels
{
    int fontSize = 20;
    if([RCTool isIpadMini])
    {
        fontSize = 40.0f;
    }

    NSDictionary* info = [RCTool getBirdInfo:self.type];
    if(info)
    {
        CCLabelTTF* label = [CCLabelTTF labelWithString:[info objectForKey:@"name"] fontName:@"Helvetica-Bold" fontSize:fontSize];
        label.anchorPoint = ccp(0,1);
        
        CGFloat offset_x = 60.0f;
        CGFloat offset_y = 66.0f;
        if([RCTool isIpadMini])
        {
            offset_x = 100.0f;
            offset_y = 132.0f;
        }
        label.position = ccp(offset_x,offset_y);
        [self addChild:label];
        
        int fontSize = 15;
        if([RCTool isIpadMini])
        {
            fontSize = 30.0f;
        }

        label = [CCLabelTTF labelWithString:[info objectForKey:@"desc"] fontName:@"Helvetica" fontSize:fontSize];
        label.anchorPoint = ccp(0,1);
        offset_x = 60.0f;
        offset_y = 30.0f;
        if([RCTool isIpadMini])
        {
            offset_x = 100.0f;
            offset_y = 60.0f;
        }
        label.position = ccp(offset_x,offset_y);
        [self addChild:label];
    }
}

@end
