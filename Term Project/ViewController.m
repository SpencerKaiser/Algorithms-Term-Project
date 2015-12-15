//
//  ViewController.m
//  Term Project
//
//  Created by Spencer Kaiser on 12/7/15.
//  Copyright © 2015 Spencer Kaiser. All rights reserved.
//

#import "ViewController.h"
#import "Node.h"
#import "SphereNode.h"
#import "DiskNode.h"
#import "AdjacencyListManager.h"
#import <CorePlot/CorePlot.h>
@import SceneKit;

@interface ViewController ()
// DATA STRUCTURES + CLASS OBJECTS
@property (strong, nonatomic) NSMutableDictionary* adjacencyList;
@property (strong, nonatomic) NSMutableDictionary* colorData;
@property (strong, nonatomic) NSMutableArray* colors;
@property (assign, nonatomic) int numColors;
@property (strong, nonatomic) AdjacencyListManager* manager;
@property (assign) GraphType graphType;
@property (assign) int graphState;
@property (strong, nonatomic) SCNNode* bipartiteGraphNodes1;
@property (strong, nonatomic) SCNNode* bipartiteEdgeNodes1;
@property (strong, nonatomic) SCNNode* bipartiteGraphNodes2;
@property (strong, nonatomic) SCNNode* bipartiteEdgeNodes2;
@property (strong, nonatomic) SCNNode* otherGraphNodes;
@property (strong, nonatomic) SCNNode* otherEdgeNodes;

typedef enum {
    NodeTypeSquare,
    NodeTypeDisk,
    NodeTypeSphere
} NodeType;

// UI ELEMENTS
@property (weak) IBOutlet NSButton *createRGGButton;
@property (weak) IBOutlet NSTextField *numNodesTextField;
@property (weak) IBOutlet NSSegmentedControl *graphTypeControl;
@property (weak) IBOutlet SCNView *graphSceneView;
@property (weak) IBOutlet NSTextField *avgDegreeField;

@end


@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.graphTypeControl.selectedSegment = 0;              // Set graph type default to Square
    self.graphState = 0;
}

