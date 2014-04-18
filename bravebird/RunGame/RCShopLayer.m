//
//  RCShopLayer.m
//  RunGame
//
//  Created by xuzepei on 4/14/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "RCShopLayer.h"
#import "RCMenuItemSprite.h"



@implementation RCShopLayer

- (id)init
{
    if(self = [super init])
    {
        self.isTouchEnabled = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buttonStatusChanged:) name:BUTTON_STATUS_CHANGE_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coinChanged:) name:COIN_CHANGED_NOTIFICATION object:nil];
        
        CGSize winSize = WIN_SIZE;
        ccColor4B bgColor = {0,0,0,200};
        CCLayerColor* bgColorLayer = [CCLayerColor layerWithColor:bgColor width:winSize.width height:winSize.height*5];
        [self addChild:bgColorLayer z:0];
        
        [RCTool addCacheFrame:@"images_block.plist"];
        
        _birdsArray = [[NSMutableArray alloc] init];
        _worldArray = [[NSMutableArray alloc] init];
        
        [self initBg];
        
        [self initButtons];
        
        [self initCoinLabel];
        
        [self initTab];
        
        [self initScrollLayer];
        
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[DIRECTOR touchDispatcher] removeDelegate:self];
    
    self.delegate = nil;
    self.coinLabel = nil;
    self.bgSprite = nil;
    
    self.birdMenuItem = nil;
    
    self.birdsArray = nil;
    self.worldArray = nil;
    
    [super dealloc];
}


- (void)initBg
{
    NSString* imageName = @"shop_bg.png";
    CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName];
    self.bgSprite = [CCSprite spriteWithSpriteFrame:spriteFrame];
    
    self.bgSprite.scale = 0.9;
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
        self.bgSprite.scale = 1.9;
    
    self.bgSprite.anchorPoint = ccp(0.5,1);
    if([RCTool isIphone5])
    {
        self.bgSprite.position = ccp(WIN_SIZE.width/2.0,WIN_SIZE.height - [RCTool getValueByHeightScale:80]);
    }
    else
    {
        self.bgSprite.position = ccp(WIN_SIZE.width/2.0,WIN_SIZE.height - [RCTool getValueByHeightScale:50]);
    }
    [self addChild:self.bgSprite z:0];
}

#pragma mark -  Buttons

- (void)initButtons
{
    CGSize winSize = WIN_SIZE;
    
    CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"buy_coin_button.png"];
    sprite.scale = 0.8;
    CGFloat offset_x = 26.0;
    CGFloat offset_y = 20.0;
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
    {
        sprite.scale = 1.8;
        offset_x = 40.0;
        offset_y = 60.0;
    }
    else if([RCTool isIpadMini])
    {
        offset_x = 60.0;
        offset_y = 40.0;
    }
    else if([RCTool isIphone5])
    {
        offset_x = 30.0;
        offset_y = 30.0;
    }
    
    CCMenuItemSprite* menuItem = [RCMenuItemSprite itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedBuyCoinButton:)];
    
    CCMenu* menu = [CCMenu menuWithItems:menuItem, nil];
    menu.anchorPoint = ccp(0.5,1);
    menu.position = ccp(offset_x, winSize.height - offset_y);
    [self addChild: menu z:50];

    sprite = [CCSprite spriteWithSpriteFrameName:@"close_button.png"];
    offset_x = 30.0;
    offset_y = 50.0;
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
    {
        sprite.scale = 1.8;
        offset_x = 110.0;
        offset_y = 110.0;
    }
    else if([RCTool isIpadMini])
    {
        offset_x = 110;
        offset_y = 110;
    }
    else if([RCTool isIphone5])
    {
        offset_y = 80.0;
    }
    
    menuItem = [RCMenuItemSprite itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedCloseButton:)];
    menu = [CCMenu menuWithItems:menuItem, nil];
    menu.anchorPoint = ccp(0,1);
    menu.position = ccp(winSize.width - offset_x, winSize.height - offset_y);
    [self addChild: menu z:50];
    
    BOOL b = [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_ads"];
    if(b)
    {
        return;
    }
    
    
    sprite = [CCSprite spriteWithSpriteFrameName:@"adblock.png"];
    sprite.scale = 0.7;
    offset_x = 36;
    offset_y = 30;
    
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
    {
        sprite.scale = 1.8;
        offset_x = 40;
        offset_y = 40.0;
    }
    else if([RCTool isIpadMini])
    {
        offset_x = 80;
        offset_y = 80;
    }
    else if([RCTool isIphone5])
    {
        offset_x = WIN_SIZE.width - 26.0;
        offset_y = 40.0;
    }
    
    menuItem = [RCMenuItemSprite itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedRemoveAdButton:)];
    menu = [CCMenu menuWithItems:menuItem, nil];
    menu.anchorPoint = ccp(0,1);
    menu.position = ccp(offset_x, offset_y);
    [self addChild: menu z:50];
    
}

