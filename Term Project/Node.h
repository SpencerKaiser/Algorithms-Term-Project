//
//  Node.h
//  Term Project
//
//  Created by Spencer Kaiser on 12/7/15.
//  Copyright © 2015 Spencer Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>
@import SceneKit;

@interface Node : NSObject
@property int nodeID;
@property (strong, nonatomic) NSNumber *x, *y, *z, *degreeWhenDeleted, *color;
@property (strong, nonatomic) NSMutableArray* connectedNodes;
@property (strong, nonatomic) NSMutableDictionary *edges, *bipartite;
//@property (strong, nonatomic) SCNSphere* nodePointer;
@property (assign, nonatomic) SCNVector3 locationVector;

-(id)initWithID:(int)ID;
-(NSNumber*)rand;
-(float)getDistanceToNode:(Node*)destinationNode;
@end
