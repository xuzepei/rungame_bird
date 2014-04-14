//
//  RCGameSceneParallaxBackground.m
//  RunGame
//
//  Created by xuzepei on 9/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCGameSceneParallaxBackground.h"

#define SPRITE_TYPE 1

@implementation RCGameSceneParallaxBackground

- (id)init
{
    if(self = [super init])
    {
        
        _pipeArray = [[NSMutableArray alloc] init];
        

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameover:) name:GAMEOVER_NOTIFICATION object:nil];
        
        
//        CGSize winSize = WIN_SIZE;
//#ifndef DEBUG
//        ccColor4B bgColor = {133,232,255,255};
//        CCLayerColor* bgColorLayer = [CCLayerColor layerWithColor:bgColor width:winSize.width height:winSize.height*50];
//        bgColorLayer.anchorPoint = ccp(0.5,0);
//        [self addChild:bgColorLayer z:0];
//        
        CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"land_0.png"];
		self.batch = [CCSpriteBatchNode batchNodeWithTexture:spriteFrame.texture];
        [self addChild:self.batch];
        
        [self initBgObjects];
//#endif
        
        // Initialize the array that contains the scroll factors for individual stripes.
		_speedFactors = [[CCArray alloc] initWithCapacity:SPRITE_TYPE];
//		[_speedFactors addObject:[NSNumber numberWithFloat:0.1f]];
//		[_speedFactors addObject:[NSNumber numberWithFloat:0.2f]];
//		[_speedFactors addObject:[NSNumber numberWithFloat:0.3f]];
//		[_speedFactors addObject:[NSNumber numberWithFloat:0.5f]];
//		[_speedFactors addObject:[NSNumber numberWithFloat:0.7f]];
//		[_speedFactors addObject:[NSNumber numberWithFloat:1.0f]];
		[_speedFactors addObject:[NSNumber numberWithFloat:1.0f]];
		NSAssert([_speedFactors count] == SPRITE_TYPE, @"speedFactors count does not match numStripes!");
        
		_scrollSpeed = SCROLL_SPEED;
        if([RCTool isIpad])
            _scrollSpeed *= 2.0;
		[self scheduleUpdate];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.batch = nil;
    self.speedFactors = nil;
    self.pipeArray = nil;
    
    [super dealloc];
}

- (void)update:(ccTime)delta
{
    CGSize winSize = WIN_SIZE;
	CCSprite* sprite;
	CCARRAY_FOREACH([self.batch children], sprite)
	{
		//NSNumber* factor = [_speedFactors objectAtIndex:sprite.zOrder];

		CGPoint pos = sprite.position;
		pos.x -= _scrollSpeed;
		
        // Reposition stripes when they're out of bounds
		if(pos.x < -winSize.width)
		{
            if([sprite isKindOfClass:[RCPipe class]])
            {
                [self rearrangePipe:(RCPipe*)sprite];
                continue;
            }
            else
                pos.x += (winSize.width * 2) - 2;
		}

        sprite.position = pos;
	}
}

- (void)initBgObjects
{
    [self.batch removeAllChildrenWithCleanup:YES];
    
    CGSize winSize = WIN_SIZE;
    
    int i = 0;
    NSString* frameName = [NSString stringWithFormat:@"land_%d.png",[RCTool randomByType:RDM_LAND]];
    CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    
    [RCTool resizeSprite:sprite toWidth:WIN_SIZE.width+2 toHeight:[RCTool getValueByHeightScale:80]];
    
    sprite.anchorPoint = CGPointMake(0, 0);
    sprite.position = CGPointMake(0,0);
    [self.batch addChild:sprite z:10 tag:i];
    
    sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    
    [RCTool resizeSprite:sprite toWidth:WIN_SIZE.width+2 toHeight:[RCTool getValueByHeightScale:80]];
    
    sprite.anchorPoint = CGPointMake(0,0);
    sprite.position = ccp(winSize.width,0);
    [self.batch addChild:sprite z:10 tag:i+SPRITE_TYPE];
    i++;
}

- (void)gameover:(NSNotification*)notification
{
    _scrollSpeed = 0.0;
}

