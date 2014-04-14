//
//  RCMatchDuck.m
//  RunGame
//
//  Created by xuzepei on 3/14/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "RCMatchDuck.h"
#import "CCAnimation+Helper.h"

#define MAX_ANGLE 30.0f
#define MIN_ANGLE -90.0f

@implementation RCMatchDuck

+ (id)duck:(int)type
{
	return [[[self alloc] initWithType:type] autorelease];
}

- (id)initWithType:(int)type
{
    NSString* imageName = [NSString stringWithFormat:@"fly_%d_0.png",type];
	if((self = [super initWithSpriteFrameName:imageName]))
	{
        self.type = type;
        NSArray* indexArray = [NSArray arrayWithObjects:@"0",@"1",@"2",nil];
        NSString* frameName = [NSString stringWithFormat:@"fly_%d_",type];
        self.flyAnimation = [CCAnimation animationWithFrame:frameName indexArray:indexArray delay:0.06];
        
        if(NO == [RCTool isIpad] && NO == [RCTool isIpadMini])
            self.scale = 0.5;
	}
	return self;
}

- (void)dealloc
{
    self.flyAnimation = nil;
    [super dealloc];
}

@end
