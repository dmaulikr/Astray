//
//  imageTile.m
//  Astray
//
//  Created by Matthew Ruston on 2/14/14.
//  Copyright (c) 2014 Matthew Ruston. All rights reserved.
//

#import "imageTile.h"

@implementation imageTile

-(id)initWithTexture:(SKTexture *)texture {
    self = [super initWithTexture:texture];
    if (self) {
        self.chunks = 1;
    }
    return self;
}

@end
