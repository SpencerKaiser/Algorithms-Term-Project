//
//  AdjacencyListManager.h
//  Term Project
//
//  Created by Spencer Kaiser on 12/7/15.
//  Copyright © 2015 Spencer Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdjacencyListManager : NSObject

typedef enum {
    square,
    disk,
    sphere
} GraphType;

-(NSMutableDictionary*)createAdjacencyListWithNodeList:(NSMutableDictionary*)nodeList andRadius:(float)radius;
-(NSMutableDictionary*)smallestLastFirst:(NSMutableDictionary*)adjacencyList;
@end


