//
//  RCMenuItemSprite2.m
//  RunGame
//
//  Created by xuzepei on 4/15/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "RCMenuItemSprite2.h"


@implementation RCMenuItemSprite2

- (void)selected
{
    self.scale += 0.03f;
}

- (void)unselected
{
    self.scale -= 0.03f;
}

@end
