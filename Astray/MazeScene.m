//
//  MyScene.m
//  Astray
//
//  Created by Matthew Ruston on 1/25/14.
//  Copyright (c) 2014 Matthew Ruston. All rights reserved.
//

#import "MazeScene.h"
#import "Maze.h"
#import "Character.h"
#import "Torch.h"
#import "HubScene.h"
#import <AVFoundation/AVFoundation.h>
@import AVFoundation;
@interface MazeScene()

//the cropnode that contains everything that will be affected by the mask
@property (nonatomic,strong) SKCropNode *cropNode;

//the area that acts as a mask to the scene
@property (nonatomic,strong) SKNode *area;

//How zoomed in are we? this is used to generate things that need to have a constant size
@property (nonatomic) double currentScale;

//this is the maze that was generated in the scene
@property (strong, nonatomic) Maze *myMaze;

//this is the player, obviously
@property (strong, nonatomic) Character *player;

//where are you touching and where were you touching, used in the long press to see if the player moved their touch far enough to do anything
@property (nonatomic) CGPoint touchLocation;
@property (nonatomic) CGPoint previousLocation;

//this is the circle that goes over the player that asks as a mask, making it dark everywhere else
@property (strong, nonatomic) SKShapeNode *circleMask;

//This is the shaded circle i currently have around the player to make it look nicer
@property (strong, nonatomic) SKSpriteNode *circleDark;


//The camera that the view is centered on
@property (nonatomic, strong) SKNode *camera;
//another camera, this one jumps around while the actual camera smoothly tries to match up with it
@property (nonatomic, strong) SKNode *smoothCamera;

//if the view is "unlocked", basically if camera is locked to the player or not
@property (nonatomic) BOOL unlocked;

//the audio player
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;

//how far in can we zoom?
@property (nonatomic) float MaxZoomX;
@property (nonatomic) float MaxZoomY;

//Is the hud showing or not?
@property (nonatomic) BOOL hud;

//If something was pressed (used under longerpress to see what nodes were touched, and if hud should hide)
@property (nonatomic) BOOL pressedSomething;

//Gesture recognizers
@property (nonatomic, strong) UILongPressGestureRecognizer *pressing;
@property (nonatomic, strong) UITapGestureRecognizer *threeFingerPress;
@property (nonatomic, strong) UIPinchGestureRecognizer *precog;

@property (nonatomic) BOOL ending;

@end

@implementation MazeScene

//When this scene loads
//type is if it is loaded from data or if it is randomly generated
-(id)initWithSize:(CGSize)size andLevel:(int)level andType:(int)type{
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        NSLog(@"Level%i",level);
        _ending = NO;
        self.MaxZoomX = self.size.width;
        self.MaxZoomY = self.size.height;
        self.backgroundColor = [SKColor blackColor];
        self.anchorPoint = CGPointMake(0.5,0.5);
        _unlocked = NO;
        _hud = NO;
        _currentScale = 1;

        if (type == 1) {
            _myMaze = [[Maze alloc]initWithSize:(((level*11)%2 == 1) ? (level*11) : (level*11+1)) by:(((level*11)%2 == 1) ? (level*11) : (level*11+1)) andLevelType:level];
        }else if (type == 2) {
            _myMaze = [[Maze alloc] initWithWorld:1 AndLevel:1];
        }
        _myMaze.xScale = .7;
        _myMaze.yScale = .7;
        _myMaze.zPosition = -1000;
        
        //Darkness stuff
        _cropNode = [[SKCropNode alloc] init];
        _area = [[SKNode alloc] init];
        _area.name = @"area";
        
        int x = 65; //radius of the circle 65
        
        _circleMask = [[SKShapeNode alloc ]init];
        CGMutablePathRef circle = CGPathCreateMutable();
        CGPathAddArc(circle, NULL, 0, 0, x/2, 0, M_PI*2, YES);
        _circleMask.path = circle;
        _circleMask.lineWidth = x*2;
        _circleMask.strokeColor = [SKColor whiteColor];
        _circleMask.name=@"circleMask";
        _circleMask.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        _circleDark = [SKSpriteNode spriteNodeWithImageNamed:@"2"];
        _circleDark.position = [_cropNode convertPoint:_circleMask.position fromNode:_area];

        [_area addChild:_circleMask];
        [_cropNode addChild:_myMaze];
        [_cropNode addChild:_circleDark];
        [_cropNode setMaskNode:_area];
        [self addChild:_cropNode];
        _cropNode.xScale = 1;
        _cropNode.yScale = 1;
        //end of darkness stuff
        
        //Make sure to change it so that a character type is entered and a direction is found
        _player = [[Character alloc]initWithCharacter:1 facing:1];
        [_player placeCharacterAtX:_myMaze.startX andY:_myMaze.startY inMaze:_myMaze];
        [_myMaze addChild:_player];
        
        
        //add the camera to the scene
        _camera = [SKNode node];
        _smoothCamera = [SKNode node];
        _camera.name = @"camera";
        //_camera.position = CGPointMake(_character.position.x + _character.size.width/2, _character.position.y + _character.size.height/2);
        _camera.position = CGPointMake(0, 0);
        _smoothCamera.position = self.camera.position;
        [_cropNode addChild:self.smoothCamera];
        [_cropNode addChild:self.camera];
        _cropNode.name = @"CropNode";
        
        
        
        NSError *error;
        NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"Music%i",_myMaze.LevelType] withExtension:@"wav"];
        self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        self.backgroundMusicPlayer.numberOfLoops = -1;
        [self.backgroundMusicPlayer prepareToPlay];
        [self.backgroundMusicPlayer play];
        
    }
    return self;

}



