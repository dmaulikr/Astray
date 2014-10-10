//
//  Maze.m
//  Astray
//
//  Created by Matthew Ruston on 1/25/14.
//  Copyright (c) 2014 Matthew Ruston. All rights reserved.
//

#import "Maze.h"
#import "backgroundTile.h"
#import "imageTile.h"
//#import "Torch.h"
@interface Maze()

@property (strong,nonatomic) SKSpriteNode *floor;
@property (strong, nonatomic) SKTextureAtlas *images;

@end

@implementation Maze


-(id)initWithWorld:(int)world AndLevel:(int)level{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"World1Levels" ofType:@"txt"];
    NSString *filecontents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!(filecontents == nil)) {
        NSArray *lines = [filecontents componentsSeparatedByString:@"Level"];
        NSArray *rows = [[lines objectAtIndex:level] componentsSeparatedByString:@"\n"];
        self.SizeY = [rows count]-3;
        self.LevelType = world;
        self.SizeX = [[rows objectAtIndex:1] length];
        
        NSLog(@"X%i",self.SizeX);
        NSLog(@"Y%i",self.SizeY);
        
        self = [super initWithColor:[SKColor blackColor] size:CGSizeMake(self.SizeX*90, self.SizeY*90)];
        if (self) {
            _images = [SKTextureAtlas atlasNamed:[NSString stringWithFormat:@"Images%i",_LevelType]];
            
            //creates the data
            self.data = [[NSMutableArray alloc] init];
            
            //takes the level from the file and makes it an array
            for (int x = 0; x<self.SizeX; x++) {
                NSMutableArray *subArray = [[NSMutableArray alloc] init];
                for (int y = 1; y <= self.SizeY; y++) {
                    [subArray addObject:[NSNumber numberWithInt:[[[rows objectAtIndex:y] substringWithRange:NSMakeRange(x, 1)] intValue]]];
                }
                [self.data addObject:subArray];
            }
            
            //converts the original 0's to 17, for images generation
            for (int y = 0; y < self.SizeY; y++) {
                for (int x = 0; x < self.SizeX; x++) {
                    if ([self valueAtRow:x andColumn:y]==0) {
                        [self setAtRow:x andColumn:y value:17];
                    }
                    if ([self valueAtRow:x andColumn:y]==6) {
                        [self setAtRow:x andColumn:y value:60];
                    }
                    if ([self valueAtRow:x andColumn:y]==5) {
                        [self setAtRow:x andColumn:y value:40];
                    }
                }
            }
            
            _floor = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:self.size];
            _floor.position = self.position;
            _floor.zPosition = 0;
            [self addChild:_floor];
            
            //this should be changed since the start point should be in the file data, but just in case
            self.startX = 1;
            self.startY = 1;
            
            [self setMazeValues];
            [self loadSurroundingAreaX:self.startX Y:self.startY];
        }
    }
    return self;
}

