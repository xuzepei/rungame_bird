//
//  GCHelper.m
//  BeatMole
//
//  Created by xuzepei on 8/12/13.
//
//

#import "GCHelper.h"
#import <UIKit/UIKit.h>
#import "RCTool.h"

@implementation GCHelper

+ (GCHelper*)sharedInstance
{
    static GCHelper* sharedInstance = nil;
    
    if(nil == sharedInstance)
    {
        @synchronized([GCHelper class])
        {
            if(nil == sharedInstance)
            {
                sharedInstance = [[GCHelper alloc] init];
            }
        }
    }
    
    return sharedInstance;
}

- (BOOL)isGameCenterAvailable
{
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    //check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id)init {
    
    if (self = [super init])
    {
        _gameCenterAvailable = [self isGameCenterAvailable];
        if(_gameCenterAvailable)
        {
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.myScore = nil;
    
    self.presentingViewController = nil;;
    self.match = nil;
    self.delegate = nil;
    self.matchStarted = nil;
    
    [super dealloc];
}

- (void)authenticationChanged
{
    if ([GKLocalPlayer localPlayer].isAuthenticated && !_userAuthenticated){
        CCLOG(@"Authentication changed: player authenticated.");
        _userAuthenticated = TRUE;
        
        //[self reportScore:[RCTool getRecordByType:RT_BEST]];
        
        [self getPlayerInfo];
    }
    else if (![GKLocalPlayer localPlayer].isAuthenticated && _userAuthenticated) {
        CCLOG(@"Authentication changed: player not authenticated");
        _userAuthenticated = FALSE;
    }
}

- (void)authenticateLocalUser
{
    if(!_gameCenterAvailable)
        return;
    
    if(_userAuthenticated)
        return;
    
    CCLOG(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO)
    {
        [GKLocalPlayer localPlayer].authenticateHandler = ^(UIViewController *viewController, NSError *error){
            if(viewController != nil)
            {
                [[RCTool getRootNavigationController] presentViewController:viewController animated:YES completion:nil];
            }
            else if ([GKLocalPlayer localPlayer].isAuthenticated)
            {
                self.userAuthenticated = YES;
            }
            else
            {
                CCLOG(@"authenticate user:%@",[error localizedDescription]);
            }
        };
    } else {
        CCLOG(@"Already authenticated!");
        self.userAuthenticated = YES;
    }
}

- (BOOL)reportScore:(int64_t)score
{
    if(NO == _userAuthenticated)
        return NO;
    
    if(NO == [RCTool isReachableViaInternet])
        return NO;

    BOOL __block b = YES;
    GKScore* reporter = [[[GKScore alloc] initWithCategory:LEADERBOARD_SCORES_ID] autorelease];
    reporter.value = score;
    [reporter reportScoreWithCompletionHandler: ^(NSError *error)
    {
        CCLOG(@"reportScore,error:%@",error);
        
        if(error)
            b = NO;
    }];
    
    return b;
}

- (BOOL)reportPlayTimes:(int64_t)times
{
    if(NO == _userAuthenticated)
        return NO;
    
    if(NO == [RCTool isReachableViaInternet])
        return NO;
    
    BOOL __block b = YES;
    GKScore* reporter = [[[GKScore alloc] initWithCategory:LEADERBOARD_PLAYTIMES_ID] autorelease];
    reporter.value = times;
    [reporter reportScoreWithCompletionHandler: ^(NSError *error)
     {
         CCLOG(@"reportPlayTimes,error:%@",error);
         
         if(error)
             b = NO;
     }];
    
    return b;
}

- (BOOL)reportGoldCoinNum:(int64_t)t
{
    if(NO == _userAuthenticated)
        return NO;
    
    if(NO == [RCTool isReachableViaInternet])
        return NO;
    
    BOOL __block b = YES;
    GKScore* reporter = [[[GKScore alloc] initWithCategory:LEADERBOARD_GOLDCOINNUM_ID] autorelease];
    reporter.value = t;
    [reporter reportScoreWithCompletionHandler: ^(NSError *error)
     {
         CCLOG(@"reportGoldCoinNum,error:%@",error);
         
         if(error)
             b = NO;
     }];
    
    return b;
}

#pragma mark - Player Info

- (void)getPlayerInfo
{
    if(NO == _userAuthenticated)
        return;
    
    if(NO == [RCTool isReachableViaInternet])
        return;
    
    if(NO == [GKLocalPlayer localPlayer].authenticated)
        return;
    
    NSArray *playerIds = [[[NSArray alloc] initWithObjects:[GKLocalPlayer localPlayer].playerID, nil] autorelease];
    GKLeaderboard *leaderboard = [[[GKLeaderboard alloc] initWithPlayerIDs:playerIds] autorelease];
    if(nil == leaderboard)
        return;
    
    leaderboard.timeScope = GKLeaderboardTimeScopeAllTime;
    leaderboard.category = LEADERBOARD_SCORES_ID;
    leaderboard.range = NSMakeRange(1,1);
    
    [leaderboard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error)
    {
        if(error != nil)
        {
            CCLOG(@"loadScoresWithCompletionHandler,error:%@",[error localizedDescription]);
        }
        else
        {
            if([scores count])
            {
                self.myScore = (GKScore*)[scores objectAtIndex:0];
                CCLOG(@"player's id:%@, rank:%d, score:%lld",self.myScore.playerID,self.myScore.rank,self.myScore.value);
                
                [[NSNotificationCenter defaultCenter] postNotificationName:MYSCORE_NOTIFICATION object:nil];
            }
        }
    }];
}

#pragma mark - Match

- (void)sendData:(id)data type:(int)type
{
    if(nil == self.match)
        return;
    
    NSError *error;
    DataPacket msg;
    msg.type = type;
    msg.count = -1;
    memset(msg.a, -1, sizeof(float)*200);

    
    if(PMT_TAP == type)
    {
        msg.count = 1;
    }
    else if(PMT_PIPES == type)
    {
        if(nil == data || NO == [data isKindOfClass:[NSArray class]])
        {
            return;
        }
        
        NSArray* array = (NSArray*)data;
        int i = 0;
        for(NSNumber* number in array)
        {
            CGFloat value = [number floatValue];
            msg.a[i] = value;
            i++;
        }
    }
    else if(PMT_ROLE == type)
    {
        if(nil == data || NO == [data isKindOfClass:[NSNumber class]])
        {
            return;
        }
        
        msg.count = [data intValue];
    }

    
    NSData *packet = [NSData dataWithBytes:&msg length:sizeof(DataPacket)];
    BOOL success = [self.match sendDataToAllPlayers:packet withDataMode: GKMatchSendDataReliable
                          error:&error];
    if(!success)
    {
        CCLOG(@"Error sending init packet");
    }
}

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                viewController:(UIViewController *)viewController
                      delegate:(id<GCHelperDelegate>)delegate
{
    if(!_gameCenterAvailable)
        return;
    
    self.matchStarted = NO;
    self.match = nil;
    self.presentingViewController = viewController;
    self.delegate = delegate;
    
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    
    GKMatchRequest *request = [[[GKMatchRequest alloc] init] autorelease];
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;
    
    GKMatchmakerViewController *mmvc = [[[GKMatchmakerViewController alloc] initWithMatchRequest:request] autorelease];
    mmvc.matchmakerDelegate = self;
    
    [self.presentingViewController presentViewController:mmvc animated:YES completion:nil];
}

#pragma mark - GKMatchmakerViewControllerDelegate
//The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController{
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"matchmakerViewControllerWasCancelled");
}

//Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error{

    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"Error finding match: %@", error.localizedDescription);
}

// A peer-to-peer match has been found, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match
{
    NSLog(@"didFindMatch");
    self.match = match;
    self.match.delegate = self;
    if (!self.matchStarted && self.match.expectedPlayerCount == 0)
    {
        self.matchStarted = YES;
        
        NSLog(@"Ready to start match!");
    
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:STARTMATCH_NOTIFICATION object:nil];
        
    }];
    

}

// Players have been found for a server-hosted game, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindPlayers:(NSArray *)playerIDs
{
    NSLog(@"didFindPlayers");
}

// An invited player has accepted a hosted invite.  Apps should connect through the hosting server and then update the player's connected state (using setConnected:forHostedPlayer:)
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didReceiveAcceptFromHostedPlayer:(NSString *)playerID
{
    NSLog(@"didReceiveAcceptFromHostedPlayer");
}

#pragma mark - GKMatchDelegate

//The match received data sent from the player.
- (void)match:(GKMatch *)theMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID{
    
    if(self.match != theMatch)
        return;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(match:didReceiveData:fromPlayer:)])
    {
        [self.delegate match:theMatch didReceiveData:data fromPlayer:playerID];
    }
}


//The player state changed(eg.connected or disconnected)
- (void)match:(GKMatch *)theMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state{
    if(self.match != theMatch)
        return;
    
    switch (state) {
        case GKPlayerStateConnected:
            //handle a new player connection.
            NSLog(@"player connected!");
            
            if(!self.matchStarted && 0 == theMatch.expectedPlayerCount){
                NSLog(@"Ready to start match!");
            }
            
            break;
        case GKPlayerStateDisconnected:

            NSLog(@"Player disconnected!");
            self.matchStarted = NO;
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(matchEnded)])
            {
                [self.delegate matchEnded:nil];
            }
            
            break;
    }
    
}


//THE MATCH WAs unable to connect with the player due to an error.
- (void)match:(GKMatch *)theMatch didFailWithError:(NSError *)error{
    
    if(self.match != theMatch)
        return;
    
    NSLog(@"Match failed with error: %@",error.localizedDescription);
    self.matchStarted = NO;
    if(self.delegate && [self.delegate respondsToSelector:@selector(matchEnded:)])
    {
        [self.delegate matchEnded:error];
    }
}


@end
