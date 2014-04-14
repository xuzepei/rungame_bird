//
//  RCDuck.m
//  RunGame
//
//  Created by xuzepei on 2/3/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "RCDuck.h"
#import "CCAnimation+Helper.h"

#define MAX_ANGLE 30.0f
#define MIN_ANGLE -90.0f


@implementation RCDuck

+ (id)duck:(int)type
{
	return [[[self alloc] initWithType:type] autorelease];
}

- (id)initWithType:(int)type
{
    NSString* imageName = @"fly_0_0.png";
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
        imageName = @"hd_fly_0_0.png";
	if ((self = [super initWithSpriteFrameName:imageName]))
	{
        self.type = type;
        NSArray* indexArray = [NSArray arrayWithObjects:@"0",@"1",@"2",nil];
        NSString* frameName = [NSString stringWithFormat:@"fly_%d_",type];
        if([RCTool isIpad] && NO == [RCTool isIpadMini])
            frameName = [NSString stringWithFormat:@"hd_fly_%d_",type];
        self.flyAnimation = [CCAnimation animationWithFrame:frameName indexArray:indexArray delay:0.08];
        
        [RCTool preloadEffectSound:MUSIC_FLAP];
        [RCTool preloadEffectSound:MUSIC_HIT];
        [RCTool preloadEffectSound:MUSIC_DROP];
        [RCTool preloadEffectSound:MUSIC_COIN];
        [RCTool preloadEffectSound:MUSIC_FART];
        
        [self scheduleUpdate];
        
        self.numVelocities = 5;
        self.flapTimes = 213;
	}
	return self;
}

- (void)dealloc
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.flyAnimation = nil;

    [super dealloc];
}

- (void)update:(ccTime)delta
{
    if([self getBody]->IsActive())
        [self down];
}

- (BOOL)needCheckCollision
{
    if(self.isOver || self.isHitted)
        return NO;
    
    return YES;
}

#pragma mark - Fly

- (void)flyUpDown
{
    [self stopAllActions];
    
    id fly = [CCAnimate actionWithAnimation:self.flyAnimation];
    id moveUp = [CCMoveBy actionWithDuration:0.8 position:ccp(0,10)];
    id moveDown = [CCMoveBy actionWithDuration:0.8 position:ccp(0,-10)];
    id sequence = [CCSequence actions:moveUp,moveDown,nil];
    
    CCRepeatForever* repeat1 = [CCRepeatForever actionWithAction:sequence];
    CCRepeatForever* repeat2 = [CCRepeatForever actionWithAction:fly];
    [self runAction:repeat1];
    [self runAction:repeat2];
    
}

- (void)flap
{
    [self stopAllActions];
    
    CCAnimate* animate = [CCAnimate actionWithAnimation:self.flyAnimation];
    CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
    [self runAction:repeat];
}

- (void)fly
{
    if(self.isHitted || self.isOver)
        return;
    
    
    [RCTool playEffectSound:MUSIC_FLAP];
    
    [self rotateTo:MAX_ANGLE];
    
    b2Body* body = [self getBody];
    
    if([RCTool isIpadMini])
    {
        body->SetLinearVelocity(b2Vec2(body->GetLinearVelocity().x,12));
    }
    else if([RCTool isIpad])
    {
        body->SetLinearVelocity(b2Vec2(body->GetLinearVelocity().x,21.3));
    }
    else
    {
        body->SetLinearVelocity(b2Vec2(body->GetLinearVelocity().x,12.5));
    }
}

- (void)down
{
    if(self.isOver)
        return;
    
    b2Body* body = [self getBody];
    CGPoint position = [self getPos];
    CGFloat a = 0.0;
    if([RCTool isIpad])
    {
        a = 0.9;
    }
    else{
        a = 0.459;
        //a = position.y*0.48/(WIN_SIZE.height/2.0);
    }

    body->SetLinearVelocity(b2Vec2(body->GetLinearVelocity().x, body->GetLinearVelocity().y - a));
    
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
        [self rotateBy:body->GetLinearVelocity().y*0.2];
    else
        [self rotateBy:body->GetLinearVelocity().y*0.3];
}

- (void)pass
{
    [RCTool playEffectSound:MUSIC_COIN];
    self.score++;
    self.flapTimes += 14;

    //防作弊
//    int64_t temp = self.flapTimes - (self.score*14) - 213;
//    if(temp <= -50 && temp >= 50)
//    {
//        return;
//    }
    
    [RCTool setRecordByType:RT_SCORE value:self.score];
    
    int best = [RCTool getRecordByType:RT_BEST];
    if(best < self.score)
    {
        self.isNewScore = YES;
        best = self.score;
        [RCTool setRecordByType:RT_BEST value:best];
    }
}

- (void)hit
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GAMEOVER_NOTIFICATION
                                                        object:nil
                                                      userInfo:nil];
    
    if(NO == self.isHitted)
    {
        [RCTool playEffectSound:MUSIC_HIT];
        
        [self drop];
    }
    
    self.isHitted = YES;
}

- (void)drop
{
    if([self getPos].y > [RCTool getValueByHeightScale:200])//高处掉落播放声音
        [RCTool playEffectSound:MUSIC_DROP];
    
    //[self rotateTo:MIN_ANGLE];
    [self down];
}

- (void)over
{
    self.isOver = YES;
    [self getBody]->SetActive(false);
    [self stopAllActions];
}

//旋转钢体
- (void)rotateBy:(float)rotation
{
    float32 b2Angle = CC_DEGREES_TO_RADIANS(rotation);
    b2Body* body = [self getBody];
    b2Angle = body->GetAngle() + b2Angle;
    
    if(b2Angle < b2_pi*MIN_ANGLE/180)
        b2Angle = b2_pi*MIN_ANGLE/180;
    
    if(b2Angle > b2_pi*MAX_ANGLE/180)
        b2Angle = b2_pi*MAX_ANGLE/180;
    
    [self setRotation:b2Angle];
}

- (void)rotateTo:(float)rotation
{
    float32 b2Angle = CC_DEGREES_TO_RADIANS(rotation);

    if(b2Angle < b2_pi*MIN_ANGLE/180)
        b2Angle = b2_pi*MIN_ANGLE/180;
    
    if(b2Angle > b2_pi*MAX_ANGLE/180)
        b2Angle = b2_pi*MAX_ANGLE/180;
    
    [self setRotation:b2Angle];
}

- (void)setRotation:(float32)b2Angle {
    
    if(b2Angle >= -b2_pi/2 && b2Angle <= b2_pi/4)
    {
        b2Body* body = [self getBody];
        body->SetTransform(body->GetPosition(), b2Angle);
    }
}

- (CGRect)frame
{
    //要求self.anchorPoint = ccp(0.5,0.5);
    CGPoint position = [self getPos];
    
    CGFloat width = self.contentSize.width - 4.0;
    CGFloat height = self.contentSize.height - 4.0;
    
    return CGRectMake(position.x - width/2.0, position.y - height/2.0, width, height);
}

@end
