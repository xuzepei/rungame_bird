//
//  RCShopWorldItem.m
//  RunGame
//
//  Created by xuzepei on 4/17/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "RCShopWorldItem.h"
#import "CCAnimation+Helper.h"

@implementation RCShopWorldItem

- (void)initWithType:(int)type;
{
    
    //self.isTouchEnabled = YES;
    
    self.type = type;
    
    [RCTool addCacheFrame:@"images_block.plist"];
    
    [self initBg];
    
    [self initButtons];
    
    [self initWorld];
    
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
    int status = [RCTool getWorldStatusByType:self.type];
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
    NSLog(@"world item,tag:%d",itemSprite.tag);

    int status = [RCTool getWorldStatusByType:self.type];
    if(-1 == status)
    {
        NSLog(@"need buy!");
        NSDictionary* info = [RCTool getWorldInfo:self.type];
        if(nil == info)
            return;
        
        NSString* price = [info objectForKey:@"price"];
        NSString* name = [info objectForKey:@"name"];
        
        NSString* message = [NSString stringWithFormat:@"Do you want to cost %@ coins for %@?",price,name];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Tip"
                                                        message: message
                                                       delegate: self
                                              cancelButtonTitle: @"Cancel"
                                              otherButtonTitles: @"Ok",nil];
        alert.tag = 120;
        [alert show];
        [alert release];
        

    }
    else if(0 == status)
    {
        [RCTool setWorldStatus:1 type:self.type];
        [self updateButton];
        
        for(int i = 0; i < WORLD_NUM; i++)
        {
            if(i != itemSprite.tag)
            {
                int status = [RCTool getWorldStatusByType:i];
                if(1 == status)
                    [RCTool setWorldStatus:0 type:i];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:BUTTON_STATUS_CHANGE_NOTIFICATION object:nil userInfo:nil];
    }
}

- (void)updateButton
{
    NSString* imageName = @"buy_button.png";
    int status = [RCTool getWorldStatusByType:self.type];
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

- (void)initWorld
{
    NSString* imageName = [NSString stringWithFormat:@"bg_review_%d.png",self.type];
    CCSprite* duckSprite = [CCSprite spriteWithSpriteFrameName:imageName];
    CGFloat offset_x = 30.0f;
    if([RCTool isIpadMini])
        offset_x = 50.0f;
    duckSprite.position = ccp(offset_x,self.contentSize.height/2.0 -3);
    
    [self addChild:duckSprite z:20];
}

- (void)initLabels
{
    int fontSize = 20;
    if([RCTool isIpadMini])
    {
        fontSize = 40.0f;
    }
    
    NSDictionary* info = [RCTool getWorldInfo:self.type];
    if(info)
    {
        CCLabelTTF* label = [CCLabelTTF labelWithString:[info objectForKey:@"name"] fontName:@"Helvetica-Bold" fontSize:fontSize];
        label.anchorPoint = ccp(0,1);
        
        CGFloat offset_x = 60.0f;
        CGFloat offset_y = 66.0f;
        if([RCTool isIpadMini])
        {
            offset_x = 110.0f;
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
            offset_x = 110.0f;
            offset_y = 60.0f;
        }
        label.position = ccp(offset_x,offset_y);
        [self addChild:label];
    }
}

#pragma mark - Buy

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(120 == alertView.tag)
    {
        NSLog(@"buttonIndex:%d",buttonIndex);
        if(1 == buttonIndex)
        {
            int coin_num = [RCTool getRecordByType:RT_COIN];
            
            NSDictionary* info = [RCTool getWorldInfo:self.type];
            if(nil == info)
                return;
            
            int price = [[info objectForKey:@"price"] intValue];
            
            if(price > coin_num)
            {
                NSString* message = [NSString stringWithFormat:@"Coin is not enough,do you want to buy?"];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Tip"
                                                                message: message
                                                               delegate: self
                                                      cancelButtonTitle: @"Cancel"
                                                      otherButtonTitles: @"Buy",nil];
                alert.tag = 121;
                [alert show];
                [alert release];
            }
            else{
                
                [RCTool setRecordByType:RT_COIN value:(coin_num - price)];
                [RCTool setWorldStatus:0 type:self.type];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:COIN_CHANGED_NOTIFICATION object:nil];
                
                [self updateButton];
            }
            
        }
        
    }
    else if(121 == alertView.tag)
    {
        if(1 == buttonIndex)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:BUY_COIN_NOTIFICATION object:nil];
        }
    }
}

@end
