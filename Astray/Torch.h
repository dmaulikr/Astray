//
//  Torch.h
//  Astray
//
//  Created by Matthew Ruston on 2/23/14.
//  Copyright (c) 2014 Matthew Ruston. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class Maze;

@interface Torch : SKSpriteNode

//X location in the maze matrix
@property (nonatomic)int torchLocationX;
//Y location in the maze matrix
@property (nonatomic)int torchLocationY;

-(id)initWithTorchinMaze:(Maze*)thisMaze AtLocationX:(int)x Y:(int)y;

@end