//Generates a maze
-(id)initWithSize:(int)width by:(int)height andLevelType:(int)level {
    self = [super initWithColor:[SKColor blackColor] size:CGSizeMake(width*90, height*90)];
    if (self) {
        self.SizeX = width;
        self.SizeY = height;
        self.LevelType = level;
        
        _images = [SKTextureAtlas atlasNamed:[NSString stringWithFormat:@"Images%i",level]];
        
        //creates the data
        self.data = [[NSMutableArray alloc] init];
        
        //create array of 0's
        for (int i = 0; i < self.SizeX; i++) {
            NSMutableArray *subArray = [[NSMutableArray alloc] init];
            for (int j = 0; j < self.SizeY; j++) {
                [subArray addObject:[NSNumber numberWithInt:17]];
            }
            [self.data addObject:subArray];
        }
        
        //backtracking arrays in the maze gen
        //first values are the start points
        NSMutableArray *previousX = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:1]];
        NSMutableArray *previousY = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:1]];
        [self setAtRow:([previousX.lastObject integerValue]) andColumn:([previousY.lastObject integerValue]) value:1];
        
        //THIS PART DOES THE MAZE GENERATING
        //BLLLARGHHH I MADE THE ROWS AND COLUMNS FLIPPED. FIX THIS AT SOME POINT
        int best = 0;
        int bestX = 0;
        int bestY = 0;
        while (previousX.count > 0) {
            int o = 0;
            NSMutableArray *options = [[NSMutableArray alloc] init];
            while (o == 0 && previousX.count > 0) {
                [options removeAllObjects];
                int x = [previousX.lastObject integerValue];
                int y = [previousY.lastObject integerValue];
                o = 0;
                
                //checks possible directions
                if (x>1) {
                    if ([self valueAtRow:(x-2) andColumn:y] == 17) {
                        [options addObject:[NSNumber numberWithInt:1]];
                        o++;
                    }
                }
                
                if (x<(self.SizeX-2)) {
                    if ([self valueAtRow:(x+2) andColumn:y] == 17) {
                        [options addObject:[NSNumber numberWithInt:2]];
                        o++;
                    }
                }
                
                if (y>1) {
                    if ([self valueAtRow:x andColumn:(y-2)] == 17) {
                        [options addObject:[NSNumber numberWithInt:3]];
                        o++;
                    }
                }
                
                if (y<(self.SizeY-2)) {
                    if ([self valueAtRow:x andColumn:(y+2)] == 17) {
                        [options addObject:[NSNumber numberWithInt:4]];
                        o++;
                    }
                }
                NSLog(@"GOOD CHECK %d",o);
                //end of checking
                
                //if there were no possibilities, it removes the previous spot
                if (o == 0) {
                    if (best < (previousX.count)) {
                        best = previousX.count;
                        bestY = [previousY.lastObject integerValue];
                        bestX = [previousX.lastObject integerValue];
                        
                    }
                    [previousX removeLastObject];
                    [previousY removeLastObject];
                    NSLog(@"(%ld,%ld)",(long)[previousX.lastObject integerValue],(long)[previousY.lastObject integerValue]);
                }
            }
            
            //if there were possible locations
            if (o > 0) {
                //randomly chooses one of them
                int r = arc4random() % o;
                o = [[options objectAtIndex:r] integerValue];
                int ChangeinX = 0;
                int ChangeinY = 0;
                
                //sets the new location and stores it as the previous value
                switch (o) {
                    case 1:
                        ChangeinX = -1;
                        break;
                    case 2:
                        ChangeinX = 1;
                        break;
                    case 3:
                        ChangeinY = -1;
                        break;
                    case 4:
                        ChangeinY = 1;
                        break;
                        
                    default:
                        NSLog(@"FAILED SET NEW LOCATION");
                        break;
                }
                //changes maze data values
                //paths are 1's and walls are 17's
                [self setAtRow:([previousX.lastObject integerValue]+ChangeinX) andColumn:([previousY.lastObject integerValue]+ChangeinY) value:1];
                [previousX addObject:[NSNumber numberWithInt:([previousX.lastObject integerValue]+(2*ChangeinX))]];
                [previousY addObject:[NSNumber numberWithInt:([previousY.lastObject integerValue]+(2*ChangeinY))]];
                [self setAtRow:([previousX.lastObject integerValue]) andColumn:([previousY.lastObject integerValue]) value:1];
            }
            
        }
        //HERE ENDS THE MAZE GENERATING
        NSLog(@"YOU DID IT!!");
        
        SKSpriteNode *end = [SKSpriteNode spriteNodeWithColor:[SKColor purpleColor] size:CGSizeMake(90, 90)];
        end.position = CGPointMake(-(self.SizeX*90/2)+90*(bestX),(self.SizeY*90/2-90)-90*(bestY));
        end.anchorPoint = CGPointMake(0, 0);
        end.zPosition = [self GetLayerAtLocationInMazeX:bestX Y:bestY For:0]+1;
        [self addChild:end];
        
        _endX = bestX;
        _endY = bestY;
        _end = end.position;

        _floor = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:self.size];
        _floor.position = self.position;
        _floor.zPosition = 0;
        [self addChild:_floor];
        
        self.startX = 1;
        self.startY = 1;
        
        [self setMazeValues];
        [self loadSurroundingAreaX:1 Y:1];
    }
    return self;
}

