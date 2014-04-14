//
//  RCHomeScene.m
//  BeatMole
//
//  Created by xuzepei on 5/28/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCHomeScene.h"
#import "RCGameScene.h"
#import "RCGameSceneParallaxBackground.h"
#import "CCAnimation+Helper.h"
#import "RCMenuItemSprite.h"
#import "RCMatchGameScene.h"
#import "RCNavigationController.h"
#import "AppDelegate.h"



static RCHomeScene* sharedInstance = nil;
@implementation RCHomeScene

+ (id)scene
{
    CCScene* scene = [CCScene node];
    RCHomeScene* layer = [RCHomeScene node];
    [scene addChild:layer];
    return scene;
}

+ (RCHomeScene*)sharedInstance
{
    return sharedInstance;
}

- (id)init
{
    if(self = [super init])
    {
        sharedInstance = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyScore:) name:MYSCORE_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startMatch:) name:STARTMATCH_NOTIFICATION object:nil];
        
        //[RCTool getRootNavigationController].topViewController.canDisplayBannerAds = YES;
        
        [RCTool addCacheFrame:@"images_block.plist"];

        [self initParallaxBackground];
        
        [self initButtons];
        
        [self initRank];
        
        [self initTitle];
        
        [self initDuck];
        
        [self initMedal];
        
        [self initCoin];
        
        [RCTool preloadEffectSound:MUSIC_SWOOSH];
        
        [self schedule:@selector(showAd:) interval:2.0];
        
        [self updatePlayerInfo];
        


    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [RCTool removeCacheFrame:@"images_block.plist"];
    
    self.bgSprite = nil;
    self.startButton = nil;
    self.scoreButton = nil;
    self.rateButton = nil;
    self.leaderboardButton = nil;
    self.shopButton = nil;
    self.settingsButton = nil;
    self.duckSprite = nil;
    self.titleSprite = nil;
    self.medalSprite = nil;
    self.coinSprite = nil;
    self.coinLabel = nil;
    
    self.rankSprite = nil;
    
    sharedInstance = nil;
    

    
    [super dealloc];
}

- (void)showAd:(ccTime)dt
{
    [RCTool showAd:YES];
}

- (void)initButtons
{
    CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"start_button.png"];
    CCMenuItemSprite* menuItem = [RCMenuItemSprite itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedStartButton:)];
    
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
        menuItem.scale = 1.8;
    menuItem.tag = T_HOMEMENU_START;
    self.startButton = [CCMenu menuWithItems:menuItem,nil];
    self.startButton.position = ccp(WIN_SIZE.width/2.0 + [RCTool getValueByWidthScale:-70], [RCTool getValueByHeightScale:109]);
    [self addChild:self.startButton z:10];
    

    sprite = [CCSprite spriteWithSpriteFrameName:@"score_button.png"];
    menuItem = [RCMenuItemSprite itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedScoreButton:)];
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
        menuItem.scale = 1.8;
    self.scoreButton = [CCMenu menuWithItems:menuItem,nil];
    
    self.scoreButton.position = ccp(WIN_SIZE.width/2.0 + [RCTool getValueByWidthScale:70], [RCTool getValueByHeightScale:109]);
    [self addChild:self.scoreButton z:10];
    
    {
        sprite = [CCSprite spriteWithSpriteFrameName:@"rate_button.png"];
        menuItem = [RCMenuItemSprite itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedRemoveAdButton:)];
        if([RCTool isIpad] && NO == [RCTool isIpadMini])
            menuItem.scale = 1.8;
        self.rateButton = [CCMenu menuWithItems:menuItem,nil];
        self.rateButton.position = ccp(WIN_SIZE.width/2, [RCTool getValueByHeightScale:176]);
        
        [self addChild:self.rateButton z:10];
    }

}


- (void)clickedStartButton:(id)sender
{
    //[RCTool getRootNavigationController].topViewController.canDisplayBannerAds = NO;
    
    [RCTool sendStatisticInfo:PLAY_EVENT];
    
    [self unschedule:@selector(showAd:)];
    [RCTool showAd:NO];
    
    [RCTool addPlayTimes];
    
    CCLOG(@"clickedStartButton");
    [RCTool playEffectSound:MUSIC_SWOOSH];
    
    CCScene* scene = [RCGameScene scene];
    [DIRECTOR replaceScene:[CCTransitionFade transitionWithDuration:0.3 scene:scene withColor:ccWHITE]];
}

