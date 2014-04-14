//
//  RCGameScene.m
//  RunGame
//
//  Created by xuzepei on 9/13/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RCGameScene.h"
#import "RCTool.h"
#import "RCHomeScene.h"
#import "RCGameSceneParallaxBackground.h"
#import "RCPauseLayer.h"
#import "RCResultLayer.h"
#import "GCHelper.h"
#import "RCMenuItemSprite.h"
#import "RCCoin.h"


#define PIPE_COUPLE_NUM 4

static RCGameScene* sharedInstance = nil;
@implementation RCGameScene

+ (id)scene
{
    CCScene* scene = [CCScene node];
    RCGameScene* layer = [RCGameScene node];
    [scene addChild:layer];
    return scene;
}

+ (RCGameScene*)sharedInstance
{
    return sharedInstance;
}

- (id)init
{
    if(self = [super init])
    {
        sharedInstance = self;
        self.isTouchEnabled = YES;
        _pipeArray = [[NSMutableArray alloc] init];
        [RCTool addCacheFrame:@"images_block.plist"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameover:) name:GAMEOVER_NOTIFICATION object:nil];
        
        //创建背景
        [self initParallaxBackground];
        
        [self initTip];
        
        [self initPhysics];
        
        [self initDuck];
        
        [self initScoreLabel];
        
        //创建按钮
        //[self initButtons];
        
        [self schedule:@selector(tick:)];
        
        [RCTool preloadEffectSound:MUSIC_SWOOSH];
        [RCTool preloadEffectSound:MUSIC_HIT];
        [RCTool preloadEffectSound:MUSIC_DROP];
        [RCTool preloadEffectSound:MUSIC_COIN];
        
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if(self.longTouchTimer)
    {
        [self.longTouchTimer invalidate];
        self.longTouchTimer = nil;
    }
    
    if(_debugDraw)
    {
        delete _debugDraw;
        _debugDraw = NULL;
    }
    
    if(_world)
    {
        if(_contactListener)
        {
            delete _contactListener;
            _contactListener = NULL;
        }
        
        if(_groundBody)
        {
            _world->DestroyBody(_groundBody);
            _groundBody = NULL;
        }
        
        delete _world;
        _world = NULL;
    }
    
    if(_groundBody)
        _groundBody = NULL;
    
    _groundFixture = NULL;
    
    self.pipeArray = nil;
    self.duck = nil;
    self.parallaxBg = nil;
    self.scoreLabel = nil;
    self.readySprite = nil;
    self.tapSprite = nil;
    sharedInstance = nil;
    
    [super dealloc];
}

#pragma mark - Tip

- (void)initTip
{
    self.readySprite = [CCSprite spriteWithSpriteFrameName:@"ready.png"];
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
        self.readySprite.scale = 2 * 1.8;
    else
        self.readySprite.scale = 2;
    self.readySprite.position = ccp(WIN_SIZE.width/2.0, WIN_SIZE.height/2.0 + [RCTool getValueByHeightScale:80]);
    [self addChild:self.readySprite z:10];
    
    self.tapSprite = [CCSprite spriteWithSpriteFrameName:@"tap.png"];
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
        self.tapSprite.scale = 2 * 1.8;
    else
        self.tapSprite.scale = 2;
    self.tapSprite.position = ccp(WIN_SIZE.width/2.0 + 40, WIN_SIZE.height/2.0 - [RCTool getValueByHeightScale:30]);
    [self addChild:self.tapSprite z:10];
    
    self.isReady = YES;
}


#pragma mark - Parallax Background

- (void)initParallaxBackground
{
    //设置背景
    NSString* imageName = [NSString stringWithFormat:@"bg_%d.png",[RCTool randomByType:RDM_BG]];
    CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName];
    CCSprite* bgSprite = [CCSprite spriteWithSpriteFrame:spriteFrame];
    [RCTool resizeSprite:bgSprite toWidth:WIN_SIZE.width toHeight:WIN_SIZE.height];
    bgSprite.anchorPoint = ccp(0,0);
    bgSprite.position = ccp(0,0);
    [self addChild:bgSprite z:0];
    
    self.parallaxBg = [RCGameSceneParallaxBackground node];
    [self addChild:self.parallaxBg z:1];
}