//finds the values in a matrix
-(int)valueAtRow:(int)row andColumn:(int)col {
    NSMutableArray *subArray = [self.data objectAtIndex:row];
    return [[subArray objectAtIndex:col] intValue];
}

//sets the values in a matrix
-(void)setAtRow:(int)row andColumn:(int)col value:(int)x {
    NSMutableArray *subArray = [self.data objectAtIndex:row];
    [subArray replaceObjectAtIndex:col withObject:[NSNumber numberWithInt:x]];
}

-(void)loadLocationX:(int)x Y:(int)y{
    if ((x >= 0) && (y >= 0) && (x < self.SizeX) && (y < self.SizeY)) {
        int locationValue = [self valueAtRow:x andColumn:y];
        if ([self childNodeWithName:[NSString stringWithFormat:@"Object%i,%i",x,y]]){
            imageTile *tile = [self childNodeWithName:[NSString stringWithFormat:@"Object%i,%i",x,y]];
            tile.chunks++;
        }else{
            if (locationValue>60 && locationValue<80) {
                //there is a door here
                imageTile *door = [[imageTile alloc] initWithTexture:[_images textureNamed:@"Door1-1"]];
                door.position = CGPointMake(-(self.SizeX*90/2)+90*(x),(self.SizeY*90/2-90)-90*(y));
                door.anchorPoint = CGPointMake(0, 0);
                door.zPosition = [self GetLayerAtLocationInMazeX:x Y:y For:1];
                [self addChild:door];
                locationValue -= 60;
                NSLog(@"%i",locationValue);
            }
            if (locationValue>40 && locationValue<60) {
                //there is a chest here
                SKTexture *crate = [SKTexture textureWithImageNamed:@"crate"];
                imageTile *chest = [[imageTile alloc] initWithTexture:crate];
                chest.position = CGPointMake(-(self.SizeX*90/2)+90*(x)+45,(self.SizeY*90/2-90)-90*(y)+45);
                chest.anchorPoint = CGPointMake(0.5, 0.5);
                chest.zPosition = [self GetLayerAtLocationInMazeX:x Y:y For:1];
                [self addChild:chest];
                locationValue -= 40;
                //make sure it doesnt keep loading more and more crates on one spot(fix this when i get an actual texture and can make it a tile object)
            }
            if (locationValue > 17) {
//                imageTile *wall = [[imageTile alloc] initWithImageNamed:[NSString stringWithFormat:@"Wall%i-%i",self.LevelType,[self valueAtRow:x andColumn:y]]];
                imageTile *wall = [[imageTile alloc] initWithTexture:[_images textureNamed:[NSString stringWithFormat:@"Wall%i-%i",self.LevelType,locationValue]]];
                //([self valueAtRow:x andColumn:y]-20)
                wall.position = CGPointMake(-(self.SizeX*90/2)+90*(x),(self.SizeY*90/2-90)-90*(y));
                wall.anchorPoint = CGPointMake(0, 0);
                wall.zPosition = [self GetLayerAtLocationInMazeX:x Y:y For:1];
                wall.name = [NSString stringWithFormat:@"Object%i,%i",x,y];
                [self addChild:wall];
            }
            if (locationValue < 17) {
                imageTile *path = [[imageTile alloc] initWithTexture:[_images textureNamed:[NSString stringWithFormat:@"Path%i-%i",self.LevelType,locationValue]]];
                path.position = CGPointMake(-(self.SizeX*90/2)+90*(x)+45,(self.SizeY*90/2-90)-90*(y)+45);
                path.anchorPoint = CGPointMake(0.5, 0.5);
                path.zPosition = [self GetLayerAtLocationInMazeX:x Y:y For:2];
                path.name = [NSString stringWithFormat:@"Object%i,%i",x,y];
                [self addChild:path];
            }
        }

        if ([self childNodeWithName:[NSString stringWithFormat:@"Object%i,%i",x,y]]) {
            x = (x + 3)/6;
            y = (y + 3)/6;
            
            if ([_floor childNodeWithName:[NSString stringWithFormat:@"Tile%i,%i",x,y]]){
                backgroundTile *tile = [_floor childNodeWithName:[NSString stringWithFormat:@"Tile%i,%i",x,y]];
                tile.chunks++;
            }else{
                backgroundTile *backtile = [[backgroundTile alloc] initWithTexture:[_images textureNamed:[NSString stringWithFormat:@"Background%i",self.LevelType]]];
                backtile.position = CGPointMake(-(self.SizeX*90/2)+540*(x),(self.SizeY*90/2)-540*(y));
                backtile.anchorPoint = CGPointMake(0.5, 0.5);
                backtile.name = [NSString stringWithFormat:@"Tile%i,%i",x,y];
                [_floor addChild:backtile];
            }
        }
    }
}

