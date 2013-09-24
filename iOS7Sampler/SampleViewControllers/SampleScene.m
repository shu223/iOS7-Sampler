//
//  SampleScene.m
//  iOS7Sampler
//
//  Created by shuichi on 9/24/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "SampleScene.h"


@interface SampleScene ()
{
    BOOL isAnimating;
}
@end


@implementation SampleScene

-(id)initWithSize:(CGSize)size {

    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    }
    return self;
}


// =============================================================================
#pragma mark - Private

- (void)addMonster {
    
    isAnimating = YES;
    
    NSUInteger num = arc4random() % 40 + 1;
    NSString *filename = [NSString stringWithFormat:@"m%lu", (unsigned long)num];
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:filename];
    
    int minY = 100;
    int maxY = self.frame.size.height - 100;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;

    monster.position = CGPointMake(-monster.size.width/2, actualY);
    [self addChild:monster];

    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    SKAction *actionMove = [SKAction moveTo:CGPointMake(self.frame.size.width + monster.size.width/2, actualY)
                                   duration:actualDuration];
    
    SKAction *actionMoveDone = [SKAction runBlock:^{
        
        [SKAction removeFromParent];
        
        isAnimating = NO;
    }];
    
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

- (void)update:(NSTimeInterval)currentTime {
    
    if (!isAnimating) {
        
        [self addMonster];
    }
}

@end
