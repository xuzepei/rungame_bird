//
//  RCResultLayer.h
//  RunGame
//
//  Created by xuzepei on 9/26/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCMenuItemSprite.h"
#import "RCLabelAtlas.h"

@protocol RCResultLayerDelegate <NSObject>

- (void)clickedBackButton:(id)token;

@end

@interface RCResultLayer : CCLayer {
    
}

@property(assign)id delegate;
@property(nonatomic,retain)RCLabelAtlas* scoreLabel;
@property(nonatomic,retain)RCLabelAtlas* bestLabel;
@property(nonatomic,retain)CCSprite* scoreBoard;
@property(nonatomic,retain)CCSprite* overSprite;
@property(nonatomic,retain)CCSprite* medalSprite;
@property(nonatomic,retain)CCSprite* newSprite;
@property(nonatomic,retain)CCSprite* starSprite;
@property(nonatomic,assign)BOOL isNew;

- (void)showNew;

@end
