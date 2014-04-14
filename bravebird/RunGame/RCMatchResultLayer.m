//
//  RCMatchResultLayer.m
//  RunGame
//
//  Created by xuzepei on 3/12/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "RCMatchResultLayer.h"
#import "CCAnimation+Helper.h"
#import "RCNavigationController.h"


@implementation RCMatchResultLayer

- (id)init:(BOOL)isWinned
{
    if(self = [super init])
    {
        self.isWinned = isWinned;
        
        [RCTool addCacheFrame:@"images_block.plist"];
        
        [self initBg];
        
        //[self initLabels];
        
        [self initButtons];
        
        [self showStar];
        
        
    }
    
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    self.scoreLabel = nil;
    self.bestLabel = nil;
    self.overSprite = nil;
    self.scoreBoard = nil;
    self.medalSprite = nil;
    self.newSprite = nil;
    
    [super dealloc];
}

- (void)initBg
{
    NSString* imageName = @"win.png";
    if(NO == self.isWinned)
        imageName = @"lose.png";
    
    self.overSprite = [CCSprite spriteWithSpriteFrameName:imageName];
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
        self.overSprite.scale = 2.2;
    self.overSprite.position = ccp(WIN_SIZE.width/2.0, WIN_SIZE.height/2.0 + [RCTool getValueByHeightScale:150]);
    [self addChild:self.overSprite z:10];
    
//    self.scoreBoard = [CCSprite spriteWithSpriteFrameName:@"score_board.png"];
//    if([RCTool isIpad])
//        self.scoreBoard.scale = 1.9;
//    self.scoreBoard.position = ccp(WIN_SIZE.width/2.0, WIN_SIZE.height/2.0 + [RCTool getValueByHeightScale:30]);
//    [self addChild:self.scoreBoard z:10];
}

- (void)initLabels
{
    int score = [RCTool getRecordByType:RT_SCORE];
    
    self.scoreLabel = [[[RCLabelAtlas alloc] initWithString:@"0" charMapFile:@"small_number.png" itemWidth:32/2.0 itemHeight:40/2.0 startCharMap:'0'] autorelease];
    self.scoreLabel.anchorPoint = ccp(1, 0.5);
    self.scoreLabel.position = ccp(454/2.0, 158/2.0);
    [self.scoreBoard addChild:self.scoreLabel];
    [self.scoreLabel rollToNumber:score];
    
    self.bestLabel = [[[RCLabelAtlas alloc] initWithString:@"0" charMapFile:@"small_number.png" itemWidth:32/2.0 itemHeight:40/2.0 startCharMap:'0'] autorelease];
    self.bestLabel.anchorPoint = ccp(1, 0.5);
    self.bestLabel.position = ccp(454/2.0, 66/2.0);
    [self.scoreBoard addChild:self.bestLabel];
    [self.bestLabel setString:[NSString stringWithFormat:@"%d",[RCTool getRecordByType:RT_BEST]]];
    
    NSString* medalImageName = nil;
    if(score >= 40)
        medalImageName = @"platinum_medal.png";
    else if(score >= 30)
        medalImageName = @"gold_medal.png";
    else if(score >= 20)
        medalImageName = @"silver_medal.png";
    else if(score >= 10)
        medalImageName = @"bronze_medal.png";
    
    if([medalImageName length])
    {
        self.medalSprite = [CCSprite spriteWithSpriteFrameName:medalImageName];
        self.medalSprite.scale = 2.2;
        self.medalSprite.position = ccp(106/2.0, 116/2.0);
        [self.scoreBoard addChild:self.medalSprite z:10];
    }
}