- (void)clickedCloseButton:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickedResetButton:)])
    {
        [self.delegate clickedResetButton:nil];
        [RCTool showAd:YES];
        [self removeFromParentAndCleanup:YES];
    }
}

- (void)clickedBuyCoinButton:(id)sender
{
    NSLog(@"clickedBuyCoinButton");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BUY_COIN_NOTIFICATION object:nil];
}

- (void)clickedRemoveAdButton:(id)sender
{
    NSString* message = [NSString stringWithFormat:@"Do you want to cost %d coins for removing advertisement?",REMOVE_AD_NEED_COINS];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Tip"
                                                    message: message
                                                   delegate: self
                                          cancelButtonTitle: @"Cancel"
                                          otherButtonTitles: @"Ok",nil];
    alert.tag = 120;
    [alert show];
    [alert release];
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
            
            int price = REMOVE_AD_NEED_COINS;
            
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
                [[NSNotificationCenter defaultCenter] postNotificationName:COIN_CHANGED_NOTIFICATION object:nil];
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"remove_ads"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"REMOVE_ALL_ADS" object:nil];
                
                [RCTool showAlert:@"Tip" message:@"The advertisement has been removed."];
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

#pragma mark -  Coin Label

- (void)initCoinLabel
{
    int fontSize = 18;
    if([RCTool isIpad])
        fontSize = 27;

    self.coinLabel = [CCLabelTTF labelWithString:@"0 coin" fontName:@"Helvetica-Bold" fontSize:fontSize];
    self.coinLabel.anchorPoint = ccp(0,1);
    if([RCTool isIpadMini])
    {
        self.coinLabel.position = ccp(100,WIN_SIZE.height - 30);
    }
    else if([RCTool isIphone5])
    {
        self.coinLabel.position = ccp(50,WIN_SIZE.height - 24);
    }
    else{
        self.coinLabel.position = ccp([RCTool getValueByWidthScale:42],WIN_SIZE.height - [RCTool getValueByHeightScale:15]);
    }


    [self addChild:self.coinLabel];
    
    int count = MIN(999999999,[RCTool getRecordByType:RT_COIN]);
    if(0 == count)
        return;
    
    [self updateCoin:count];
}

- (void)updateCoin:(int64_t)count
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = kCFNumberFormatterDecimalStyle;
    NSString *string = [formatter stringFromNumber:[NSNumber numberWithLongLong:count]];
    [formatter release];
    
    
    if(self.coinLabel)
    {
        if(count > 1)
            [self.coinLabel setString:[NSString stringWithFormat:@"%@ coins",string]];
        else
            [self.coinLabel setString:[NSString stringWithFormat:@"%@ coin",string]];
    }
}

- (void)coinChanged:(NSNotification*)noti
{
    [self updateCoin:[RCTool getRecordByType:RT_COIN]];
}

#pragma mark -  Coin Label

- (void)initTab
{

    CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"select_bird_button_1.png"];
    sprite.scale = 0.8;
    self.birdMenuItem = [RCMenuItemSprite2 itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedBirdTabButton:)];
    
    CCMenu* menu = [CCMenu menuWithItems:self.birdMenuItem, nil];
    menu.anchorPoint = ccp(0,1);
    if([RCTool isIpadMini])
    {
        menu.position = ccp(self.bgSprite.contentSize.width/2.0 - (sprite.contentSize.width * sprite.scale)/2.0,self.bgSprite.contentSize.height - 60);
    }
    else{
    menu.position = ccp(self.bgSprite.contentSize.width/2.0 - (sprite.contentSize.width * sprite.scale)/2.0,self.bgSprite.contentSize.height - 30);
    }
    [self.bgSprite addChild: menu z:10];
    

    sprite = [CCSprite spriteWithSpriteFrameName:@"select_world_button_0.png"];
    sprite.scale = 0.8;
    self.worldMenuItem = [RCMenuItemSprite2 itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedWorldTabButton:)];
    menu = [CCMenu menuWithItems:self.worldMenuItem, nil];
    menu.anchorPoint = ccp(0,1);
    if([RCTool isIpadMini])
    {
        menu.position = ccp(self.bgSprite.contentSize.width/2.0 + (sprite.contentSize.width * sprite.scale)/2.0, self.bgSprite.contentSize.height - 60);
    }
    else{
    menu.position = ccp(self.bgSprite.contentSize.width/2.0 + (sprite.contentSize.width * sprite.scale)/2.0, self.bgSprite.contentSize.height - 30);
    }
    [self.bgSprite addChild: menu z:10];
}