- (void)clickedScoreButton:(id)sender
{
    [RCTool sendStatisticInfo:SCORE_EVENT];
    
    CCLOG(@"clickedScoreButton");
    [RCTool playEffectSound:MUSIC_SWOOSH];

    //[self showLeaderboard];
    [self showGameCenter];
}

- (void)clickedRemoveAdButton:(id)sender
{
//    [RCTool sendStatisticInfo:RANK_EVENT];
//
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_URL]];

//    [[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:(UIViewController*)[RCTool getRootNavigationController] delegate:[RCTool getAppDelegate]];
    
    
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@"Remove Advertisement"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"Purchase",@"Restore Previous Purchase",nil]autorelease];
    actionSheet.delegate = self;
    actionSheet.tag = PURCHASE_TAG;
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    if([RCTool isIpad])
        [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet showInView:[RCTool getRootNavigationController].topViewController.view];
}

- (void)clickedRankButton:(id)sender
{
    [RCTool sendStatisticInfo:RANK_EVENT];
    
    //[self showGameCenter];
    [self showLeaderboard];
}

- (void)clickedShopButton:(id)sender
{
    //[self showAllButton:NO];
    
//    RCStoreLayer* layer = [[[RCStoreLayer alloc] init] autorelease];
//    layer.delegate = self;
//    [self addChild:layer z:100];
}

- (void)clickedHelpButton:(id)sender
{
}

- (void)clickedSettingButton:(id)sender
{
//    RCSettingsViewController* temp = [[RCSettingsViewController alloc] initWithNibName:nil bundle:nil];
//    
//    [[RCTool getRootNavigationController] pushViewController:temp animated:YES];
//    [temp release];
//    [DIRECTOR pause];
}