- (void)initButtons
{
    //CGSize winSize = WIN_SIZE;
    
    CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"ok_button.png"];
    CCMenuItemSprite* menuItem = [RCMenuItemSprite itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedBackButton:)];
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
        menuItem.scale = 1.8;
    CCMenu* okButton = [CCMenu menuWithItems:menuItem,nil];
    okButton.position = ccp(WIN_SIZE.width/2.0 + [RCTool getValueByWidthScale:-70], [RCTool getValueByHeightScale:200]);
    [self addChild:okButton z:10];
    
    sprite = [CCSprite spriteWithSpriteFrameName:@"share_button.png"];
    menuItem = [RCMenuItemSprite itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedShareButton:)];
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
        menuItem.scale = 1.8;
    CCMenu*shareButton = [CCMenu menuWithItems:menuItem,nil];
    shareButton.position = ccp(WIN_SIZE.width/2.0 + [RCTool getValueByWidthScale:70], [RCTool getValueByHeightScale:200]);
    [self addChild:shareButton z:10];
}

- (void)clickedBackButton:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickedBackButton:)])
    {
        int playTimes = [RCTool getPlayTimes];
        if(playTimes && 0 == playTimes % 5)
            [RCTool showInterstitialAd];
        else
            [RCTool showAd:YES];
        
        [self.delegate clickedBackButton:nil];
        [self removeFromParentAndCleanup:YES];
    }
}

- (void)clickedShareButton:(id)sender
{
    [RCTool sendStatisticInfo:SHARE_EVENT];
    
    NSMutableArray* itemsToShare = [[[NSMutableArray alloc] init] autorelease];
    
    NSArray* excludedActivityTypes;
    if([RCTool systemVersion] >= 7.0)
    {
        excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeAssignToContact,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList];
    }
    else{
        excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeAssignToContact,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll];
    }
    
    UIImage* screen = [self copyScreen];
    if(screen)
        [itemsToShare addObject:screen];
    
    NSString* text = [NSString stringWithFormat:@"%@ \r\n\r\n%@",@"I'm playing with Brave Bird 2 ~ Flap Again!",APP_URL];
    if([text length])
        [itemsToShare addObject:text];
    
    UIActivityViewController *activityViewController = [[[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil] autorelease];
    activityViewController.excludedActivityTypes = excludedActivityTypes;
    [[RCTool getRootNavigationController] presentViewController:activityViewController animated:YES completion:^{
    }];
}

- (void)showNew
{
    self.isNew = YES;
    self.newSprite = [CCSprite spriteWithSpriteFrameName:@"new.png"];
    self.newSprite.scale = 2;
    self.newSprite.position = ccp(332/2.0, 113/2.0);
    [self.scoreBoard addChild:self.newSprite z:10];
}

- (void)showStar
{
    int score = [RCTool getRecordByType:RT_SCORE];
    if(score < 10)
        return;
    
    self.starSprite = [CCSprite spriteWithSpriteFrameName:@"star_0.png"];
    self.starSprite.scale = 2;
    [self.scoreBoard addChild:self.starSprite z:10];
    
    [self blinkDone:nil];
}

- (void)blinkDone:(id)sender
{
    CGFloat width = [RCTool randFloat:80 min:20];
    CGFloat height = [RCTool randFloat:86 min:26];
    self.starSprite.position = ccp(width,height);
    
    NSArray* indexArray = [NSArray arrayWithObjects:@"0",@"1",@"2",@"2",@"1",@"0",nil];
    NSString* frameName = [NSString stringWithFormat:@"star_"];
    CCAnimation* blinkAnimation = [CCAnimation animationWithFrame:frameName indexArray:indexArray delay:0.1];
    id blink = [CCAnimate actionWithAnimation:blinkAnimation];
    CCCallFunc *done = [CCCallFuncN actionWithTarget:self selector:@selector(blinkDone:)];
    id sequence = [CCSequence actions:blink,done,nil];
    
    [self.starSprite runAction:sequence];
}

- (UIImage*)copyScreen
{
    CCScene*scene = [[CCDirector sharedDirector] runningScene];
    CCNode *n = [scene.children objectAtIndex:0];
    return [RCTool screenshotWithStartNode:n];
}


@end
