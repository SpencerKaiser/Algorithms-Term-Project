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
@property (assign) float radius;
@end

@implementation AdjacencyListManager


-(NSMutableDictionary*)createAdjacencyListWithNodeList: (NSMutableDictionary*)nodeList andRadius:(float)radius {
    self.radius = radius;
    NSArray* sortedNodes = [self sortNodesByXPos:nodeList];
    NSMutableDictionary* adjacencyList = nodeList;
    
//        for (int i = 0; i < self.sortedNodes.count; i++) {
//            Node* currNode = [self.adjacencyList objectForKey: self.sortedNodes[i]];
//            NSLog(@"%f", [currNode.x floatValue]);
//        }
    
    for (int i = 0; i < sortedNodes.count; i++) {
        Node* currNode = [nodeList objectForKey:sortedNodes[i]];
        
//        NSLog(@"Inspecting node %d", currNode.nodeID);
        
        int nextNodeIndex = i + 1;
        
        if (nextNodeIndex < sortedNodes.count) {               // Make sure index of next node is in range
//            NSLog(@"Looking at first comparison node");
            while (nextNodeIndex < sortedNodes.count) {        // Continue through remaining nodes until end of list or break
                Node* nextNode = [adjacencyList objectForKey: sortedNodes[nextNodeIndex]];
                
                if (([currNode.x floatValue] - [nextNode.x floatValue]) > self.radius) {
                    // Exceeded R radius on X-axis
                    break;
                }

                float distance = [currNode getDistanceToNode:nextNode];
                
                if (distance <= self.radius) {      // Next node is within R distance on the X axis and distance < R
                    [currNode.connectedNodes addObject:nextNode];
                    [nextNode.connectedNodes addObject:currNode];
                    // We don't need to store temp connections a second time
                    // [nextNode.tempConnectedNodes addObject:currNode];
                    
                    
                    // Create edge for graphing
                    SCNVector3 edgePoints[] = {
                        currNode.locationVector,         // Start Pos
                        nextNode.locationVector          // End Pos
                    };
                    
                    int indices[] = {0, 1};
                    
                    SCNGeometrySource *edgeSourceData = [SCNGeometrySource geometrySourceWithVertices:edgePoints
                                                                                              count:2];
                    NSData *edgeIndexData = [NSData dataWithBytes:indices
                                                           length:sizeof(indices)];
                    SCNGeometryElement *edgeElement = [SCNGeometryElement geometryElementWithData:edgeIndexData
                                                                                    primitiveType:SCNGeometryPrimitiveTypeLine
                                                                                   primitiveCount:1
                                                                                    bytesPerIndex:sizeof(int)];
                    SCNGeometry *line = [SCNGeometry geometryWithSources:@[edgeSourceData]
                                                                elements:@[edgeElement]];
                    SCNNode *lineNode = [SCNNode nodeWithGeometry:line];
                    
                    [currNode.edges addObject:lineNode];
                    
                    
                    
                    
                    
                    // CYLINDER CODE
                    // Find midpoint
//                    float midX, midY, midZ, rotation;
//                    midX = (x1 + x2) / 2.0;
//                    midY = (y1 + y2) / 2.0;
//                    midZ = (z1 + z2) / 2.0;
//                    
//                    
//                    float opposite, theta;
//                    float hypotenuse = distance;
//                    
//                    if (y2 > y1) {
//                        opposite = y2 - y1;
//                        theta = sin(opposite / hypotenuse);
//                        rotation = M_PI_2 - theta;
//                    }
//                    else {
//                        opposite = y1 - y2;
//                        theta = sin(opposite / hypotenuse);
//                        rotation = M_PI_2 + theta;
//                    }
                    
//                    NSLog(@"%f, %f, %f, %f, %f, %f, %f", x1, x2, y1, y2, distance, theta, rotation);
//                    
//                    SCNCylinder* edge = [SCNCylinder cylinderWithRadius:cylinderRadius height:distance];
//                    
//                    edge.firstMaterial.diffuse.contents = [NSColor colorWithWhite:20.0 alpha:1.0];
//                    SCNNode* edgeNode = [SCNNode nodeWithGeometry:edge];
//                    edgeNode.position = SCNVector3Make(midX, midY, 0.0);
//                    
//                    edgeNode.rotation = SCNVector4Make(0.0, 0.0, 1.0, -rotation);
//                    
//                    currNode.edges[@(nextNodeIndex)] = edgeNode;
                    

                }
                nextNodeIndex++;
            }
        }
    }
    return adjacencyList;
}


-(NSArray*) sortNodesByXPos:(NSMutableDictionary*)nodeList {
    NSArray* sortedNodes = [nodeList keysSortedByValueUsingComparator: ^(Node* node1, Node* node2) {
        if ([node1.x doubleValue] > [node2.x doubleValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        else if ([node1.x doubleValue] < [node2.x doubleValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    return sortedNodes;
}

@end