//Tells which way the character should move
// Michael says what's up brah
-(void)setMovementValuesWithPreviousPoint:(CGPoint)previous andCurrent:(CGPoint)current {
    _player.movingX = 0;
    _player.movingY = 0;
    NSNumber* up = [NSNumber numberWithFloat:(previous.y-current.y)];
    NSNumber* down = [NSNumber numberWithFloat:(current.y - previous.y)];
    NSNumber* left = [NSNumber numberWithFloat:(previous.x - current.x)];
    NSNumber* right = [NSNumber numberWithFloat:(current.x-previous.x)];
    NSMutableArray *numbers = [NSMutableArray arrayWithObjects:up,down,left,right, nil];
    NSNumber* max = [numbers valueForKeyPath:@"@max.floatValue"];
   // NSLog(@"%@",up);
   // NSLog(@"%@",left);
    if ([max isEqualToNumber:up]) {
      //  NSLog(@"UP");
        _player.movingY = -1;
    }else if ([max isEqualToNumber:down]){
      //  NSLog(@"DOWN");
        _player.movingY = 1;
    }else if ([max isEqualToNumber:left]){
       // NSLog(@"LEFT");
        _player.movingX = -1;
    }else if ([max isEqualToNumber:right]){
       // NSLog(@"RIGHT");
        _player.movingX = 1;
    }
}

//UIGesture Handlers
- (void)didMoveToView:(SKView *)view {
//    //When the user long presses (for movement)
    _pressing = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _pressing.minimumPressDuration = 0;
    _pressing.allowableMovement = 10;
    [view addGestureRecognizer:_pressing];
    
    
    //when the user pans
//    UIPanGestureRecognizer *panning = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//    [self.scene.view addGestureRecognizer:panning];
    
    _threeFingerPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeUnlockedValue:)];
    _threeFingerPress.numberOfTouchesRequired = 2;
    _threeFingerPress.numberOfTapsRequired = 2;
    [view addGestureRecognizer:_threeFingerPress];
    
    //When the user pinches the screen
    _precog = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    _precog.cancelsTouchesInView = YES;
    [view addGestureRecognizer:_precog];
}

//MAKE SURE TO REMOVE THE GESTURE RECOGNIZERS HERE
-(void)willMoveFromView:(SKView *)view{
    [view removeGestureRecognizer:_pressing];
    [view removeGestureRecognizer:_threeFingerPress];
    [view removeGestureRecognizer:_precog];
    
}