#pragma mark - Score

- (void)initScoreLabel
{
    if(self.scoreLabel)
        [self.scoreLabel removeFromParentAndCleanup:YES];
    
    CGFloat fact = 2.0f;
    if([RCTool isIpadMini])
        fact = 1.0f;
    
    self.scoreLabel = [[[CCLabelAtlas alloc]  initWithString:@"0" charMapFile:@"large_number.png" itemWidth:64/fact itemHeight:84/fact startCharMap:'0'] autorelease];
    self.scoreLabel.anchorPoint = ccp(0.5, 1);
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
        self.scoreLabel.scale = 1.8;
    self.scoreLabel.position = ccp(WIN_SIZE.width/2.0, WIN_SIZE.height - [RCTool getValueByHeightScale:60]);
    
    [self addChild:self.scoreLabel z:50];
}

#pragma mark - Buttons

- (void)initButtons
{
    CGSize winSize = WIN_SIZE;

    CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"pause_button.png"];
    CCMenuItemSprite* menuItem = [RCMenuItemSprite itemWithNormalSprite:sprite selectedSprite:nil target:self selector:@selector(clickedPauseButton:)];
    CCMenu* menu = [CCMenu menuWithItems:menuItem, nil];
    menu.anchorPoint = ccp(0,1);
    menu.position = ccp(30, winSize.height - 30);
    menu.tag = T_PAUSE_BUTTON;
    [self addChild: menu z:50];
}


- (void)clickedBackButton:(id)token
{
    [RCTool playEffectSound:MUSIC_SWOOSH];
    
    [self.duck over];
    
    if([DIRECTOR isPaused])
        [DIRECTOR resume];
    
    CCScene* scene = [RCHomeScene scene];
    [DIRECTOR replaceScene:[CCTransitionFade transitionWithDuration:0.2 scene:scene withColor:ccWHITE]];
}

- (void)clickedResumeButton:(id)token
{
    if([DIRECTOR isPaused])
    {
        [DIRECTOR resume];
    }
}

- (void)clickedPauseButton:(id)sender
{
    if(NO == [DIRECTOR isPaused])
    {
        [DIRECTOR pause];
        
        RCPauseLayer* pauseLayer = [[[RCPauseLayer alloc] init] autorelease];
        pauseLayer.delegate = self;
        pauseLayer.tag = T_PAUSE_LAYER;
        [self addChild:pauseLayer z:100];
    }
}

#pragma mark - Box2D

- (void)draw
{
	[super draw];
    
#ifdef DEBUG
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
	kmGLPushMatrix();
	_world->DrawDebugData();
	kmGLPopMatrix();
#endif
}

- (void)tick:(ccTime)dt
{
    int32 velocityIterations = 8;
	int32 positionIterations = 1;
	_world->Step(dt, velocityIterations, positionIterations);
    
    [self checkCollision];
    
    if(self.shouldBeShaking)
    {
        float x = (arc4random() % self.shakeIntensity) - 0.5f; //Generate a random x coordinate
        float y = (arc4random() % self.shakeIntensity) - 0.5f; //Do the same for the y coordinate
        self.position = ccp(x,y); //Offset the layer's position by x and y
        self.shakeLength--; //Subtract one from the length
        if (self.shakeLength <= 0) { //Have we reached the end?
            self.position = ccp(0,0); //Set us back to align with the screen
            self.shouldBeShaking = NO; //Stop shaking
            self.shakeLength = 0; //Reset shakeLength
            self.shakeIntensity = 0; //Reset shakeIntensity
            [self unscheduleUpdate];
        }
    }
}

