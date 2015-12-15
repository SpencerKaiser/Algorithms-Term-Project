//
//  BipartiteSubgraphs.h
//  Term Project
//
//  Created by Spencer Kaiser on 12/15/15.
//  Copyright © 2015 Spencer Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BipartiteSubgraph : NSObject
@property (strong, nonatomic) NSMutableArray* subgraph1;
@property (strong, nonatomic) NSMutableArray* subgraph2;
@property (assign, nonatomic) int edgeCount;
@property (assign, nonatomic) int color1;
@property (assign, nonatomic) int color2;
@end


@implementation BipartiteSubgraph

@end
