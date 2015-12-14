//
//  Node.m
//  Term Project
//
//  Created by Spencer Kaiser on 12/7/15.
//  Copyright © 2015 Spencer Kaiser. All rights reserved.
//

#import "Node.h"
#import "Constants.h"

@interface Node ()

@end

@implementation Node

-(id)initWithID:(int)ID
{
    self = [super init];
    
    self.nodeID = ID;
    [self generatePositionValues];
    self.locationVector = [self getVector];
    self.connectedNodes = [[NSMutableArray alloc] init];
    self.edges = [[NSMutableArray alloc] init];
    
    return self;
}

-(void)dealloc {
    self.connectedNodes = nil;
    self.edges = nil;
}


-(void)generatePositionValues {
    self.x = [self rand];
    self.y = [self rand];
    self.z = [NSNumber numberWithFloat:0.0];        // Square nodes have no Z coordinate
}

-(NSNumber*)rand {
    // Generate a random value between 0.0 and #precision+1
    // Return result divided by #precision
    return @(arc4random_uniform(nodePrecision + 1.0) / nodePrecision);
}

-(float)getDistanceToNode:(Node *)destinationNode {
    
    float distance,x1,x2,y1,y2,z1,z2;
    
    x1 = [self.x floatValue];
    y1 = [self.y floatValue];
    z1 = [self.z floatValue];
    
    x2 = [destinationNode.x floatValue];
    y2 = [destinationNode.y floatValue];
    z2 = [destinationNode.z floatValue];
            
    distance = sqrt( pow((x1 - x2),2) + pow((y1 - y2),2) + pow((z1 - z2),2) );
    
    return distance;
}

-(SCNVector3)getVector {
    return SCNVector3Make([self.x floatValue], [self.y floatValue], [self.z floatValue]);
}

@end