- (id)checkCollision
{
    //检测是否碰撞到管道
    if(NO == self.duck.isHitted)
    {
        for(RCPipe* pipe in _pipeArray)
        {
            //CCLOG(@"duck:%@",NSStringFromCGRect([self.duck frame]));
            
            if(CGRectIntersectsRect([pipe frame],[self.duck frame]))
            {
                CCLOG(@"duck:%@",NSStringFromCGRect([self.duck frame]));
                CCLOG(@"pipe:%@,tag:%d",NSStringFromCGRect([pipe frame]),pipe.tag);
                NSLog(@"Duck hits the pipe!");

                [self.duck hit];
                [self shakeScreen];
                [self flashScreen];
                
                return nil;
            }
        }
    }

    std::vector<MyContact>::iterator pos;
    for(pos = _contactListener->_contacts.begin();
        pos != _contactListener->_contacts.end(); ++pos) {
        MyContact contact = *pos;
        
        //_groundFixture 为下边的groundFixture
        if((contact.fixtureA == [self.duck getFixture] && contact.fixtureB == _groundFixture) ||
           (contact.fixtureA == _groundFixture && contact.fixtureB == [self.duck getFixture]))
        {
            NSLog(@"Duck hit ground!");
            
            if(NO == self.duck.isHitted)
                [self.duck hit];
            
            if(NO == self.duck.isOver)
                [self showResult:nil];
            return nil;
        }
    }
    
    //检测是否通过管道
    for(RCPipe* pipe in _pipeArray)
    {
        if(pipe.flipY)//下方管道
        {
            CGPoint duckPos = [self.duck getPos];
            CGPoint pipePos = pipe.position;
            if(duckPos.x - self.duck.contentSize.width/2.0 > pipePos.x)
                pipe.isPassed = YES;
            
            if(pipe.isPassed)
                continue;

            CGRect passRect;
            if([RCTool isIpadMini])
            {
                passRect = CGRectMake(pipePos.x - 2, pipePos.y+pipe.contentSize.height,4,PIPE_TOPBOTTOM_INTERVAL_IPAD_MINI);
            }
            else{
                
                passRect = CGRectMake(pipePos.x - 2, pipePos.y+[RCTool getValueByHeightScale:pipe.contentSize.height],4,MAX(PIPE_TOPBOTTOM_INTERVAL, [RCTool getValueByHeightScale:PIPE_TOPBOTTOM_INTERVAL]));
            }
            
            //NSLog(@"passRect:%@,duck frame:%@",NSStringFromCGRect(passRect),NSStringFromCGRect([self.duck frame]));
            if(CGRectIntersectsRect(passRect,[self.duck frame]))
            {
                NSLog(@"Duck passed the pipe!");
                
                RCCoin* coin = (RCCoin*)[self.parallaxBg.batch getChildByTag:T_COIN_0 + (pipe.tag - T_PIPE_0)/2];
                if(coin && [coin isKindOfClass:[RCCoin class]])
                {
                    [coin setVisible:NO];
                }
                
                pipe.isPassed = YES;
                self.score++;
                [self.scoreLabel setString:[NSString stringWithFormat:@"%d",self.score]];
                [self.duck pass];
                break;
            }
            
        }
        
    }
    
    
    return NULL;
}