-(void)viewDidAppear {
    [self createScene];                                     // Instiantiate SceneKit Scene
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (IBAction)createRGGButtonPressed:(id)sender {
    [self generateGraph];                                   // Create graph using given chosen settings (type, num nodes, etc.)
}

- (IBAction)graphTypeDidChange:(id)sender {
    NSString* selected = [self.graphTypeControl labelForSegment:self.graphTypeControl.selectedSegment];
    if ([selected isEqualToString:@"Square"]) {
        self.graphType = square;
    }
    else if ([selected isEqualToString:@"Disk"]) {
        self.graphType = disk;
    }
    else if ([selected isEqualToString:@"Sphere"]) {
        self.graphType = sphere;
    }
}

- (IBAction)toggle:(id)sender {
    self.graphState++;
    switch (self.graphState) {
        case 3:
            [self.bipartiteGraphNodes1 removeFromParentNode];
            [self.bipartiteEdgeNodes1 removeFromParentNode];
            
            [self.bipartiteGraphNodes2 removeFromParentNode];
            [self.bipartiteEdgeNodes2 removeFromParentNode];
            
            [self.otherGraphNodes removeFromParentNode];
            [self.otherEdgeNodes removeFromParentNode];
            
            [self.graphSceneView.scene.rootNode addChildNode:self.bipartiteGraphNodes1];
            [self.graphSceneView.scene.rootNode addChildNode:self.bipartiteEdgeNodes1];
            
            self.graphState = 0;
            break;
        case 1:
            [self.bipartiteGraphNodes1 removeFromParentNode];
            [self.bipartiteEdgeNodes1 removeFromParentNode];
            
            [self.graphSceneView.scene.rootNode addChildNode:self.bipartiteGraphNodes2];
            [self.graphSceneView.scene.rootNode addChildNode:self.bipartiteEdgeNodes2];
            break;
        case 2:
            [self.graphSceneView.scene.rootNode addChildNode:self.bipartiteGraphNodes1];
            [self.graphSceneView.scene.rootNode addChildNode:self.bipartiteEdgeNodes1];
            
            [self.graphSceneView.scene.rootNode addChildNode:self.otherGraphNodes];
            [self.graphSceneView.scene.rootNode addChildNode:self.otherEdgeNodes];
            break;
    }
}


#pragma mark - Core
-(void)generateGraph {
    // Create list of nodes
    NSMutableDictionary* nodeList = [self createNodeList];
    
    // Create adjacency list from node list
    [self deallocAdjacencyList];
    self.adjacencyList = [self createAdjacencyListFromNodeList:nodeList];
    NSLog(@"Finished Creating Adjacency List");
    
    self.colorData = [self.manager smallestLastFirst:self.adjacencyList];
    self.numColors = (int)self.colorData.count;
    
    // Graph adjacency list
    [self graphAdjacencyList];                  // Create visualizations from adjacency list
    
    
}


- (NSMutableDictionary*)createNodeList {
    NSInteger numNodes = [self.numNodesTextField integerValue];         // Get # nodes from ui element
    if (!numNodes || numNodes <= 0) {                                   // Default # nodes = 1000
        numNodes = 1000;
    }
    
    NSMutableDictionary* nodeList = [[NSMutableDictionary alloc] init];                 // Create node list data structure
    
    switch (self.graphType) {
        case square:
            for (int i = 0; i < numNodes; i++) {
                Node* newNode = [[Node alloc] initWithID:i];                    // Create new node with id of current index
                nodeList[@(i)] = newNode;                                  // Store the new node in the nodeList
            }
            break;
        case disk:
            for (int i = 0; i < numNodes; i++) {
                Node* newNode = [[DiskNode alloc] initWithID:i];                    // Create new node with id of current index
                nodeList[@(i)] = newNode;                                  // Store the new node in the nodeList
            }
            break;
        case sphere:
            for (int i = 0; i < numNodes; i++) {
                Node* newNode = [[SphereNode alloc] initWithID:i];                    // Create new node with id of current index
                nodeList[@(i)] = newNode;                                  // Store the new node in the nodeList
            }
            break;
    }
    return nodeList;
}

-(void)deallocAdjacencyList {
    for (id key in self.adjacencyList) {
        Node* currNode = self.adjacencyList[key];
        currNode.edges = nil;
        currNode.connectedNodes = nil;
    }
    self.adjacencyList = nil;
}

-(NSMutableDictionary*)createAdjacencyListFromNodeList:(NSMutableDictionary*)nodeList {
    NSInteger averageDegree, numNodes;
    
    averageDegree = [self.avgDegreeField integerValue];
    if (averageDegree < 0) {
        averageDegree = 5;
    }
    
    numNodes = nodeList.count;
    
    float radius;
    float graphOccupiedArea = 0.0;              // Total area of the graph
    
    switch (self.graphType) {
        case square:
            graphOccupiedArea = 1.0;
            radius = sqrtf( (graphOccupiedArea * (averageDegree + 1)) / (M_PI * numNodes) );
            break;
        case disk:
            graphOccupiedArea = M_PI * pow(0.5, 2);                 //πr^2
            radius = sqrtf( (graphOccupiedArea * (averageDegree + 1)) / (M_PI * numNodes) );
            break;
        case sphere:
            graphOccupiedArea = (4.0/3) * M_PI * pow(0.5, 3);           //4/3πr^3
            radius = sqrtf( (4.0 * averageDegree) / numNodes );
            break;
    }
    
    self.manager = [[AdjacencyListManager alloc] init];
    
    return [self.manager createAdjacencyListWithNodeList:nodeList andRadius:radius];
}



-(void)graphAdjacencyList {
    [self generateColors];
    float avgX = 0.0,avgY = 0.0,avgZ = 0.0;
    // Release previous nodes
    //    NSArray* childNodes = self.graphSceneView.scene.rootNode.childNodes;
    //    for (int i = 0; i < childNodes.count; i++) {
    //        SCNNode* childNode = childNodes[i];
    //        [childNode removeFromParentNode];
    //    }
    
    [self createScene];
    
    float numEdges = 0.0;
    
    // Create node to contain all graph nodes (vertices and edges)
    self.bipartiteGraphNodes1 = [[SCNNode alloc] init];
    self.bipartiteGraphNodes2 = [[SCNNode alloc] init];
    self.otherGraphNodes = [[SCNNode alloc] init];
    
    self.bipartiteEdgeNodes1 = [[SCNNode alloc] init];
    self.bipartiteEdgeNodes2 = [[SCNNode alloc] init];
    self.otherEdgeNodes = [[SCNNode alloc] init];
    
    // Create reusable sphere
    float nodeRadius = 0.25 / sqrtf(self.adjacencyList.count);
    if (self.graphType == disk) {
        nodeRadius *= .8;
    }
    else if (self.graphType == sphere) {
        nodeRadius *= 2;
    }
    
    // UI Correction for rotating sphere
    if (self.graphType == sphere) {
        SCNSphere* wobbleCorrection = [SCNSphere sphereWithRadius:1.0];
        wobbleCorrection.firstMaterial.diffuse.contents = [NSColor colorWithWhite:0.0 alpha:0.0];
        SCNNode* wobbleCorrectionNode = [SCNNode nodeWithGeometry:wobbleCorrection];
        wobbleCorrectionNode.position = SCNVector3Make(0.0, 0.0, 0.0);
        [self.graphSceneView.scene.rootNode addChildNode:wobbleCorrectionNode];
    }
    
    
    // Create nodes and edges for each vertex in the adjacency list
    for (id key in self.adjacencyList) {
        // Create node for vertex
        Node* node = [self.adjacencyList objectForKey:key];
        avgX += [node.x floatValue];
        avgY += [node.y floatValue];
        avgZ += [node.z floatValue];
        
        SCNSphere* nodeSphere = [SCNSphere sphereWithRadius:nodeRadius];
        NSColor* color = self.colors[[node.color intValue]];
        nodeSphere.firstMaterial.diffuse.contents = color;
        nodeSphere.firstMaterial.specular.contents = [NSColor colorWithWhite:0.0 alpha:1.0];
        
        
        NSNumber* bipartite1 = node.bipartite[@(0)];
        NSNumber* bipartite2 = node.bipartite[@(1)];
        
        if ([bipartite1 intValue] == 1 || [bipartite2 intValue] == 1) {
            if ([bipartite2 intValue] == 1) {
                SCNNode* vertexNode = [SCNNode nodeWithGeometry:nodeSphere];
                vertexNode.position = SCNVector3Make([node.x floatValue], [node.y floatValue], [node.z floatValue]);
                [self.bipartiteGraphNodes2 addChildNode:vertexNode];
            }
            if ([bipartite1 intValue] == 1) {
                SCNNode* vertexNode = [SCNNode nodeWithGeometry:nodeSphere];
                vertexNode.position = SCNVector3Make([node.x floatValue], [node.y floatValue], [node.z floatValue]);
                [self.bipartiteGraphNodes1 addChildNode:vertexNode];
            }
        }
        else {
            SCNNode* vertexNode = [SCNNode nodeWithGeometry:nodeSphere];
            vertexNode.position = SCNVector3Make([node.x floatValue], [node.y floatValue], [node.z floatValue]);
            [self.otherGraphNodes addChildNode:vertexNode];
        }
        
        for (id key in node.edges) {
            
            SCNNode* edgeNode = node.edges[key];
            
            Node* connectedNode = self.adjacencyList[key];
            NSNumber* connectedBipartite1 = connectedNode.bipartite[@(0)];
            NSNumber* connectedBipartite2 = connectedNode.bipartite[@(1)];
            
            if (([bipartite1 intValue] == 1 && [connectedBipartite1 intValue] == 1) || ([bipartite2 intValue] == 1 && [connectedBipartite2 intValue] == 1) ){
                if ([bipartite1 intValue] == 1 && [connectedBipartite1 intValue] == 1) {
                    [self.bipartiteEdgeNodes1 addChildNode:edgeNode];
                }
                if ([bipartite2 intValue] == 1 && [connectedBipartite2 intValue] == 1) {
                    [self.bipartiteEdgeNodes2 addChildNode:edgeNode];
                }
            }
            else {
                [self.otherEdgeNodes addChildNode:edgeNode];
            }
            
            numEdges++;
        }
        
        
        
        node.edges = nil;   // Remove references to edges within the graph
    }
    NSLog(@"Updating Scene");
    
    //    SCNNode* flattenedGraphNodes = [graphNodes flattenedClone];
    [self.graphSceneView.scene.rootNode addChildNode:self.bipartiteGraphNodes1];
    
//    if (self.edgeNodes.childNodes.count > 30000) {
//        NSArray* partialNodes = [self.edgeNodes.childNodes subarrayWithRange:NSMakeRange(0, 30000)];
//        self.edgeNodes = [[SCNNode alloc] init];
//        for (int i = 0; i < partialNodes.count; i++) {
//            [self.edgeNodes addChildNode:partialNodes[i]];
//        }
//    }
    
    //    SCNNode* flattenedEdgeNodes = [edgeNodes flattenedClone];
    [self.graphSceneView.scene.rootNode addChildNode:self.bipartiteEdgeNodes1];
    
    int numNodes = (int)self.adjacencyList.count;
    
    if (numNodes + numEdges > 30000) {
        self.graphSceneView.allowsCameraControl = false;
    }
    
    NSLog(@"Nodes: %d\nEdges: %f\nAverage Degree: %f", numNodes, numEdges, 2.0*(numEdges/self.adjacencyList.count));
}

-(void)generateColors {
    self.colors = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.numColors; i++) {
        NSColor* newColor = [NSColor colorWithDeviceRed:[self rand] green:[self rand] blue:[self rand] alpha:1.0];
        [self.colors addObject: newColor];
    }
}

