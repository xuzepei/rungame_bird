//
//  RCCoin.m
//  RunGame
//
//  Created by xuzepei on 3/2/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "RCCoin.h"
#import "CCAnimation+Helper.h"


@implementation RCCoin

+ (id)coin
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	if((self = [super initWithSpriteFrameName:@"coin_0.png"]))
	{
        NSArray* indexArray = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",nil];
        NSString* frameName = [NSString stringWithFormat:@"coin_"];
        self.rotateAnimation = [CCAnimation animationWithFrame:frameName indexArray:indexArray delay:0.15];
	}
	return self;
}

- (void)dealloc
{
    self.rotateAnimation = nil;
    
    [super dealloc];
}

- (void)rotate
{
    [self stopAllActions];
    
    CCAnimate* animate = [CCAnimate actionWithAnimation:self.rotateAnimation];
    CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
    [self runAction:repeat];
}

@end
