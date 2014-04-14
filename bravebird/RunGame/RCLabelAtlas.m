//
//  RCLabelAtlas.m
//  RunGame
//
//  Created by xuzepei on 2/8/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "RCLabelAtlas.h"


@implementation RCLabelAtlas

- (void)rollToNumber:(int)number
{
    if(self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.maxNum = number;
    self.currentNum = 0;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(roll:) userInfo:nil repeats:YES];
    [self.timer fire];
}

- (void)roll:(NSTimer*)timer
{
    [self setString:[NSString stringWithFormat:@"%d",self.currentNum]];
    self.currentNum++;
    if(self.currentNum > self.maxNum)
    {
        [self.timer invalidate];
    }
}

- (void)dealloc
{
    if(self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    [super dealloc];
}

@end
