//
//  StartScene.m
//  Astray
//
//  Created by Matthew Ruston on 1/25/14.
//  Copyright (c) 2014 Matthew Ruston. All rights reserved.
//

#import "StartScene.h"
#import "HubScene.h"

@implementation StartScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.anchorPoint = CGPointMake(0.5,0.5);
        SKLabelNode *text = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        text.text = @"Start";
        [self addChild:text];
        
    }
    return self;
    
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    HubScene* myScene = [[HubScene alloc] initWithSize:self.size];
    // gameScene.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:myScene transition:[SKTransition fadeWithDuration:2.0]];
}


@end
