//
//  Torch.m
//  Astray
//
//  Created by Matthew Ruston on 2/23/14.
//  Copyright (c) 2014 Matthew Ruston. All rights reserved.
//

#import "Torch.h"
#import "Maze.h"

@implementation Torch

-(id)initWithTorchinMaze:(Maze*)thisMaze AtLocationX:(int)x Y:(int)y {
    self = [super initWithColor:[SKColor redColor] size:CGSizeMake(30, 50)];
    if (self) {
        [self placeTorchAtX:x andY:y inMaze:thisMaze];
        self.anchorPoint = CGPointMake(0.5, 0.5);
        [thisMaze loadTorchLightX:x Y:y];
    }
    return self;
}

-(void)placeTorchAtX:(int)TargetX andY:(int)TargetY inMaze:(Maze*)thisMaze {
    self.position = CGPointMake(-(thisMaze.SizeX*90/2)+90*(TargetX)+45,(thisMaze.SizeY*90/2-90)-90*(TargetY)+67.5);
    self.torchLocationX = TargetX;
    self.torchLocationY = TargetY;
    [self bringToLayer:thisMaze];
}

-(void)bringToLayer:(Maze*)thisMaze {
    //sets the character on the correct layer
    self.zPosition = thisMaze.SizeX*thisMaze.SizeY/2+thisMaze.SizeX+2+self.torchLocationY*(thisMaze.SizeX+3)-1;
}


@end
