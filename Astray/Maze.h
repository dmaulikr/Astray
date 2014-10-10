//
//  Maze.h
//  Astray
//
//  Created by Matthew Ruston on 1/25/14.
//  Copyright (c) 2014 Matthew Ruston. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Maze : SKSpriteNode

//X dimension of the maze
@property (nonatomic) int SizeX;
//Y dimension of the maze
@property (nonatomic) int SizeY;
//Which art and music will be used for the level
@property (nonatomic) int LevelType;
//The matrix that represents the maze
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic) int endX;
@property (nonatomic) int endY;
@property (nonatomic) int startX;
@property (nonatomic) int startY;

@property (nonatomic) CGPoint end;


-(id)initWithSize:(int)width by:(int)height andLevelType:(int)level;
-(id)initWithWorld:(int)world AndLevel:(int)level;
- (int)valueAtRow:(int)row andColumn:(int)col;
-(void)setAtRow:(int)row andColumn:(int)col value:(int)x;
-(void)loadLocationX:(int)x Y:(int)y;
-(void)unloadLocationX:(int)x Y:(int)y;
-(void)loadTorchLightX:(int)x Y:(int)y;

@end
