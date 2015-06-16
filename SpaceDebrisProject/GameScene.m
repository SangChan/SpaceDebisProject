//
//  GameScene.m
//  SpaceDebrisProject2
//
//  Created by SangChan on 2015. 6. 8..
//  Copyright (c) 2015년 sangchan. All rights reserved.
//

#import "GameScene.h"
#import "Satellite.h"
#import "Planet.h"
#define SK_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f)

@interface GameScene () {
    SKShapeNode *_planet;
    SKSpriteNode *_satellite;
    SKShapeNode *_debris;
    CFTimeInterval _startTime;
    CFTimeInterval _currentTime;
    BOOL _isTracking;
}

@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    self.physicsWorld.gravity =  CGVectorMake(0.0, 0.0);
    _startTime = 0.0;
    [self initPlanet];
    [self initSatellite];
    _isTracking = NO;
    SKAction *wait = [SKAction waitForDuration:1.0];
    SKAction *creatDebris = [SKAction performSelector:@selector(initDebris) onTarget:self];
    SKAction *perform = [SKAction repeatActionForever:[SKAction sequence:@[wait,creatDebris]]];
    [self runAction:perform];
    
    _planet.physicsBody.angularVelocity = 1.0;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (_isTracking == NO) {
            _isTracking = YES;
            
            float deltaX = location.x - _satellite.position.x;
            float deltaY = location.y - _satellite.position.y;
            _satellite.physicsBody.angularVelocity = 0.0;
            float angle = atan2f(deltaY, deltaX);
            _satellite.zRotation = angle - SK_DEGREES_TO_RADIANS(-90.0f);
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (_isTracking == YES) {
            float deltaX = location.x - _satellite.position.x;
            float deltaY = location.y - _satellite.position.y;
            _satellite.physicsBody.angularVelocity = 0.0;
            float angle = atan2f(deltaY, deltaX);
            _satellite.zRotation = angle - SK_DEGREES_TO_RADIANS(-90.0f);
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self resetController];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self resetController];
}



-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    _planet.physicsBody.angularVelocity = 1.0;
    _planet.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5 );
}

-(void)initPlanet {
    CGPoint centerPos = CGPointMake(self.size.width * 0.5, self.size.height * 0.5 );
    _planet = [SKShapeNode shapeNodeWithCircleOfRadius:50.0];
    [_planet setFillColor:[UIColor blueColor]];
    
    _planet.position = CGPointMake(centerPos.x,centerPos.y);
    
    SKShapeNode *point = [SKShapeNode shapeNodeWithCircleOfRadius:5.0];
    [point setFillColor:[UIColor whiteColor]];
    point.position = CGPointMake(0,_planet.frame.size.height/2 - 9.0);
    [_planet addChild:point];
    
    _planet.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:50.0];
    _planet.physicsBody.dynamic = YES;
    _planet.physicsBody.density = 100;
    [self addChild:_planet];
}


-(void)initDebris {
    //CGPoint centerPos = CGPointMake(self.size.width * 0.5, self.size.height * 0.5 );
    float radian = [self randomFromMin:0.0 Max:M_PI];//(float)rand()/RAND_MAX*2*M_PI;
    _debris = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(13.0, 7.0)];
    NSLog(@"radian = %f",radian);
    CGFloat radius =  sqrt((self.size.width/2.0 * self.size.width/2.0) + (self.size.height/2.0*self.size.height/2.0));
    _debris.position = CGPointMake(radius*cos(radian)+self.size.width/3.0, radius*sin(radian)+self.size.height/2.0);
    [_debris setFillColor:[UIColor brownColor]];
    
    _debris.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_debris.frame.size];
    _debris.physicsBody.dynamic = YES;
    _debris.physicsBody.density = 1;
    [self addChild:_debris];
    NSLog(@"planet x= %f, y= %f. debris x= %f, y =%f", _planet.position.x, _planet.position.y, _debris.position.x, _debris.position.y);
    
    CGVector throwVector = CGVectorMake((_planet.position.x - _debris.position.x) *0.5, (_planet.position.y - _debris.position.y) *0.5);
    NSLog(@"vector = %f,%f", throwVector.dx, throwVector.dy);
    [_debris.physicsBody applyForce:throwVector];
    
}

-(void)resetController {
    _isTracking = NO;
    _satellite.physicsBody.angularVelocity = 0.0;
}

-(void)initSatellite {
    CGPoint centerPos = CGPointMake(self.size.width * 0.5, self.size.height * 0.5 );
    _satellite = [[Satellite alloc]initWithColor:[UIColor redColor] size:CGSizeMake(10.0,10.0)];
    _satellite.position = CGPointMake(centerPos.x, centerPos.y - _planet.frame.size.width/2 - 45);
    _satellite.anchorPoint = CGPointMake(0.5, 0.5);
    
    SKShapeNode *point = [SKShapeNode shapeNodeWithCircleOfRadius:2.0];
    [point setFillColor:[UIColor whiteColor]];
    point.position = CGPointMake(0,_satellite.frame.size.height/2 - 9.0);
    [_satellite addChild:point];
    
    _satellite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(10.0, 10.0)];
    _satellite.physicsBody.dynamic = YES;
    _satellite.physicsBody.density = 1;
    [self addChild:_satellite];
    
    
    CGPoint middleOfPlanet = CGPointMake(_planet.frame.origin.x + (_planet.frame.size.width * 0.5),_planet.frame.origin.y + (_planet.frame.size.height * 0.5));
    CGPoint middleOfSatellite = CGPointMake(_satellite.frame.origin.x + (_satellite.frame.size.width * 0.5),_satellite.frame.origin.y + (_satellite.frame.size.height * 0.5));
    
    SKPhysicsJointLimit *limitJoint = [SKPhysicsJointLimit jointWithBodyA:_planet.physicsBody bodyB:_satellite.physicsBody anchorA:middleOfPlanet anchorB:middleOfSatellite];
    [limitJoint setMaxLength:1.0];
    [self.physicsWorld addJoint:limitJoint];
    
    SKPhysicsJointPin *pinJoint = [SKPhysicsJointPin jointWithBodyA:_planet.physicsBody bodyB:_satellite.physicsBody anchor:middleOfSatellite];
    [self.physicsWorld addJoint:pinJoint];
}

-(float)randomFromMin:(float)min toMax:(float)max{
    return (float) rand()/RAND_MAX * (max - min) + min;
}

@end