-(float)rand {
    float precision = 100.0;
    return arc4random_uniform(precision + 1.0) / precision;
}



#pragma mark - SceneKit Methods
-(void)createScene {
    self.graphState = 0;
    SCNScene* graphScene = [[SCNScene alloc] init];
    
    self.graphSceneView.scene = graphScene;
    self.graphSceneView.allowsCameraControl = true;
    self.graphSceneView.autoenablesDefaultLighting = true;
    self.graphSceneView.backgroundColor = [NSColor colorWithWhite:0.0 alpha:1.0];
    
    SCNNode* lightNode = [[SCNNode alloc] init];
    lightNode.light = [[SCNLight alloc] init];
    lightNode.light.type = SCNLightTypeAmbient;
    lightNode.light.color = [NSColor colorWithWhite:0.67 alpha:1.0];
    [self.graphSceneView.scene.rootNode addChildNode:lightNode];
    
    SCNNode* omniLightNode = [[SCNNode alloc] init];
    omniLightNode.light = [[SCNLight alloc] init];
    omniLightNode.light.type = SCNLightTypeOmni;
    omniLightNode.light.color = [NSColor colorWithWhite:0.75 alpha:1.0];
    omniLightNode.position = SCNVector3Make(0.5, 0.5, 1.0);
    [self.graphSceneView.scene.rootNode addChildNode:omniLightNode];
}


@end
