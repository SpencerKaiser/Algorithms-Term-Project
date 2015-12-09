//
//  ViewController.m
//  Term Project
//
//  Created by Spencer Kaiser on 12/7/15.
//  Copyright © 2015 Spencer Kaiser. All rights reserved.
//

#import "ViewController.h"
#import "Node.h"
#import "AdjacencyListManager.h"
@import SceneKit;

@interface ViewController ()
// DATA STRUCTURES + CLASS OBJECTS
@property (strong, nonatomic) NSMutableDictionary* nodeList;
@property (strong, nonatomic) NSMutableDictionary* adjacencyList;
@property (strong, nonatomic) AdjacencyListManager* manager;
@property (assign) GraphType graphType;

// UI ELEMENTS
@property (weak) IBOutlet NSButton *createRGGButton;
@property (weak) IBOutlet NSTextField *numNodesTextField;
@property (weak) IBOutlet NSSegmentedControl *graphTypeControl;
@property (weak) IBOutlet SCNView *graphSceneView;

@end


@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.graphTypeControl.selectedSegment = 0;
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear {
    [self createScene];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

- (void)textDidEndEditing:(NSNotification *)aNotification {
    [self generateGraph];
}

- (IBAction)createRGGButtonPressed:(id)sender {
    [self generateGraph];
}

- (IBAction)graphTypeDidChange:(id)sender {
    NSString* selected = [self.graphTypeControl labelForSegment:self.graphTypeControl.selectedSegment];
    if ([selected isEqualToString:@"Square"]) {
        self.graphType = square;
    }
    else if ([selected isEqualToString:@"Disc"]) {
        self.graphType = disc;
    }
    else if ([selected isEqualToString:@"Sphere"]) {
        self.graphType = sphere;
    }
    
    //    if (self.adjacencyList) {
    //        [self graphAdjacencyList];
    //    }
}


-(void)generateGraph {
    [self createNodeList];
    
    [self createAdjacencyListFromNodeList];
    self.adjacencyList = self.nodeList;
    
    [self graphAdjacencyList];
}


- (void)createNodeList {
    NSInteger numNodes = [self.numNodesTextField integerValue];
    if (!numNodes || numNodes <= 0) {
        numNodes = 1000;
    }
    
    self.nodeList = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < numNodes; i++) {
        Node* newNode = [[Node alloc] initWithID:i];
        self.nodeList[@(i)] = newNode;
        //self.nodeList[ [NSString stringWithFormat:@"%d", i] ] = newNode;
    }
}

-(void)createAdjacencyListFromNodeList {
    NSString* graphType = [self.graphTypeControl labelForSegment:self.graphTypeControl.selectedSegment];
    int radius = 50000;
    
    self.manager = [[AdjacencyListManager alloc] initWithNodeList:self.nodeList withGraphType:graphType];
    
    [self.manager createAdjacencyListWithRadius:radius];
}

-(void)graphAdjacencyList {
    switch (self.graphType) {
        case square:
        {
            [self graphSquare];
            break;
        }
        case disc:
            break;
        case sphere:
            break;
        default:
            break;
    }
}

-(void)graphSquare {
    [self createScene];
    int numNodes = 0;
    SCNNode *graphNodes = [[SCNNode alloc] init];
    float nodeRadius = 5000;
    for (id key in self.adjacencyList) {
        SCNSphere* nodeSphere = [SCNSphere sphereWithRadius:nodeRadius];
        
        Node* node = [self.adjacencyList objectForKey:key];
        
        node.nodePointer = nodeSphere;      // Store pointer to sphere for later edge connections
        
        nodeSphere.firstMaterial.diffuse.contents = [NSColor colorWithWhite:50.0 alpha:1.0];
        //        nodeSphere.firstMaterial.specular.contents = [NSColor colorWithWhite:0.0 alpha:1.0];
        
        SCNNode* graphNode = [SCNNode nodeWithGeometry:nodeSphere];
        
        graphNode.position = SCNVector3Make([node.x floatValue], [node.y floatValue], 0.0);
        if (numNodes <= INFINITY) {
            [graphNodes addChildNode:graphNode];
        }
        numNodes++;
    }
    
    SCNNode* edges = [[SCNNode alloc] init];
    // MAKE EDGES
    int numEdges = 0;
    for (id key in self.adjacencyList) {
        Node* node = [self.adjacencyList objectForKey:key];
        for (id key in node.edges) {
            SCNNode* edgeNode = [node.edges objectForKey:key];
            
            //             SCNCylinder* edge = [node.edges objectForKey:key];
            //             edge.firstMaterial.diffuse.contents = [NSColor colorWithWhite:20.0 alpha:1.0];
            //             SCNNode* edgeNode = [SCNNode nodeWithGeometry:edge];
            //             edgeNode.position = SCNVector3Make([node.x floatValue], [node.y floatValue], 0.0);
            if (numEdges <= INFINITY) {
                [edges addChildNode:edgeNode];
            }
            numEdges++;
        }
    }
    
//    SCNCylinder* newEdge = [SCNCylinder cylinderWithRadius:0.5 height:0.5];
//    SCNNode* edgeNode = [SCNNode nodeWithGeometry:newEdge];
//    edgeNode.position = SCNVector3Make(0.0, 0.0, 0.0);
//    [edges addChildNode:edgeNode];
    
//    SCNSphere* nodeSphere = [SCNSphere sphereWithRadius:nodeRadius];
//    nodeSphere.firstMaterial.diffuse.contents = [NSColor colorWithWhite:50.0 alpha:1.0];
//    SCNNode* graphNode1 = [SCNNode nodeWithGeometry:nodeSphere];
//    graphNode1.position = SCNVector3Make(0.5, 0.5, 0.0);
//    
//    SCNNode* graphNode2 = [SCNNode nodeWithGeometry:nodeSphere];
//    graphNode2.position = SCNVector3Make(1.0, 0.5, 0.0);
//    
//    SCNNode* graphNode3 = [SCNNode nodeWithGeometry:nodeSphere];
//    graphNode3.position = SCNVector3Make(0.5, 1.0, 0.0);
//    
//    SCNNode* graphNode4 = [SCNNode nodeWithGeometry:nodeSphere];
//    graphNode4.position = SCNVector3Make(0.0, 0.5, 0.0);
//
//    [graphNodes addChildNode:graphNode1];
//    [graphNodes addChildNode:graphNode2];
//    [graphNodes addChildNode:graphNode3];
//    [graphNodes addChildNode:graphNode4];
    
    
    NSLog(@"Num Edges: %d", numEdges);
    [self.graphSceneView.scene.rootNode addChildNode:graphNodes];
    [self.graphSceneView.scene.rootNode addChildNode:edges];
}







#pragma mark - SceneKit Methods
-(void)createScene {
    SCNScene* graphScene = [[SCNScene alloc] init];
    
    self.graphSceneView.scene = graphScene;
    self.graphSceneView.allowsCameraControl = true;
    self.graphSceneView.autoenablesDefaultLighting = true;
    self.graphSceneView.backgroundColor = [NSColor colorWithWhite:0.0 alpha:1.0];
}


@end