-(void) changeUnlockedValue:(UITapGestureRecognizer *)recognizer{
    if (UIGestureRecognizerStateEnded == recognizer.state) {
       // NSLog(@"OK");
        _unlocked = !_unlocked;
       // NSLog(@"%hhd",_unlocked);
    }
}

//Panning
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    if (_unlocked) {
       // NSLog(@"Panning");
        CGPoint translation = [recognizer translationInView:self.view];
        _smoothCamera.position = CGPointMake(_smoothCamera.position.x - (translation.x/_currentScale), _smoothCamera.position.y + (translation.y/_currentScale));
        [_camera runAction:[SKAction moveTo:_smoothCamera.position duration:0.8]];
        //    recognizer.view.center = CGPointMake(recognizer.view.center.y - translation.x,
        //                                         recognizer.view.center.x - translation.y);
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    }
}

//Running the Character's Movement
-(void)handleLongPress:(UILongPressGestureRecognizer*) recognizer {
    CGPoint location = [recognizer locationInView:recognizer.view];
    location = [self.view convertPoint:location toScene:self.scene];
    
    if (!_unlocked) {
        switch (recognizer.state) {
            case UIGestureRecognizerStateBegan:
            {
                _pressedSomething = NO;
                _player.moving = YES;
                _previousLocation = [recognizer locationInView:self.view];
                _touchLocation = _previousLocation;
                //_previousLocaiton = [self.scene convertPoint:[self.view convertPoint:[recognizer locationInView:self.view] toScene:self.scene] toNode:_cropNode];
                break;
            }
            case UIGestureRecognizerStateChanged:
            {
                _touchLocation = [recognizer locationInView:self.view];
                
                if ((ABS(_touchLocation.x-_previousLocation.x) > 30) || (ABS(_touchLocation.y-_previousLocation.y) > 30)) {
                    [self setMovementValuesWithPreviousPoint:_previousLocation andCurrent:_touchLocation];
                    [_player moveCharacterinMaze:_myMaze];
                    _previousLocation = _touchLocation;
                    _pressedSomething = YES;
                    if (_hud) {
                        [self hideHud];
                        _hud = NO;
                    }
                }
                
            }
                break;
            case UIGestureRecognizerStateEnded:
            {
                NSLog(@"Scale: %f",_currentScale);
                _player.moving = NO;
                NSMutableArray *nodes = [NSMutableArray arrayWithArray:[self nodesAtPoint:location]];
                if ([nodes count]>0) {
                    [nodes removeObject:_cropNode];
                    SKNode *node = [nodes objectAtIndex:0];
                    if ([node.name characterAtIndex:0] == 'B') {
                        [self performSelector:NSSelectorFromString(node.name)];
                        _pressedSomething = YES;
                    }
                    
                }
                if (!_pressedSomething) {
                    if (_hud) {
                        [self hideHud];
                    }else{
                        [self showHud];
                    }
                    _hud = !_hud;
                }
                break;
            }
            case UIGestureRecognizerStateCancelled:
            {
                _player.moving = NO;
                break;
            }
            default:
                break;
        }
    }
}

-(void)BPlaceTorch{
    if (![_myMaze childNodeWithName:[NSString stringWithFormat:@"torch%i,%i",_player.characterLocationX,_player.characterLocationY]]) {
        NSLog(@"TORCH PLACED");
        Torch *torch = [[Torch alloc]initWithTorchinMaze:_myMaze AtLocationX:_player.characterLocationX Y:_player.characterLocationY];
        torch.name = [NSString stringWithFormat:@"torch%i,%i",_player.characterLocationX,_player.characterLocationY];
        [_myMaze addChild:torch];
        
        int x = 65; //radius of the circle 65
        
        SKShapeNode *circleMask = [[SKShapeNode alloc ]init];
        CGMutablePathRef circle = CGPathCreateMutable();
        CGPathAddArc(circle, NULL, 0, 0, x/2, 0, M_PI*2, YES);
        circleMask.path = circle;
        circleMask.lineWidth = x*2;
        circleMask.strokeColor = [SKColor whiteColor];
        circleMask.name =[NSString stringWithFormat:@"LightCircle%i,%i",_player.characterLocationX,_player.characterLocationY];
        circleMask.position = [_myMaze convertPoint:torch.position toNode:_cropNode];
        [_area addChild:circleMask];
    }
}

