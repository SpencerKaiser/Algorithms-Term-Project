//
//  SphereNode.m
//  Term Project
//
//  Created by Spencer Kaiser on 12/12/15.
//  Copyright © 2015 Spencer Kaiser. All rights reserved.
//

#import "SphereNode.h"

@implementation SphereNode

-(void)generatePositionValues {
    float theta = 2.0 * M_PI * [[super rand] floatValue];
    float phi = acosf(2 * [[super rand] floatValue] - 1.0);
    
    self.x = [NSNumber numberWithFloat:(cosf(theta) * sinf(phi))];
    self.y = [NSNumber numberWithFloat:(sinf(theta) * sinf(phi))];
    self.z = [NSNumber numberWithFloat:cosf(phi)];
    
    
//    // Initialize node position to origin (outside sphere)
//    self.x = [NSNumber numberWithFloat:0.0];
//    self.y = [NSNumber numberWithFloat:0.0];
//    self.z = [NSNumber numberWithFloat:0.0];
//   
//    // While ditance is greater than R (outside sphere), generatePoints()
//    while (! [self isWithinSphere]) {
//        [self generatePoints];
//    }
//    if ([self.z floatValue] >= 0.5) {
//        self.z = [NSNumber numberWithFloat:-1.0];
//    }
//    else {
//        self.z = [NSNumber numberWithFloat:1.0];
//    }
//    
//    // Move node to surface of sphere
//    [self normalizePosition];
}

-(void)generatePoints {
    self.x = [super rand];
    self.y = [super rand];
    self.z = [super rand];
}

-(BOOL)isWithinSphere {
    // In a unit sphere, the x,y,z position is (0.5,0.5,0.5) with a radius of 0.5
    float unitSphereVals = 0.5;
    
    float distance = sqrt( pow(([self.x floatValue] - unitSphereVals),2) + pow(([self.y floatValue] - unitSphereVals),2) + pow(([self.z floatValue] - unitSphereVals),2) );
    
    return (distance <= unitSphereVals);
}

//-(void)normalizePosition {
//    float theta = 2.0 * M_PI * [[super rand] floatValue];
//    float phi = acosf(2 * [[super rand] floatValue] - 1.0);
//    
//    self.x = [NSNumber numberWithFloat:(cosf(theta) * sinf(phi))];
//    self.y = [NSNumber numberWithFloat:(sinf(theta) * cosf(phi))];
//    self.z = [NSNumber numberWithFloat:cosf(phi)];
//    
//    
//
//}

@end