- (void)clickedMatchButton:(id)sender
{
    //[RCTool getRootNavigationController].topViewController.canDisplayBannerAds = NO;
    
    [RCTool sendStatisticInfo:FIND_MATCH_EVENT];
    
    [[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:(UIViewController*)[RCTool getRootNavigationController] delegate:[RCTool getAppDelegate]];
}

#pragma mark - GameCenter

- (void)updatePlayerInfo
{
    if(NO == [GCHelper sharedInstance].userAuthenticated)
    {
        return;
    }
    
    [[GCHelper sharedInstance] getPlayerInfo];
}

- (void)showGameCenter
{
    if(NO == [GCHelper sharedInstance].userAuthenticated)
    {
        [RCTool showAlert:@"Hint" message:@"Need sign in Game Center first!"];
        return;
    }
    
    GKGameCenterViewController *gameCenterController = [[[GKGameCenterViewController alloc] init] autorelease];
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = self;
        //gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
        [[RCTool getRootNavigationController] presentViewController: gameCenterController animated: YES
                         completion:nil];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController
                                           *)gameCenterViewController
{
    [[RCTool getRootNavigationController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)showLeaderboard
{
    if(NO == [GCHelper sharedInstance].userAuthenticated)
    {
        //[[GCHelper sharedInstance] authenticateLocalUser];
        
        [RCTool showAlert:@"Hint" message:@"Need sign in Game Center first!"];
        return;
    }
    
	GKLeaderboardViewController* leaderboardController = [[[GKLeaderboardViewController alloc] init] autorelease];
	if(leaderboardController != NULL)
	{
		leaderboardController.category = LEADERBOARD_SCORES_ID;
		leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardController.leaderboardDelegate = self;
        [[RCTool getRootNavigationController] presentViewController:leaderboardController animated:YES completion:^{}];
	}
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[[RCTool getRootNavigationController] dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)updateMyScore:(NSNotification*)notification
{
    if([GCHelper sharedInstance].myScore)
    {
        if(self.rankSprite)
        {
            [self.rankSprite updateRank:[GCHelper sharedInstance].myScore.rank];
            [self.rankSprite move];
        }
    }
}

#pragma mark - Parallax Background

- (void)initParallaxBackground
{
    //设置背景
    NSString* imageName = [NSString stringWithFormat:@"bg_%d.png",[RCTool randomByType:RDM_BG]];
    CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName];
    CCSprite* bgSprite = [CCSprite spriteWithSpriteFrame:spriteFrame];

    [RCTool resizeSprite:bgSprite toWidth:WIN_SIZE.width toHeight:WIN_SIZE.height];

    bgSprite.anchorPoint = ccp(0,0);
    bgSprite.position = ccp(0,0);
    [self addChild:bgSprite z:0];
    
    RCGameSceneParallaxBackground* parallaxBg = [RCGameSceneParallaxBackground node];
    [self addChild:parallaxBg z:1];
}


#pragma mark - Store

- (void)showAllButton:(BOOL)b
{
    [self.bgSprite setVisible:b];
    [self.startButton setVisible:b];
    [self.scoreButton setVisible:b];
    //[self.rateButton setVisible:b];
    [self.leaderboardButton setVisible:b];
    [self.shopButton setVisible:b];
    [self.settingsButton setVisible:b];
}

- (void)clickedStoreBackButton:(id)sender
{
    [self showAllButton:YES];
}

- (void)clickedAchievementBackButton:(id)sender
{
    [self showAllButton:YES];
}

#pragma mark - Duck

- (void)initDuck
{
    NSArray* indexArray = [NSArray arrayWithObjects:@"0",@"1",@"2",nil];
    NSString* frameName = [NSString stringWithFormat:@"fly_0_"];
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
        frameName = [NSString stringWithFormat:@"hd_fly_0_"];
    CCAnimation* flyAnimation = [CCAnimation animationWithFrame:frameName indexArray:indexArray delay:0.15];
    
    NSString* imageName = @"fly_0_0.png";
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
        imageName = @"hd_fly_0_0.png";
    self.duckSprite = [CCSprite spriteWithSpriteFrameName:imageName];
    self.duckSprite.position = ccp(WIN_SIZE.width/2.0, WIN_SIZE.height - [RCTool getValueByHeightScale:250]);
    [self addChild:self.duckSprite z:20];
    
    id fly = [CCAnimate actionWithAnimation:flyAnimation];
    id moveUp = [CCMoveBy actionWithDuration:0.8 position:ccp(0,[RCTool getValueByHeightScale:10])];
    id moveDown = [CCMoveBy actionWithDuration:0.8 position:ccp(0,[RCTool getValueByHeightScale:-10])];
//    id action = [CCRotateBy actionWithDuration:0.8 angle: 720];
    id sequence = [CCSequence actions:moveUp,moveDown,nil];
    
    CCRepeatForever* repeat1 = [CCRepeatForever actionWithAction:sequence];
    CCRepeatForever* repeat2 = [CCRepeatForever actionWithAction:fly];
    [self.duckSprite runAction:repeat1];
    [self.duckSprite runAction:repeat2];
}

#pragma mark - Title

- (void)initTitle
{
    self.titleSprite = [CCSprite spriteWithSpriteFrameName:@"title.png"];
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
        self.titleSprite.scale = 1.8;
    self.titleSprite.position = ccp(WIN_SIZE.width/2.0, WIN_SIZE.height - [RCTool getValueByHeightScale:170]);
    [self addChild:self.titleSprite z:20];
    
    id moveUp = [CCMoveBy actionWithDuration:0.8 position:ccp(0,[RCTool getValueByHeightScale:10])];
    id moveDown = [CCMoveBy actionWithDuration:0.8 position:ccp(0,[RCTool getValueByHeightScale:-10])];
    id sequence = [CCSequence actions:moveUp,moveDown,nil];
    id repeat = [CCRepeatForever actionWithAction:sequence];
    [self.titleSprite runAction:repeat];
}

#pragma mark - Medal

- (void)initMedal
{
    NSString* medalImageName = nil;
    int score = [RCTool getRecordByType:RT_BEST];
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
        self.medalSprite.scale = 1.6;
        if([RCTool isIpad] && NO == [RCTool isIpadMini])
            self.medalSprite.scale *= 1.8;
        self.medalSprite.position = ccp(WIN_SIZE.width - [RCTool getValueByWidthScale:50], WIN_SIZE.height - [RCTool getValueByHeightScale:95]);
        [self addChild:self.medalSprite z:20];
        
        id moveUp = [CCMoveBy actionWithDuration:0.8 position:ccp(0,[RCTool getValueByHeightScale:10])];
        id moveDown = [CCMoveBy actionWithDuration:0.8 position:ccp(0,[RCTool getValueByHeightScale:-10])];
        id sequence = [CCSequence actions:moveUp,moveDown,nil];
        id repeat = [CCRepeatForever actionWithAction:sequence];
        [self.medalSprite runAction:repeat];

    }
}

#pragma mark - Coin

- (void)initCoin
{
    int count = MIN(999999999,[RCTool getRecordByType:RT_COIN]);
    if(0 == count)
        return;
    
    self.coinSprite = [RCCoin coin];
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
        self.coinSprite.scale = 1.6;
    else
        self.coinSprite.scale = 0.8;
    //[self.coinSprite rotate];
    self.coinSprite.position = ccp([RCTool getValueByHeightScale:26], WIN_SIZE.height - [RCTool getValueByHeightScale:76]);
    [self addChild:self.coinSprite z:20];
    
    CGFloat fact = 2.0f;
    if([RCTool isIpadMini])
        fact = 1.0f;
    self.coinLabel = [[[RCLabelAtlas alloc] initWithString:@"0" charMapFile:@"small_number.png" itemWidth:32/fact itemHeight:40/fact startCharMap:'0'] autorelease];
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
        self.coinLabel.scale = 1.6;
    else
        self.coinLabel.scale = 0.8;
    
    self.coinLabel.anchorPoint = ccp(0, 0.5);
    self.coinLabel.position = ccp([RCTool getValueByHeightScale:46], WIN_SIZE.height - [RCTool getValueByHeightScale:77]);
    [self addChild:self.coinLabel z:20];
    [self.coinLabel setString:[NSString stringWithFormat:@"%d",count]];
}

#pragma mark - Rank

- (void)initRank
{
    if(nil == _rankSprite)
    {
        self.rankSprite = [RCRank spriteWithSpriteFrameName:@"game_center.png"];
        self.rankSprite.delegate = self;
        
        if([RCTool isIpad] && NO == [RCTool isIpadMini])
        self.rankSprite.scale = 1.18;
            else
        self.rankSprite.scale = 0.55;
        self.rankSprite.anchorPoint = ccp(0.5,0.5);
    }
    
    self.rankSprite.position = ccp(WIN_SIZE.width + [RCTool getValueByWidthScale: self.rankSprite.contentSize.width/2.0], WIN_SIZE.height - [RCTool getValueByHeightScale:110]);
    //ccp(WIN_SIZE.width + [RCTool getValueByWidthScale: self.rankSprite.contentSize.width/2.0], [RCTool getValueByHeightScale:250]);
    [self addChild:self.rankSprite z:10];
    
    [self updateMyScore:nil];
}

#pragma mark Match

- (void)startMatch:(NSNotification*)notification
{
    [RCTool sendStatisticInfo:START_MATCH_EVENT];
    
    [self unschedule:@selector(showAd:)];
    [RCTool showAd:NO];
    
    CCLOG(@"startMatch");
    [RCTool playEffectSound:MUSIC_SWOOSH];
    
    CCScene* scene = [RCMatchGameScene scene];
    [DIRECTOR replaceScene:[CCTransitionFade transitionWithDuration:0.3 scene:scene withColor:ccWHITE]];
}

#pragma mark - In App Purchase

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex:%d",buttonIndex);
    
    if(PURCHASE_TAG == actionSheet.tag)
    {
        if(0 == buttonIndex)
        {
            AppController* appDelegate =(AppController*)[UIApplication sharedApplication].delegate;
            [appDelegate buyProduct];
        }
        else if(1 == buttonIndex)
        {
            AppController* appDelegate =(AppController*)[UIApplication sharedApplication].delegate;
            [appDelegate restoreProduct];
        }
    }
}




@end