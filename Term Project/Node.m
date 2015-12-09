//
//  Node.m
//  Term Project
//
//  Created by Spencer Kaiser on 12/7/15.
//  Copyright © 2015 Spencer Kaiser. All rights reserved.
//

#import "Node.h"

#define precision 100000

@interface Node ()

@end

@implementation Node

-(id)initWithID:(int)ID
{
    self = [super init];
    self.nodeID = ID;
    [self generatePositionValues];
    self.connectedNodes = [[NSMutableArray alloc] init];
    self.edges = [[NSMutableDictionary alloc] init];
    
    return self;
}

-(void)generatePositionValues {
    self.x = [self rand];
    self.y = [self rand];
    self.z = [self rand];
}

-(NSNumber*)rand {
    // Generate a random value between 0.0 and #precision+1
    // Return result divided by #precision
    return @(arc4random_uniform(precision + 1));
}

@end
