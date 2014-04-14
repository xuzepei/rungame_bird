//
//  RCMatchGameBackground.m
//  RunGame
//
//  Created by xuzepei on 3/12/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "RCMatchGameBackground.h"

#define SPRITE_TYPE 1

@implementation RCMatchGameBackground

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
        if([RCTool isIpad] && NO == [RCTool isIpadMini])
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
    self.gameScene = nil;
    
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
    NSString* frameName = @"land_0.png";
    CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    
    [RCTool resizeSprite:sprite toWidth:WIN_SIZE.width+1 toHeight:[RCTool getValueByHeightScale:80]];
    
    sprite.anchorPoint = CGPointMake(0, 0);
    sprite.position = CGPointMake(0,0);
    [self.batch addChild:sprite z:10 tag:i];
    
    sprite = [CCSprite spriteWithSpriteFrameName:frameName];
    
    [RCTool resizeSprite:sprite toWidth:WIN_SIZE.width+1 toHeight:[RCTool getValueByHeightScale:80]];
    
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

- (void)addLabel:(CCLabelTTF*)label
{
    if(nil == label)
        return;

    [self.batch addChild:label z:2];
}

- (void)rearrangePipe:(RCPipe*)pipe
{
    CGFloat offset_x = 0;
    for(RCPipe* temp in _pipeArray)
    {
        offset_x = MAX(temp.position.x,offset_x);
    }
    offset_x += [RCTool getValueByWidthScale:pipe.contentSize.width + PIPE_INTERVAL];
    
    int index = pipe.tag;
    index += 4;
    if(index < [self.gameScene.pipePositions count])
    {
        CGFloat random_height = [[self.gameScene.pipePositions objectAtIndex:index] floatValue];
        random_height = [RCTool getValueByHeightScale:random_height];
        random_height += [RCTool getValueByHeightScale:PIPE_MIN_HEIGHT + FLOOR_HEIGHT];
        
        if([pipe isBottom])//下方管道
        {
            CGFloat offset_y = random_height - [RCTool getValueByHeightScale:pipe.contentSize.height];
            pipe.position = ccp(offset_x,offset_y);
            pipe.isPassed = NO; //重新设置为未通过
            
            RCPipe* top_pipe = (RCPipe*)[self.batch getChildByTag:pipe.tag+1];//根据tag查找到对应的上方管道
            
            if(top_pipe && [top_pipe isKindOfClass:[RCPipe class]])
            {
                CGFloat offset_y = random_height + MAX(PIPE_TOPBOTTOM_INTERVAL,[RCTool getValueByHeightScale:PIPE_TOPBOTTOM_INTERVAL]);
                top_pipe.position = ccp(offset_x,offset_y);
            }
        }
    }
    

}

@end
