//
//  Character.h
//  Astray
//
//  Created by Matthew Ruston on 1/27/14.
//  Copyright (c) 2014 Matthew Ruston. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Maze.h"

@interface Character : SKSpriteNode

//X location in the maze matrix
@property (nonatomic)int characterLocationX;
//Y location in the maze matrix
@property (nonatomic)int characterLocationY;
//If the character should be moving or not
@property (nonatomic)BOOL moving;
//Which way the character should be moving in the maze matrix
@property (nonatomic)int movingX;
@property (nonatomic)int movingY;
@property (nonatomic) BOOL actionRunning;
@property (nonatomic) BOOL done;

-(id)initWithCharacter:(int)characterType facing:(int)facing;
-(void)moveCharacterinDirectionX:(int)directionX andY:(int)directionY inMaze:(Maze*)thisMaze;
-(void)placeCharacterAtX:(int)TargetX andY:(int)TargetY inMaze:(Maze*)thisMaze;
-(void)bringToLayer:(Maze*)thisMaze;
-(void)moveCharacterinMaze:(Maze*)thisMaze;

@end
