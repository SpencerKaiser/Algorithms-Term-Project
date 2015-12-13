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
@import SceneKit;

@interface ViewController ()
// DATA STRUCTURES + CLASS OBJECTS
@property (strong, nonatomic) NSMutableDictionary* adjacencyList;
@property (strong, nonatomic) AdjacencyListManager* manager;
@property (assign) GraphType graphType;

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



#pragma mark - Core
-(void)generateGraph {
    // Create list of nodes
    NSMutableDictionary* nodeList = [self createNodeList];
    
    // Create adjacency list from node list
    self.adjacencyList = [self createAdjacencyListFromNodeList:nodeList];
    
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
    float avgX = 0.0,avgY = 0.0,avgZ = 0.0;
    // Release previous nodes
    //    NSArray* childNodes = self.graphSceneView.scene.rootNode.childNodes;
    //    for (int i = 0; i < childNodes.count; i++) {
    //        SCNNode* childNode = childNodes[i];
    //        [childNode removeFromParentNode];
    //    }
    
    [self createScene];
    
    NSLog(@"Finished Creating Adjacency List");
    
    float numEdges = 0.0;
    
    // Create node to contain all graph nodes (vertices and edges)
    SCNNode *graphNodes = [[SCNNode alloc] init];
    
    // Create reusable sphere
    float nodeRadius = 0.25 / sqrtf(self.adjacencyList.count);
    if (self.graphType == disk) {
        nodeRadius *= .8;
    }
    else if (self.graphType == sphere) {
        nodeRadius *= 2;
    }
    
    SCNSphere* nodeSphere = [SCNSphere sphereWithRadius:nodeRadius];
    nodeSphere.firstMaterial.diffuse.contents = [NSColor colorWithDeviceCyan:1.0 magenta:0.0 yellow:0.0 black:0.2 alpha:1.0];
    nodeSphere.firstMaterial.specular.contents = [NSColor colorWithWhite:0.0 alpha:1.0];
    
    // UI Correction for rotating sphere
    if (self.graphType == sphere) {
        SCNSphere* wobbleCorrection = [SCNSphere sphereWithRadius:1.0];
        wobbleCorrection.firstMaterial.diffuse.contents = [NSColor colorWithWhite:0.0 alpha:0.0];
        SCNNode* wobbleCorrectionNode = [SCNNode nodeWithGeometry:wobbleCorrection];
        wobbleCorrectionNode.position = SCNVector3Make(0.0, 0.0, 0.0);
        [graphNodes addChildNode:wobbleCorrectionNode];
    }
    
    
    // Create nodes and edges for each vertex in the adjacency list
    for (id key in self.adjacencyList) {
        // Create node for vertex
        Node* node = [self.adjacencyList objectForKey:key];
        avgX += [node.x floatValue];
        avgY += [node.y floatValue];
        avgZ += [node.z floatValue];
        
        SCNNode* vertexNode = [SCNNode nodeWithGeometry:nodeSphere];
        vertexNode.position = SCNVector3Make([node.x floatValue], [node.y floatValue], [node.z floatValue]);
        [graphNodes addChildNode:vertexNode];
        
        for (int i = 0; i < node.edges.count; i++) {
            SCNNode* edgeNode = node.edges[i];
            [graphNodes addChildNode:edgeNode];
            numEdges++;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.graphSceneView.scene.rootNode addChildNode:graphNodes];
    });
    
    
    int numNodes = (int)self.adjacencyList.count;
    
    NSLog(@"Nodes: %lu\nEdges: %f\nAverage Degree: %f", (unsigned long)self.adjacencyList.count, numEdges, 2.0*(numEdges/self.adjacencyList.count));
    NSLog(@"Average X: %f\nAverage Y: %f\nAverage Z: %f", avgX/numNodes,avgY/numNodes,avgZ/numNodes);
    float camX = self.graphSceneView.pointOfView.position.x;
    float camY = self.graphSceneView.pointOfView.position.y;
    float camZ = self.graphSceneView.pointOfView.position.z;
    NSLog(@"Camera Position: %f, %f, %f", camX, camY, camZ);
}



#pragma mark - SceneKit Methods
-(void)createScene {
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
