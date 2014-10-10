//
//  Character.m
//  Astray
//
//  Created by Matthew Ruston on 1/27/14.
//  Copyright (c) 2014 Matthew Ruston. All rights reserved.
//

#import "Character.h"
#import "Maze.h"
#import "HubScene.h"

@interface Character()

@end
@implementation Character

//Creates a character with a type (which skin) and a direction that the character is facing
-(id)initWithCharacter:(int)characterType facing:(int)facing {
    self = [super initWithImageNamed:[NSString stringWithFormat:@"character%iFacing%i",characterType,facing]];
    if (self) {
        self.position = CGPointMake(0, 0);
        self.anchorPoint = CGPointMake(0, 0);
        self.moving = NO;
        _actionRunning = NO;
        self.name = @"player1";
        _done = NO;
    }
    return self;
}

//This is what is run when we want the character to move
-(void)moveCharacterinMaze:(Maze*)thisMaze {
    if (self.moving == YES) {
        if (!(_actionRunning || _done)) {
            [self moveCharacterinDirectionX:self.movingX andY:self.movingY inMaze:thisMaze];
        }
    }
}

//this moves the character in the entered direction
-(void)moveCharacterinDirectionX:(int)directionX andY:(int)directionY inMaze:(Maze*)thisMaze {
    if ([thisMaze valueAtRow:(self.characterLocationX+directionX) andColumn:self.characterLocationY+directionY] < 17) {
        //this is where the character moves if possible
        self.characterLocationX = self.characterLocationX+directionX;
        self.characterLocationY = self.characterLocationY+directionY;
        CGPoint newLocation = CGPointMake(-(thisMaze.SizeX*90/2)+90*(self.characterLocationX),(thisMaze.SizeY*90/2-90)-90*(self.characterLocationY));
        _actionRunning = YES;
        
        if (self.characterLocationY == thisMaze.endY && self.characterLocationX == thisMaze.endX) {
            _done = YES;
        }
        
        [self runAction:[SKAction moveTo:newLocation duration:.6] completion:^{
            _actionRunning = NO;
            [self moveCharacterinMaze:thisMaze];
        }];
        
        [self bringToLayer:thisMaze];
        if (directionX != 0) {
            for (int y = self.characterLocationY-3; y <= self.characterLocationY+3; y++) {
                [thisMaze loadLocationX:self.characterLocationX+3*directionX Y:y];
                [thisMaze unloadLocationX:self.characterLocationX-4*directionX Y:y];
            }
        }
        if (directionY != 0) {
            for (int x = self.characterLocationX-3; x <= self.characterLocationX+3; x++) {
                [thisMaze loadLocationX:x Y:self.characterLocationY+3*directionY];
                [thisMaze unloadLocationX:x Y:self.characterLocationY-4*directionY];
            }
        }
    }
    else
    {
        //this is what happens if he cant move, for example, have them change how they are facing here.
    }
}

//this just sets the character's location
-(void)placeCharacterAtX:(int)TargetX andY:(int)TargetY inMaze:(Maze*)thisMaze {
    self.position = CGPointMake(-(thisMaze.SizeX*90/2)+90*(TargetX),(thisMaze.SizeY*90/2-90)-90*(TargetY));
    self.characterLocationX = TargetX;
    self.characterLocationY = TargetY;
    [self bringToLayer:thisMaze];
}

//this brings the character to the correct layer in the maze
-(void)bringToLayer:(Maze*)thisMaze {
    //sets the character on the correct layer
    self.zPosition = thisMaze.SizeX*thisMaze.SizeY/2+thisMaze.SizeX+2+self.characterLocationY*(thisMaze.SizeX+3);
}

@end