- (void)addPipe:(RCPipe*)pipe
{
    if(nil == pipe)
        return;
    
    [_pipeArray addObject:pipe];
    [self.batch addChild:pipe z:2];
}

- (void)rearrangePipe:(RCPipe*)pipe
{
    CGFloat offset_x = 0;
    for(RCPipe* temp in _pipeArray)
    {
        offset_x = MAX(temp.position.x,offset_x);
    }
    
    if([RCTool isIpadMini])
    {
        offset_x += pipe.contentSize.width + PIPE_INTERVAL_IPAD_MINI;
    }
    else
    {
        offset_x += [RCTool getValueByWidthScale:pipe.contentSize.width + PIPE_INTERVAL];
    }
    
    CGFloat random_height = WIN_SIZE.height - [RCTool getValueByHeightScale:PIPE_MIN_HEIGHT*2] - MAX(PIPE_TOPBOTTOM_INTERVAL, [RCTool getValueByHeightScale:PIPE_TOPBOTTOM_INTERVAL]) - [RCTool getValueByHeightScale:FLOOR_HEIGHT];
    if([RCTool isIpadMini])
    {
        random_height = WIN_SIZE.height - PIPE_MIN_HEIGHT_IPAD_MINI*2 - PIPE_TOPBOTTOM_INTERVAL_IPAD_MINI - FLOOR_HEIGHT_IPAD_MINI;
    }
    
    random_height = [RCTool randFloat:random_height min:0];
    
    if([RCTool isIpadMini])
    {
        random_height += PIPE_MIN_HEIGHT_IPAD_MINI + FLOOR_HEIGHT_IPAD_MINI;
    }
    else{
        random_height += [RCTool getValueByHeightScale:PIPE_MIN_HEIGHT + FLOOR_HEIGHT];
    }
    
    BOOL isRotated = NO;
    BOOL isAngry = [RCTool isAngry];
    //        if(NO == isAngry)
    //        {
    //            int score = [RCTool getRecordByType:RT_SCORE];
    //            if(score >= 20)
    //            {
    //                isRotated = [RCTool isRotated];
    //            }
    //        }
    
    if([pipe isBottom])//下方管道
    {
        CGFloat offset_y = random_height - [RCTool getValueByHeightScale:pipe.contentSize.height];
        if([RCTool isIpadMini])
        {
            offset_y = random_height - pipe.contentSize.height;
        }
        pipe.position = ccp(offset_x,offset_y);
        pipe.isPassed = NO; //重新设置为未通过
        [pipe setAction:isAngry isRotated:isRotated];
        
        RCPipe* top_pipe = (RCPipe*)[self.batch getChildByTag:pipe.tag+1];//根据tag查找到对应的上方管道
        
        if(top_pipe && [top_pipe isKindOfClass:[RCPipe class]])
        {
            CGFloat offset_y = random_height + MAX(PIPE_TOPBOTTOM_INTERVAL,[RCTool getValueByHeightScale:PIPE_TOPBOTTOM_INTERVAL]);
            if([RCTool isIpadMini])
            {
                offset_y = random_height + PIPE_TOPBOTTOM_INTERVAL_IPAD_MINI;
            }
            
            top_pipe.position = ccp(offset_x,offset_y);
            
            [top_pipe setAction:isAngry isRotated:isRotated];
        }
        
        //NSLog(@"pipe.tag:%d,coin.tag:%d",pipe.tag,T_COIN_0 + (pipe.tag - T_PIPE_0)/2);
        RCCoin* coin = (RCCoin*)[self.batch getChildByTag:T_COIN_0 + (pipe.tag - T_PIPE_0)/2];
        if(coin && [coin isKindOfClass:[RCCoin class]])
        {
            CGFloat offset_y = random_height + MAX(PIPE_TOPBOTTOM_INTERVAL,[RCTool getValueByHeightScale:PIPE_TOPBOTTOM_INTERVAL])/2.0;
            if([RCTool isIpadMini])
            {
                offset_y = random_height + PIPE_TOPBOTTOM_INTERVAL_IPAD_MINI/2.0;
            }
            
            coin.position = ccp(offset_x,offset_y);
            if(isAngry || isRotated)
                [coin setVisible:NO];
            else
                [coin setVisible:YES];
        }
    }
}

@end
