//
//  RCRank.m
//  RunGame
//
//  Created by xuzepei on 3/6/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "RCRank.h"
#import "GCHelper.h"


@implementation RCRank

- (void)dealloc
{
    self.delegate = nil;
    self.label = nil;
    
    [super dealloc];
}

- (void) onEnter
{
    self.clickableSize = CGSizeMake(self.contentSize.width + 200,self.contentSize.height);
    
    int fontSize = 26;
    if([RCTool isIpadMini])
        fontSize = 32;
    
    self.label = [CCLabelTTF labelWithString:@"" fontName:@"Helvetica-Bold" fontSize:fontSize];
    self.label.anchorPoint = ccp(0,0.5);
    self.label.position = ccp([RCTool getValueByWidthScale:12], self.contentSize.height/2.0);
    [self addChild:self.label];
    
    if([GCHelper sharedInstance].myScore)
    {
        [self updateRank:[GCHelper sharedInstance].myScore.rank];
    }
    
    [self registerWithTouchDispatcher];
    
    [super onEnter];
}

- (void)onExit {
    [[DIRECTOR touchDispatcher] removeDelegate:self];
    [super onExit];
}

- (void)move
{
    id moveTo = [CCMoveTo actionWithDuration:0.3 position:ccp([RCTool getValueByHeightScale:26] - 5,self.position.y)];
    
    id moveBy0 = [CCMoveBy actionWithDuration:0.2 position:ccp(5 + 2,0)];
    id moveBy1 = [CCMoveBy actionWithDuration:0.1 position:ccp(-3,0)];
    id moveBy2 = [CCMoveBy actionWithDuration:0.0 position:ccp(1,0)];
    
    id sequence = [CCSequence actions:moveTo,moveBy0,moveBy1,moveBy2,nil];
    [self runAction:sequence];
}

- (void)updateRank:(int64_t)rank
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = kCFNumberFormatterDecimalStyle;
    NSString *string = [formatter stringFromNumber:[NSNumber numberWithLongLong:rank]];
    [formatter release];
    

    if(self.label)
    {
        self.label.position = ccp(50, self.contentSize.height/2.0);
        [self.label setString:[NSString stringWithFormat:@"#%@ overall",string]];
    }
}



#pragma mark - Touch Event

- (BOOL)containsTouchLocation:(UITouch *)touch
{
    CGPoint p = [self convertTouchToNodeSpaceAR:touch];
    CGSize size = self.contentSize;
    if(!CGSizeEqualToSize(self.clickableSize, CGSizeZero))
        size = self.clickableSize;
    CGRect r = CGRectMake(-size.width*0.5, -size.height*0.5, size.width, size.height);
    return CGRectContainsPoint(r, p);
}

- (void)registerWithTouchDispatcher
{
	[[DIRECTOR touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch*)touch withEvent:(UIEvent *)event
{
    BOOL b = [self containsTouchLocation:touch];
    if(b)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(clickedRankButton:)])
        {
            [self.delegate clickedRankButton:nil];
        }
    }
    
    return b;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(![self containsTouchLocation:touch])
        return;
}

@end