- (void)initPhysics
{
    CGSize winSize = WIN_SIZE;
    
    //创建world
    b2Vec2 gravity = b2Vec2(0.0f,-10.0f)
    ;
    _world = new b2World(gravity);
    _world->SetAllowSleeping(true);
    _world->SetContinuousPhysics(true);
    
    _contactListener = new MyContactListener();
    _world->SetContactListener(_contactListener);
    
#ifdef DEBUG
    _debugDraw = new GLESDebugDraw(PTM_RATIO);
	_world->SetDebugDraw(_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	_debugDraw->SetFlags(flags);
#endif
    
    
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0,0);
    _groundBody = _world->CreateBody(&groundBodyDef);
    
    b2EdgeShape groundEdge;
    
    //top edge
    groundEdge.Set(b2Vec2(0, winSize.height/PTM_RATIO),
                   b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
    _groundBody->CreateFixture(&groundEdge,0);
    
    //bottom edge
    groundEdge.Set(b2Vec2(0,[RCTool getValueByHeightScale:FLOOR_HEIGHT]/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, [RCTool getValueByHeightScale:FLOOR_HEIGHT]/PTM_RATIO));
    _groundFixture = _groundBody->CreateFixture(&groundEdge,0);
    
    //left edge
    groundEdge.Set(b2Vec2(0,0), b2Vec2(0, 0/PTM_RATIO));
    _groundBody->CreateFixture(&groundEdge,0);
    
    //right edge
    groundEdge.Set(b2Vec2(winSize.width/PTM_RATIO,
                          0), b2Vec2(winSize.width/PTM_RATIO, 0/PTM_RATIO));
    _groundBody->CreateFixture(&groundEdge,0);
}

- (void)initDuck
{
    if(self.duck)
        [self.duck removeFromParentAndCleanup:YES];
    
    self.duck = [RCDuck duck:[RCTool randomByType:RDM_DUCK]];

    self.duck.position = ccp([RCTool getValueByWidthScale:100],WIN_SIZE.height/2.0 - [RCTool getValueByWidthScale:20]);
    [self addChild:self.duck z:10];
    [self.duck flap];
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(self.duck.position.x/PTM_RATIO, self.duck.position.y/PTM_RATIO);
    //bodyDef.angle = 0.25*b2_pi; //设置初始角度，单位弧度
    bodyDef.fixedRotation = true; // 不旋转
    b2Body* body = _world->CreateBody(&bodyDef);
    
//    b2MassData * MassData = new b2MassData;
//    MassData->mass = 0.1f;
//    MassData->I = 0.0f;
//    b2Vec2 center;
//    center.Set(10.0f, 0.1f);
//    MassData->center = center; 
//    body->SetMassData(MassData);

    
    b2PolygonShape box;
    box.SetAsBox(self.duck.contentSize.width/2.0/PTM_RATIO, self.duck.contentSize.height/2.0/PTM_RATIO);
    
    b2FixtureDef shapeDef;
    shapeDef.shape = &box;
    shapeDef.density = 1.0f; //密度,就是单位体积的质量。因此，一个对象的密度越大，那么它就有更多的质量，当然就会越难以移动。
    shapeDef.friction = 0.1f; //摩擦系数,它的范围是0-1.0, 0意味着没有摩擦，1代表最大摩擦，几乎移不动的摩擦。
    shapeDef.restitution = 0.0f; //补偿系数,它的范围也是0到1.0。 0意味着对象碰撞之后不会反弹，1意味着是完全弹性碰撞，会以同样的速度反弹。
    b2Fixture* fixture = body->CreateFixture(&shapeDef);
    [self.duck setFixture:fixture];
    
//    b2PrismaticJointDef jointDef;
//    b2Vec2 worldAxis(0.0f, 1.0f);
//    jointDef.collideConnected = true;
//    jointDef.Initialize(body, _groundBody,
//                        body->GetWorldCenter(), worldAxis);
//    _world->CreateJoint(&jointDef);

    [self.duck setPhysicsBody:body];
    
    [self.duck getBody]->SetActive(false);
}

#pragma mark - Pipe

- (void)initPipes
{
    [RCTool addCacheFrame:@"images_block.plist"];
    
    //清理旧的Pipe
    for(RCPipe* pipe in _pipeArray)
        [pipe removeFromParentAndCleanup:NO];
    [_pipeArray removeAllObjects];
    
    int pipeType = [RCTool randomByType:RDM_PIPE];
    
    //创建Pipe
    CGFloat offset_x = WIN_SIZE.width*2;
    int index = T_PIPE_0;
    for(int i = 0; i < PIPE_COUPLE_NUM; i++)
    {
        BOOL isRotated = NO;
        BOOL isAngry = [RCTool isAngry];
        
        CGFloat random_height = WIN_SIZE.height - [RCTool getValueByHeightScale:PIPE_MIN_HEIGHT]*2 - MAX(PIPE_TOPBOTTOM_INTERVAL, [RCTool getValueByHeightScale:PIPE_TOPBOTTOM_INTERVAL]) - [RCTool getValueByHeightScale:FLOOR_HEIGHT];
        if([RCTool isIpadMini])
        {
            random_height = WIN_SIZE.height - PIPE_MIN_HEIGHT_IPAD_MINI*2 - PIPE_TOPBOTTOM_INTERVAL_IPAD_MINI - FLOOR_HEIGHT_IPAD_MINI;
        }
        
        random_height = [RCTool randFloat:random_height min:0];
        
        if([RCTool isIpadMini])
        {
            random_height += PIPE_MIN_HEIGHT_IPAD_MINI + FLOOR_HEIGHT_IPAD_MINI;
        }
        else
        {
            random_height += [RCTool getValueByHeightScale:PIPE_MIN_HEIGHT + FLOOR_HEIGHT];
        }
        
        RCPipe* bottom_pipe = [RCPipe pipe:pipeType];
        [bottom_pipe setAction:isAngry isRotated:isRotated];
        bottom_pipe.anchorPoint = ccp(0.5,0);
        CGFloat offset_y = random_height - [RCTool getValueByHeightScale:bottom_pipe.contentSize.height];
        bottom_pipe.position = ccp(offset_x,offset_y);
        bottom_pipe.flipY = YES;
        bottom_pipe.tag = index;
        bottom_pipe.scale = [RCTool getHeightScale];
        if([RCTool isIpadMini])
        {
            offset_y = random_height - bottom_pipe.contentSize.height;
            bottom_pipe.position = ccp(offset_x,offset_y);
            bottom_pipe.scale = 1.0;
        }
        
        [self.parallaxBg addPipe:bottom_pipe];
        [_pipeArray addObject:bottom_pipe];
        index++;
        
        //创建上方管道
        RCPipe* top_pipe = [RCPipe pipe:pipeType];
        [top_pipe setAction:isAngry isRotated:isRotated];
        top_pipe.bottomPipe = bottom_pipe;
        top_pipe.anchorPoint = ccp(0.5,0);
        offset_y = random_height + MAX(PIPE_TOPBOTTOM_INTERVAL,[RCTool getValueByHeightScale:PIPE_TOPBOTTOM_INTERVAL]);
        top_pipe.position = ccp(offset_x,offset_y);
        top_pipe.tag = index;
        top_pipe.scale = [RCTool getHeightScale];
        if([RCTool isIpadMini])
        {
            offset_y = random_height + PIPE_TOPBOTTOM_INTERVAL_IPAD_MINI;
            top_pipe.position = ccp(offset_x,offset_y);
            top_pipe.scale = 1.0;
        }
        [self.parallaxBg addPipe:top_pipe];
        [_pipeArray addObject:top_pipe];
        index++;
        
        //创建金币
        RCCoin* coin = [RCCoin coin];
        if([RCTool isIpad] && NO == [RCTool isIpadMini])
            coin.scale = 1.8;
        offset_y = random_height + MAX(PIPE_TOPBOTTOM_INTERVAL,[RCTool getValueByHeightScale:PIPE_TOPBOTTOM_INTERVAL])/2.0;
        if([RCTool isIpadMini])
        {
            offset_y = random_height + PIPE_TOPBOTTOM_INTERVAL_IPAD_MINI/2.0;
        }
        coin.position = ccp(offset_x,offset_y);
        coin.tag = T_COIN_0 + i;
        
        if(isAngry || isRotated)
            [coin setVisible:NO];
        else
            [coin setVisible:YES];
        
        [coin rotate];
        [self.parallaxBg.batch addChild:coin z:2];
        
        if([RCTool isIpadMini])
        {
            offset_x += top_pipe.contentSize.width + PIPE_INTERVAL_IPAD_MINI;
        }
        else
        {
            offset_x += [RCTool getValueByHeightScale:top_pipe.contentSize.width] + [RCTool getValueByWidthScale:PIPE_INTERVAL];
        }
    }
    
}

#pragma mark - Touch Event

- (void)registerWithTouchDispatcher
{
    [[DIRECTOR touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    //CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    //CCLOG(@"touchLocation:%@",NSStringFromCGPoint(touchLocation));
    
    if(self.isReady)
    {
        [self play];
    }
    
    [self.duck fly];

    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    //CCLOG(@"long touch end,state:%d",self.duck);
    if(self.longTouchTimer)
    {
        [self.longTouchTimer invalidate];
        self.longTouchTimer = nil;
    }
}

- (void)longTouchTimer:(NSTimer*)timer
{
//    if([self.duck isFlying])
//    {
//        [self clickedJumpButton];
//    }
}

#pragma mark - Fade Out

- (void)fadeOut:(CCSprite*)sprite
{
    if(sprite)
    {
        id fadeOut = [CCFadeOut actionWithDuration:0.3f];
        CCCallFunc *done = [CCCallFuncN actionWithTarget:self selector:@selector(fadeOutDone:)];
        id sequence = [CCSequence actions:fadeOut,done,nil];
        [sprite runAction:sequence];
    }
}

- (void)fadeOutDone:(id)sender
{
    CCSprite* sprite = (CCSprite*)sender;
    [sprite removeFromParentAndCleanup:YES];
    
    self.readySprite = nil;
    self.tapSprite = nil;
}

#pragma mark - Play

- (void)play
{
    self.isReady = NO;
    
    [self initPipes];
    
    [self fadeOut:self.readySprite];
    [self fadeOut:self.tapSprite];
    
    [RCTool setRecordByType:RT_SCORE value:0];
    
    [self.duck getBody]->SetActive(true);
}

#pragma mark - GameOver

- (void)gameover:(NSNotification*)notification
{
    _pipeSpeed = 0.0;
}

- (void)sendResult
{
    
    NSLog(@"coin number: %d + %d",[RCTool getRecordByType:RT_COIN],[RCTool getRecordByType:RT_SCORE]);
    
    [RCTool setRecordByType:RT_COIN value:[RCTool getRecordByType:RT_COIN] + [RCTool getRecordByType:RT_SCORE]];
    
    [[GCHelper sharedInstance] reportGoldCoinNum:[RCTool getRecordByType:RT_COIN]];
    [[GCHelper sharedInstance] reportScore:[RCTool getRecordByType:RT_BEST]];
    [[GCHelper sharedInstance] reportPlayTimes:[RCTool getRecordByType:RT_PLAYTIMES]];
}

- (void)showResult:(id)argument
{
    [self.duck over];
    
    if(NO == [DIRECTOR isPaused])
    {
        [RCTool playEffectSound:MUSIC_SWOOSH];
        //[DIRECTOR pause];
        
        [self sendResult];
        
        RCResultLayer* resultLayer = [[[RCResultLayer alloc] init] autorelease];
        resultLayer.delegate = self;
        if(self.duck.isNewScore)
            [resultLayer showNew];
        [self addChild:resultLayer z:100];
        
        [self.scoreLabel removeFromParentAndCleanup:YES];
        [self removeChildByTag:T_PAUSE_BUTTON cleanup:YES];
    }
}

#pragma mark - Shake Screen

- (void)shakeScreen
{
    CCLOG(@"shakeScreen");
    
    if([RCTool isIpad] && NO == [RCTool isIpadMini])
    {
        self.shakeLength = 11;
        self.shakeIntensity = 11;
    }
    else{
        self.shakeLength = 6;
        self.shakeIntensity = 6;
    }
    self.shouldBeShaking = YES;
}

- (void)flashScreen
{
    CCLayerColor* whiteLayer = [CCLayerColor layerWithColor:ccc4(255,255,255,100)];
    [self addChild:whiteLayer z:100];
    id animate = [CCFadeOut actionWithDuration:0.1];
    id sequence = [CCSequence actions:animate, nil];
    [whiteLayer runAction:sequence];
}

@end