- (void)clickedBirdTabButton:(id)sender
{
    NSLog(@"clickedBirdTabButton");
    
    if(0 == self.selected_tab_index)
        return;
    
    self.selected_tab_index = 0;

    CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"select_bird_button_1.png"];
    sprite.scale = 0.8;
    [self.birdMenuItem setNormalImage:sprite];
    
    CCSprite* sprite1 = [CCSprite spriteWithSpriteFrameName:@"select_world_button_0.png"];
    sprite1.scale = 0.8;
    [self.worldMenuItem setNormalImage:sprite1];
    
    for(RCShopWorldItem* item in _worldArray)
    {
        [item removeFromParentAndCleanup:NO];
    }
    
    for(RCShopBirdItem* item in _birdsArray)
    {
        [self.bgSprite addChild:item];
    }

}

- (void)clickedWorldTabButton:(id)sender
{
    NSLog(@"clickedWorldTabButton");
    
    if(1 == self.selected_tab_index)
        return;
    
    self.selected_tab_index = 1;
    
    CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"select_bird_button_0.png"];
    sprite.scale = 0.8;
    [self.birdMenuItem setNormalImage:sprite];
    
    CCSprite* sprite1 = [CCSprite spriteWithSpriteFrameName:@"select_world_button_1.png"];
    sprite1.scale = 0.8;
    [self.worldMenuItem setNormalImage:sprite1];
    
    for(RCShopBirdItem* item in _birdsArray)
    {
        [item removeFromParentAndCleanup:NO];
    }
    
    for(RCShopWorldItem* item in _worldArray)
    {
        [self.bgSprite addChild:item];
    }
}

#pragma mark - Scroll Layer

- (void)initScrollLayer
{
    for(int i = 0; i < BIRDS_NUM; i++) {
        
        CGFloat height = 80.0f;
        
        CGFloat width = self.bgSprite.contentSize.width*self.bgSprite.scale;
        if([RCTool isIpadMini])
        {
            height = 160.0f;
            width = self.bgSprite.contentSize.width - 10;
        }

        RCShopBirdItem* temp = [RCShopBirdItem layerWithColor:ccc4(255, 255, 255, 0) width:width height:height];
        temp.anchorPoint = ccp(0,1);
        temp.position = ccp(10, self.bgSprite.contentSize.height - i*height - 144);
        if([RCTool isIpadMini])
            temp.position = ccp(10, self.bgSprite.contentSize.height - i*height - 288);
        [temp initWithType:i];
        [self.bgSprite addChild:temp];
        
        [_birdsArray addObject:temp];
    }

    for(int i = 0; i < WORLD_NUM; i++) {
        
        CGFloat height = 80.0f;
        
        CGFloat width = self.bgSprite.contentSize.width*self.bgSprite.scale;
        if([RCTool isIpadMini])
        {
            height = 160.0f;
            width = self.bgSprite.contentSize.width - 10;
        }
        
        RCShopWorldItem* temp = [RCShopWorldItem layerWithColor:ccc4(255, 255, 255, 0) width:self.bgSprite.contentSize.width*self.bgSprite.scale height:height];
        temp.anchorPoint = ccp(0,1);
        temp.position = ccp(10, self.bgSprite.contentSize.height - i*height - 144);
        if([RCTool isIpadMini])
            temp.position = ccp(10, self.bgSprite.contentSize.height - i*height - 288);
        [temp initWithType:i];
        
        [_worldArray addObject:temp];
    }
}

- (void)buttonStatusChanged:(id)sender
{
    NSLog(@"buttonStatusChanged");
    
    for(RCShopBirdItem* temp in _birdsArray)
    {
        [temp updateButton];
    }
    
    for(RCShopWorldItem* temp in _worldArray)
    {
        [temp updateButton];
    }
}

#pragma mark - Touch Event

- (void)registerWithTouchDispatcher
{
    [[DIRECTOR touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
}

@end
