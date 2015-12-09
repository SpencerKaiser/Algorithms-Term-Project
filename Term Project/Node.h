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
@property NSNumber *x, *y, *z;
@property NSMutableArray* connectedNodes;
@property NSMutableDictionary* edges;
@property SCNSphere* nodePointer;

-(id)initWithID:(int)ID;
@end