-(void)BMenu{
    HubScene* hub = [[HubScene alloc] initWithSize:CGSizeMake(_MaxZoomX, _MaxZoomY)];
    //hub.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:hub transition:[SKTransition fadeWithDuration:2.0]];
}

//THE BUTTONS
-(void)hideHud{
    [[self childNodeWithName:@"BPlaceTorch"] runAction:[SKAction fadeOutWithDuration:.3] completion:^{
        [[self childNodeWithName:@"BPlaceTorch"]removeFromParent];
    }];
    [[self childNodeWithName:@"BMenu"] runAction:[SKAction fadeOutWithDuration:.3] completion:^{
        [[self childNodeWithName:@"BMenu"]removeFromParent];
    }];
    
}

//THE BUTTONS
-(void)showHud{
    SKSpriteNode *torches = [SKSpriteNode spriteNodeWithColor:[SKColor darkGrayColor] size:CGSizeMake(70*_currentScale, 70*_currentScale)];
    torches.name = @"BPlaceTorch";
    torches.position = CGPointMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame));
    torches.anchorPoint = CGPointMake(0, 0);
    torches.zPosition = 1;
    torches.alpha = 0;
    [self addChild:torches];
    
    SKSpriteNode *menu = [SKSpriteNode spriteNodeWithColor:[SKColor darkGrayColor] size:CGSizeMake(70*_currentScale, 70*_currentScale)];
    menu.name = @"BMenu";
    menu.position = CGPointMake(CGRectGetMaxX(self.frame), CGRectGetMinY(self.frame));
    menu.anchorPoint = CGPointMake(1, 0);
    menu.zPosition = 1;
    menu.alpha = 0;
    [self addChild:menu];
    [menu runAction:[SKAction fadeInWithDuration:.3]];
    [torches runAction:[SKAction fadeInWithDuration:.3]];
    
}

//Zooming
- (void)handlePinch:(UIPinchGestureRecognizer *) recognizer {
    //NSLog(@"Pinch %f", recognizer.scale);
    //[_bg setScale:recognizer.scale];
    
    self.scaleMode = SKSceneScaleModeAspectFill;
    self.size = CGSizeMake(self.size.width + (1-recognizer.scale)*self.size.width, self.size.height + (1-recognizer.scale)*self.size.height);
    NSLog(@"%f",self.size.width);
    if (self.size.width < self.MaxZoomX) {
        self.size = CGSizeMake(self.MaxZoomX, self.MaxZoomY);
    }
    if (recognizer.scale != 1) {
        NSLog(@"REC%f",self.scene.size.width);
        //THIS NEEDS TO CHANGE, shouldnt have constant 320, should be grabbed from somewhere
        _currentScale = (self.size.width/320);
    }
    [self hideHud];
    _hud = NO;
    
    recognizer.scale = 1;
}

//Centering code
- (void) centerOnNode: (SKNode *) node {
    CGPoint characterPositionInScene = [node.scene convertPoint:node.position fromNode:node.parent];
    node.parent.position = CGPointMake(node.parent.position.x - characterPositionInScene.x, node.parent.position.y - characterPositionInScene.y);
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    //centering on the character
    if (_player.done && !_player.actionRunning && !_ending) {
        _ending = YES;
        [self BMenu];
    }
    _camera.position = [_myMaze convertPoint:CGPointMake(_player.position.x + _player.size.width/2, _player.position.y + _player.size.height/2) toNode:_cropNode];
    _circleMask.position = [_myMaze convertPoint:CGPointMake(_player.position.x + _player.size.width/2, _player.position.y + _player.size.height/2) toNode:_cropNode];
    _circleDark.position = _circleMask.position;
    [self centerOnNode: [_cropNode childNodeWithName:@"camera"]];
}


@end
