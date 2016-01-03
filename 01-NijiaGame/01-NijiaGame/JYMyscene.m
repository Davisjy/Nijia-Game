//
//  JYMyscene.m
//  01-NijiaGame
//
//  Created by qingyun on 15/12/31.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "JYMyscene.h"

@interface JYMyscene ()
{
    SKSpriteNode *_player;
    NSMutableArray *_monsters;
    NSMutableArray *_projectiles;
}
@end

@implementation JYMyscene
- (instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        _monsters = [NSMutableArray array];
        _projectiles = [NSMutableArray array];
        
        self.backgroundColor = [SKColor whiteColor];
        // 1.添加忍者
        SKSpriteNode *player = [[SKSpriteNode alloc] initWithImageNamed:@"player"];
        _player = player;
        // 2.设置忍着的位置
        player.position = CGPointMake(player.frame.size.width * 0.5 , self.frame.size.height * 0.5);
        // 3.添加到当前场景
        [self addChild:player];
        
        // 4.添加妖怪
        SKAction *addAction = [SKAction runBlock:^{
            [self addMonster];
        }];
        
        // 添加妖怪前要等待一秒否则一直执行不会出现预想效果
        SKAction *wait = [SKAction waitForDuration:1.0];
        // 创建序列行为
        SKAction *sequence = [SKAction sequence:@[addAction, wait]];
        
        SKAction *repeate = [SKAction repeatActionForever:sequence];
        [self runAction:repeate];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        [self addProjectile:location];
        
        SKAction *sound = [SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO];
        [self runAction:sound];
    }
}

#pragma mark - 添加子弹
- (void)addProjectile:(CGPoint)location
{
    // 1. 实例化子弹
    SKSpriteNode *projectitl = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
    
    // 2. 设置子弹运动轨迹
    CGPoint from = CGPointMake(_player.size.width + projectitl.size.width * 0.5, self.size.height * 0.5);
    // 1) x轴飞行的距离
    CGFloat x = self.size.width + projectitl.size.width / 2.0 - from.x;
    // 2) 计算便宜点
    CGPoint offset = CGPointMake(location.x - from.x, location.y - from.y);
    // 3) 限制只允许向屏幕右侧发射飞镖
    if (offset.x <= 0) return;
    
    // 4) y轴计算飞行的距离
    CGFloat y = offset.y / offset.x * x + from.y;
    // 5) 生成目标飞行点
    CGPoint to = CGPointMake(x, y);
    
    // 3. 添加子弹
    projectitl.position = from;
    [self addChild:projectitl];
    [_projectiles addObject:projectitl];
    
    // 计算时间
    // 速度是恒定的
    CGFloat velocity = self.size.width;
    CGPoint d = CGPointMake(to.x - from.x, to.y - from.y);
    CGFloat dis = sqrtf(d.x * d.x + d.y * d.y);
    
    NSTimeInterval duration = dis / velocity;
    // 4. 移动
    SKAction *move = [SKAction moveTo:to duration:duration];
    [projectitl runAction:move completion:^{
        [projectitl removeFromParent];
        [_projectiles removeObject:projectitl];
    }];

}

#pragma mark - 添加妖怪
- (void)addMonster
{
    // 1.实例化一个妖怪
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    
    // 2.设置位置
    CGFloat x = self.frame.size.width + monster.size.width * 0.5;
    CGFloat maxY = self.frame.size.height - monster.size.height;
    CGFloat y = arc4random_uniform(maxY) + monster.size.height * 0.5;
    monster.position = CGPointMake(x, y);
    
    // 3.添加到当前场景
    [self addChild:monster];
    [_monsters addObject:monster];
    
    // 4.移动妖怪
    NSTimeInterval duration = arc4random_uniform(3) + 2.0;
    SKAction *move = [SKAction moveToX:-monster.size.width * 0.5 duration:duration];
    [monster runAction:move completion:^{
        [monster removeFromParent];
        [_monsters removeObject:monster];
    }];
}

// 场景每次渲染时都会调用
- (void)update:(NSTimeInterval)currentTime
{
    NSMutableSet *proSet = [NSMutableSet set];
    
    for (SKSpriteNode *projectiel in _projectiles) {
        
        NSMutableSet *monsSet = [NSMutableSet set];
        
        for (SKSpriteNode *monster in _monsters) {
            
            if (CGRectIntersectsRect(projectiel.frame, monster.frame)) {
                
                [monsSet addObject:monster];
            }
        }
        
        for (SKSpriteNode *monster in monsSet) {
            [_monsters removeObject:monster];
            SKAction *rotate = [SKAction rotateToAngle:-M_PI_2 duration:0.1];
            [monster runAction:rotate completion:^{
                [monster removeFromParent];
            }];
        }
        
        // 如果要删除的妖怪存在数组
        if (monsSet.count > 0) {
            [proSet addObject:projectiel];
        }
    }
    for (SKSpriteNode *pro in proSet) {
        [pro removeFromParent];
        [_projectiles removeObject:pro];
    }
}









@end
