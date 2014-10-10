//
//  backgroundTile.m
//  Astray
//
//  Created by Matthew Ruston on 2/12/14.
//  Copyright (c) 2014 Matthew Ruston. All rights reserved.
//

#import "backgroundTile.h"

@implementation backgroundTile

-(id)initWithTexture:(SKTexture *)texture {
    self = [super initWithTexture:texture];
    if (self) {
        self.chunks = 1;
    }
    return self;
}

-(int)getChunkNumber{
    return self.chunks;
}
-(void)setChunkNumber:(int)x{
    self.chunks = x;
}

@end
