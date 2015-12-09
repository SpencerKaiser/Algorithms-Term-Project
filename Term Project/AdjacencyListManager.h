//
//  AdjacencyListManager.h
//  Term Project
//
//  Created by Spencer Kaiser on 12/7/15.
//  Copyright © 2015 Spencer Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdjacencyListManager : NSObject
@property (strong, nonatomic) NSMutableDictionary* adjacencyList;

-(id)initWithNodeList:(NSMutableDictionary*)nodeList withGraphType:(NSString*)graphType;
-(void)createAdjacencyListWithRadius:(int)radius;
@end


