//
//  backgroundTile.h
//  Astray
//
//  Created by Matthew Ruston on 2/12/14.
//  Copyright (c) 2014 Matthew Ruston. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface backgroundTile : SKSpriteNode

@property(nonatomic) int chunks;

-(int)getChunkNumber;
-(void)setChunkNumber:(int)x;

@end