-(void)unloadLocationX:(int)x Y:(int)y{
    if ([self childNodeWithName:[NSString stringWithFormat:@"Object%i,%i",x,y]]) {
        imageTile *tile = [self childNodeWithName:[NSString stringWithFormat:@"Object%i,%i",x,y]];
        tile.chunks--;
        if (tile.chunks <= 0) {
            [[self childNodeWithName:[NSString stringWithFormat:@"Object%i,%i",x,y]] removeFromParent];
        }
        x = (x + 3)/6;
        y = (y + 3)/6;
        backgroundTile *backtile = [_floor childNodeWithName:[NSString stringWithFormat:@"Tile%i,%i",x,y]];
        backtile.chunks--;
        if (backtile.chunks <= 0) {
            [[_floor childNodeWithName:[NSString stringWithFormat:@"Tile%i,%i",x,y]] removeFromParent];
        }
    }
}

-(void)loadSurroundingAreaX:(int)x Y:(int)y{
    for (int t = y-3; t <= y+3; t++) {
        for (int z = x-3; z <= x+3; z++) {
            [self loadLocationX:z Y:t];
        }
    }
}

-(void)loadTorchLightX:(int)x Y:(int)y{
    for (int t = y-2; t <= y+2; t++) {
        for (int z = x-2; z <= x+2; z++) {
            [self loadLocationX:z Y:t];
        }
    }
}

//only run this once
//values 2-16 are paths
//values 20-35 are walls
//initial walls are 17
//initial paths are still 1
-(void)setMazeValues{
    NSLog(@"End");
    for (int y = 0; y < self.SizeY; y++) {
        for (int x = 0; x < self.SizeX; x++) {
            //if it is a wall
            if ([self valueAtRow:x andColumn:y] == 17) {
                [self setAtRow:x andColumn:y value:[self CountWallNumberForX:x Y:y]];
            }
            else if ([self valueAtRow:x andColumn:y] == 1) {
                [self setAtRow:x andColumn:y value:[self CountPathNumberForX:x Y:y]];
            }
            else if ([self valueAtRow:x andColumn:y] == 2){
                //journal location
            }
            else if ([self valueAtRow:x andColumn:y] == 3){
                //starting location
                self.startX = x;
                self.startY = y;
                //create normal path for now...
                [self setAtRow:x andColumn:y value:[self CountPathNumberForX:x Y:y]];
                    
            }
            else if ([self valueAtRow:x andColumn:y] == 4){
                //ending location
                [self setAtRow:x andColumn:y value:-1];
            }
            else if ([self valueAtRow:x andColumn:y] == 40){
                //key location(chest)
                [self setAtRow:x andColumn:y value:([self CountPathNumberForX:x Y:y]+40)];
            }
            else if ([self valueAtRow:x andColumn:y] == 60){
                //door location
                [self setAtRow:x andColumn:y value:([self CountPathNumberForX:x Y:y]+60)];
            }
        }
    }
}

