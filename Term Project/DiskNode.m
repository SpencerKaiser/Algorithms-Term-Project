//
//  DiskNode.m
//  Term Project
//
//  Created by Spencer Kaiser on 12/12/15.
//  Copyright © 2015 Spencer Kaiser. All rights reserved.
//

#import "DiskNode.h"

@implementation DiskNode

-(void)generatePositionValues {
        // Initialize node position to origin (outside sphere)
        self.x = [NSNumber numberWithFloat:0.0];
        self.y = [NSNumber numberWithFloat:0.0];
        self.z = [NSNumber numberWithFloat:0.0];
    
        // While ditance is greater than R (outside sphere), generatePoints()
        while (! [self isWithinDisk]) {
            [self generatePoints];
        }
}


-(void)generatePoints {
    self.x = [super rand];
    self.y = [super rand];
    self.z = [NSNumber numberWithFloat:0.0];
}

-(BOOL)isWithinDisk {
    // In a unit sphere, the x,y,z position is (0.5,0.5,0.5) with a radius of 0.5
    float unitCircleVals = 0.5;
    
    float distance = sqrt( pow(([self.x floatValue] - unitCircleVals),2) + pow(([self.y floatValue] - unitCircleVals),2) );
    
    return (distance <= unitCircleVals);
}



@end
