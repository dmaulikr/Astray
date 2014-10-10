//
//  HubScene.m
//  Astray
//
//  Created by Matthew Ruston on 1/25/14.
//  Copyright (c) 2014 Matthew Ruston. All rights reserved.
//

#import "HubScene.h"
#import "MazeScene.h"
#import "Character.h"

@interface HubScene()

@property (strong) SKShapeNode *circleMask;
@property (strong) SKSpriteNode *circleDark;
@property (strong) SKCropNode *cropNode;
@property (strong) SKSpriteNode *BOX;

@end

@implementation HubScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor blackColor];
        self.anchorPoint = CGPointMake(0.5,0.5);
        
        
        //this will be the hub background
        _BOX = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1] size:CGSizeMake(320, 480)];
        _BOX.xScale = 1;
        _BOX.yScale = 1;
        _BOX.anchorPoint = CGPointMake(0.5, 0.5);
        _BOX.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        _BOX.name = @"THE BOX";
        //end of hub background
        
        _cropNode = [[SKCropNode alloc] init];
        SKNode *area = [[SKNode alloc] init];
        
        int x = 120; //radius of the circle 65
        
        _circleMask = [[SKShapeNode alloc ]init];
        CGMutablePathRef circle = CGPathCreateMutable();
        CGPathAddArc(circle, NULL, 0, 0, x/2, 0, M_PI*2, YES);
        _circleMask.path = circle;
        _circleMask.lineWidth = x*2;
        _circleMask.strokeColor = [SKColor whiteColor];
        _circleMask.name=@"circleMask";
        _circleMask.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        _circleDark = [SKSpriteNode spriteNodeWithImageNamed:@"menudark"];
        _circleDark.position = [_cropNode convertPoint:_circleMask.position fromNode:area];
        
        [area addChild:_circleMask];
        [_cropNode addChild:_BOX];
        [_cropNode addChild:_circleDark];
        [_cropNode setMaskNode:area];
        [self addChild:_cropNode];
        _cropNode.xScale = 1;
        _cropNode.yScale = 1;
        //end of darkness stuff
        
        SKSpriteNode *Level1Portal = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:CGSizeMake(200, 50)];
        Level1Portal.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+100);
        Level1Portal.anchorPoint = CGPointMake(0.5, 0.5);
        Level1Portal.name = @"B1";
        [_BOX addChild:Level1Portal];
        
        SKSpriteNode *Level2Portal = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0 green:0.4 blue:0 alpha:1] size:CGSizeMake(200, 50)];
        Level2Portal.anchorPoint = CGPointMake(0.5, 0.5);
        Level2Portal.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        Level2Portal.name = @"B2";
        [_BOX addChild:Level2Portal];
        
        SKSpriteNode *Level3Portal = [SKSpriteNode spriteNodeWithColor:[SKColor brownColor] size:CGSizeMake(200, 50)];
        Level3Portal.anchorPoint = CGPointMake(0.5, 0.5);
        Level3Portal.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-100);
        Level3Portal.name = @"B3";
        [_BOX addChild:Level3Portal];
        
        SKSpriteNode *NextLevelPortal = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:CGSizeMake(300, 50)];
        NextLevelPortal.anchorPoint = CGPointMake(0.5, 0.5);
        NextLevelPortal.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-200);
        NextLevelPortal.name = @"N";
        [_BOX addChild:NextLevelPortal];
        
    }
    return self;
    
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:_BOX];
    SKNode *node = [_BOX nodeAtPoint:location];
    
    if ([node.name characterAtIndex:0] == 'B') {
        
        MazeScene* myScene = [[MazeScene alloc] initWithSize:self.size andLevel:([[node.name substringWithRange:NSMakeRange(1, 1)] intValue]) andType:1];
        // gameScene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:myScene transition:[SKTransition fadeWithDuration:2.0]];

    }
    
    if ([node.name characterAtIndex:0] == 'N') {
        MazeScene* myScene = [[MazeScene alloc] initWithSize:self.size andLevel:1 andType:2];
        // gameScene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:myScene transition:[SKTransition fadeWithDuration:2.0]];
    }
}



@end