//make sure this is counting chests and things as the correct objects
//make sure chest spots count as paths
//make sure doors count as both
-(int)CountWallNumberForX:(int)x Y:(int)y {
    int whichWall = 0;
    int offset = 0;
    if (self.LevelType<3) {
        whichWall = 20;
        if (x>=1) {
            offset = [self valueAtRow:(x-1) andColumn:(y)];
            if (offset < 17 || (offset >= 42 && offset <= 56)) {
                whichWall++;
            }
        }else{
            whichWall++;
        }
        if (x<(self.SizeX-1)) {
            offset = [self valueAtRow:(x+1) andColumn:(y)];
            NSLog(@"%i",offset);
            if (offset < 17 || (offset >=42 && offset <= 56)) {
                whichWall += 2;
            }
        }else{
            whichWall += 2;
        }
        if (y<(self.SizeY-1) && whichWall == 23) {
            offset = [self valueAtRow:x andColumn:(y+1)];
            if (offset >= 17 && !(offset >=42 && offset <= 56)) {
                whichWall = 24;
            }
        }
        
    }else if (self.LevelType == 3) {
        whichWall = 19;
        if (x>0) {
            if ([self valueAtRow:(x-1) andColumn:y] >= 17) {
                whichWall+=8;
            }
        }
        
        if (x<(self.SizeX-1)) {
            if ([self valueAtRow:(x+1) andColumn:y] >= 17) {
                whichWall+=2;
            }
        }
        
        if (y>0) {
            if ([self valueAtRow:x andColumn:(y-1)] >= 17) {
                whichWall+=1;
            }
        }
            
        if (y<(self.SizeY-1)) {
            if ([self valueAtRow:x andColumn:(y+1)] >= 17) {
                whichWall+=4;
            }
        }
    }
    
    return whichWall;
}

-(int)CountPathNumberForX:(int)x Y:(int)y {
    int pathCount = 1;
    int offset = 0;
    if (x>0) {
        offset = [self valueAtRow:x-1 andColumn:y];
        if (offset < 17 || offset >= 42) {
            pathCount+=8;
        }
    }
    
    if (x<(self.SizeX-1)) {
        offset = [self valueAtRow:(x+1) andColumn:y];
        if (offset < 17 || offset >=42) {
            pathCount+=2;
        }
    }
    
    if (y>0) {
        offset = [self valueAtRow:x andColumn:(y-1)];
        if (offset < 17 || offset >=42) {
            pathCount+=1;
        }
    }
    
    if (y<(self.SizeY-1)) {
        offset = [self valueAtRow:x andColumn:y+1];
        if (offset < 17 || offset >=42) {
            pathCount+=4;
        }
    }
    return  pathCount;
}

-(int)GetLayerAtLocationInMazeX:(int)x Y:(int)y For:(int)type {
    int layer = 0;
    
    //type 0 means it chooses
    //1 means for a wall type object
    //2 means for a path type object
    
    if (type == 0) {
        if ([self valueAtRow:x andColumn:y] >= 17) {
            layer = self.SizeX*self.SizeY/2 + (y*(self.SizeX+3))+x;
        }
        if ([self valueAtRow:x andColumn:y] < 17) {
            layer = 1 +(y*(self.SizeX))+x;
            //layer = -1;
        }
    }else if (type == 1){
        layer = self.SizeX*self.SizeY/2 + (y*(self.SizeX+3))+x;
    }else if (type == 2){
        layer = 1 +(y*(self.SizeX))+x;
    }

    return layer;
}

@end
