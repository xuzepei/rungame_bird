//
//  RCPipe.m
//  RunGame
//
//  Created by xuzepei on 2/7/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "RCPipe.h"


@implementation RCPipe

+ (id)pipe:(int)type
{
	return [[[self alloc] initWithType:type] autorelease];
}

- (id)initWithType:(int)type
{
    NSString* imageName = [NSString stringWithFormat:@"pipe_%d.png",type];
	if((self = [super initWithSpriteFrameName:imageName]))
	{
        self.type = type;
        self.up = NO;
        self.right = NO;
        
        [self scheduleUpdate];
	}
	return self;
}

- (void)setImageByImagePath:(NSString*)imagePath
{
    if(0 == [imagePath length])
        return;
    
    CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage:imagePath];
    [self setTexture:texture];
}

- (void)setImageBySpriteFrameName:(NSString*)frameName
{
    if(0 == [frameName length])
        return;
    
    CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCSpriteFrame* frame = [cache spriteFrameByName:frameName];
    [self setDisplayFrame:frame];
}

- (void)dealloc
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self unscheduleUpdate];
    
    self.bottomPipe = nil;
    
    [super dealloc];
}

- (CGRect)frame
{
    CGFloat width = 0.0f;
    CGFloat height = 0.0f;
    
    if([RCTool isIpadMini])
    {
        width = self.contentSize.width;
        height = self.contentSize.height;
    }
    else
    {
        width = [RCTool getHeightScale]*self.contentSize.width;
        height = [RCTool getHeightScale]*self.contentSize.height;
    }
    
    return CGRectMake(self.position.x - width/2.0, self.position.y, width, height);
}

- (void)update:(ccTime)delta
{
    if(self.isAngry)
    {
        CGPoint pos = self.position;
        CGFloat value = 0.5;
        if([RCTool isIpad] && NO == [RCTool isIpadMini])
            value = 0.9;

        if([self isBottom])
        {
            if(self.up)
                self.position = ccp(pos.x,pos.y+value);
            else
                self.position = ccp(pos.x,pos.y-value);
        }
        else
        {
            if(pos.y >= WIN_SIZE.height - [RCTool getValueByHeightScale:PIPE_MIN_HEIGHT])
            {
                self.up = NO;
                self.bottomPipe.up = NO;
            }
            else if(pos.y <= [RCTool getValueByHeightScale:PIPE_MIN_HEIGHT + FLOOR_HEIGHT + PIPE_TOPBOTTOM_INTERVAL])
            {
                self.up = YES;
                self.bottomPipe.up = YES;
            }
            
            if(self.up)
                self.position = ccp(pos.x,pos.y+value);
            else
                self.position = ccp(pos.x,pos.y-value);
        }
    }
    else if(self.isRotated)
    {
        if([self isBottom])
        {
            if(self.right)
                self.rotation -= 0.1;
            else
                self.rotation += 0.1;
        }
        else
        {
            if(self.rotation <= -5)
            {
                self.right = NO;
                self.bottomPipe.right = NO;
            }
            else if(self.rotation >= 5)
            {
                self.right = YES;
                self.bottomPipe.right = YES;
            }
            
            if(self.right)
                self.rotation -= 0.1;
            else
                self.rotation += 0.1;
        }

    }
}

- (BOOL)isBottom
{
    return self.flipY;
}

- (void)setAction:(BOOL)isAngry isRotated:(BOOL)isRotated
{
    self.isAngry = isAngry;
//    self.isRotated = isRotated;
    
//    if(NO == self.isRotated)
//        self.rotation = 0;
    
    if(self.isAngry || self.isRotated)
    {
        NSString* imageName = @"pipe_3.png";
        if(NO == [RCTool isOpenAll])
            imageName = @"pipe_7.png";
            
        [self setImageBySpriteFrameName:imageName];
    }
    else
    {
        [self setImageBySpriteFrameName:[NSString stringWithFormat:@"pipe_%d.png",self.type]];
    }
}

@end
