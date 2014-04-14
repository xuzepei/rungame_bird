//
//  RCMatchResultLayer.h
//  RunGame
//
//  Created by xuzepei on 3/12/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCMenuItemSprite.h"
#import "RCLabelAtlas.h"

@protocol RCMatchResultLayerDelegate <NSObject>

- (void)clickedBackButton:(id)token;

@end

@interface RCMatchResultLayer : CCLayer {
    
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
@property(assign)BOOL isWinned;

- (id)init:(BOOL)isWinned;
- (void)showNew;

@end
