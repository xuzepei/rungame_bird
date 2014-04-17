//
//  RCMenuItemSprite.m
//  RunGame
//
//  Created by xuzepei on 2/3/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "RCMenuItemSprite.h"


@implementation RCMenuItemSprite

- (void)selected
{
    self.scale += 0.1f;
}

- (void)unselected
{
    self.scale -= 0.1f;
}

@end
