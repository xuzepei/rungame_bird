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
    self.position = ccp(self.position.x,self.position.y-2);
}

- (void)unselected
{
    self.position = ccp(self.position.x,self.position.y+2);
}

@end
