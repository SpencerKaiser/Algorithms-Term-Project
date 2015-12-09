//
//  AdjacencyListManager.m
//  Term Project
//
//  Created by Spencer Kaiser on 12/7/15.
//  Copyright © 2015 Spencer Kaiser. All rights reserved.
//

#import "AdjacencyListManager.h"
#import "Node.h"
@import SceneKit;

@interface AdjacencyListManager ()

@property (strong, nonatomic) NSString* graphType;
@property (assign) float radius;
@property (strong, nonatomic) NSArray* sortedNodes;

@end

@implementation AdjacencyListManager

-(id)initWithNodeList:(NSMutableDictionary*)nodeList withGraphType:(NSString*)graphType {
    self = [super init];
    
    self.adjacencyList = nodeList;
    
    return self;
}



-(void)createAdjacencyListWithRadius:(float)radius {
    self.radius = radius;
    float cylinderRadius = .02 / self.adjacencyList.count;
    [self sortNodesByXPos];
    
    //    for (int i = 0; i < self.sortedNodes.count; i++) {
    //        Node* currNode = [self.adjacencyList objectForKey: self.sortedNodes[i]];
    //        NSLog(@"%f", [currNode.x floatValue]);
    //    }

    for (int i = 0; i < self.sortedNodes.count; i++) {
        Node* currNode = [self.adjacencyList objectForKey:self.sortedNodes[i]];
//        NSLog(@"Looking at node %d with x value %f", currNode.nodeID, [currNode.x floatValue]);
        
        double x1,x2,y1,y2,z1,z2;
        x1 = [currNode.x doubleValue];
        y1 = [currNode.y doubleValue];
        z1 = [currNode.z doubleValue];
        
        int nextNodeIndex = i + 1;
        if (nextNodeIndex < self.sortedNodes.count) {
            while (nextNodeIndex < self.sortedNodes.count) {
                Node* nextNode = [self.adjacencyList objectForKey: self.sortedNodes[nextNodeIndex]];
                
//                NSLog(@"Comparing against node %d with x value %f", nextNode.nodeID, [nextNode.x floatValue]);
                
                x2 = [nextNode.x floatValue];
                y2 = [nextNode.y floatValue];
                z2 = [nextNode.z floatValue];
                
                double distance = sqrt( pow((x1 - x2),2) + pow((y1 - y2),2) );
                
                if ([nextNode.x floatValue] - x1 > radius) {
                    break;
                }
                else if (distance <= self.radius) {
                    [currNode.connectedNodes addObject:nextNode];
                    [nextNode.connectedNodes addObject:currNode];
                    
                    // Find midpoint
                    float midX, midY, midZ, rotation;
                    midX = (x1 + x2) / 2;
                    midY = (y1 + y2) / 2;
                    midZ = (z1 + z2) / 2;
                    
                    
                    double opposite, theta;
                    double hypotenuse = distance;
                    
                    if (y2 > y1) {
                        opposite = y2 - y1;
                        theta = asinf(opposite / hypotenuse);
                        rotation = M_PI_2 - theta;
                    }
                    else {
                        opposite = y1 - y2;
                        theta = asinf(opposite / hypotenuse);
                        rotation = M_PI_2 + theta;
                    }
                    
//                    NSLog(@"%f, %f, %f, %f, %f, %f, %f", x1, x2, y1, y2, distance, theta, rotation);
                    
                    SCNCylinder* edge = [SCNCylinder cylinderWithRadius:cylinderRadius height:distance];
                    
                    edge.firstMaterial.diffuse.contents = [NSColor colorWithWhite:20.0 alpha:1.0];
                    SCNNode* edgeNode = [SCNNode nodeWithGeometry:edge];
                    edgeNode.position = SCNVector3Make(midX, midY, 0.0);
                    
                    edgeNode.rotation = SCNVector4Make(0.0, 0.0, 1.0, -rotation);
                    
                    currNode.edges[@(nextNodeIndex)] = edgeNode;
                }
                nextNodeIndex++;
            }
        }
    }
    
    //    int degreeCount = 0;
    //    for (int i = 0; i < self.sortedNodes.count; i++) {
    //        Node* currNode = [self.adjacencyList objectForKey: self.sortedNodes[i]];
    //        degreeCount += currNode.edges.count;
    //        NSLog(@"%lu", (unsigned long)currNode.edges.count);
    //    }
    //    float avgDegree = degreeCount/self.sortedNodes.count;
    //    NSLog(@"Average Degree: %f", avgDegree);
}

-(bool)distanceBetweenNodesIsWithinRadius:(Node*)currNode and:(Node*)nextNode {
    float distance = sqrt( pow(([currNode.x floatValue] - [nextNode.x floatValue]),2) + pow(([currNode.y floatValue] - [nextNode.y floatValue]),2) );
    return distance <= self.radius;
}

-(void) sortNodesByXPos {
    self.sortedNodes = [self.adjacencyList keysSortedByValueUsingComparator: ^(Node* node1, Node* node2) {
        if ([node1.x doubleValue] > [node2.x doubleValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        else if ([node1.x doubleValue] < [node2.x doubleValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
}

@end
