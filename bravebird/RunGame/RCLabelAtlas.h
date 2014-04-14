//
//  RCLabelAtlas.h
//  RunGame
//
//  Created by xuzepei on 2/8/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface RCLabelAtlas : CCLabelAtlas {
    
}

@property(nonatomic,assign)int maxNum;
@property(nonatomic,assign)int currentNum;
@property(nonatomic,retain)NSTimer* timer;

- (void)rollToNumber:(int)number;

@end
