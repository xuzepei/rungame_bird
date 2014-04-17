//
//  CCItemsScroller.h
//
//  Created by Aleksander Bykin on 26.06.12.
//  Copyright 2012. All rights reserved.
//

#import "cocos2d.h"

typedef enum{
    CCItemsScrollerVertical,
    CCItemsScrollerHorizontal
} CCItemsScrollerOrientations;

@protocol CCItemsScrollerDelegate;

@interface CCItemsScroller : CCLayer

@property (strong, nonatomic) id<CCItemsScrollerDelegate> delegate;
@property (assign, nonatomic) CCItemsScrollerOrientations orientation;

+(id)itemsScrollerWithItems:(NSArray*)items andOrientation:(CCItemsScrollerOrientations)orientation andRect:(CGRect)rect;

-(id)initWithItems:(NSArray*)items andOrientation:(CCItemsScrollerOrientations)orientation andRect:(CGRect)rect;

-(void)updateItems:(NSArray*)items;

@end


// PROTOCOL
@protocol CCItemsScrollerDelegate <NSObject>

@required

- (void)itemsScroller:(CCItemsScroller *)sender didSelectItemIndex:(int)index;

@optional

- (void)itemsScrollerScrollingStarted:(CCItemsScroller *)sender;

@end


// PROTOCOL
@protocol CCSelectableItemDelegate <NSObject>

@optional

-(void)setIsSelected:(BOOL)isSelected;

@end