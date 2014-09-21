//
//  SceneKitTextureRenderer.m
//  TestVR
//
//  Created by Andy Qua on 21/09/2014.
//  Copyright (c) 2014 Andy Qua. All rights reserved.
//

#import "SceneKitTextureRenderer.h"
#import "Constants.h"

@import SceneKit;

@interface SceneKitTextureRenderer () <SCNSceneRendererDelegate>
{
    float rotate;
    SCNScene *scene;
    float hrx, hry, hrz;  // head rotation angles in radians

    SCNNode *headPositionNode;
    SCNNode *headRotationNode;
}
@end

@implementation SceneKitTextureRenderer
{
    SCNRenderer *leftEyeRenderer, *rightEyeRenderer;
    
    BOOL leftSceneReady, rightSceneReady;
    SCNNode *leftEyeCameraNode, *rightEyeCameraNode;
   	CGFloat interpupillaryDistance;

}

- (instancetype)initWithFrameSize:(CGSize)frameSize
{
    self = [super initWithFrameSize:frameSize];
    if (self) {
        // create a renderer for each eye
        SCNRenderer *(^makeEyeRenderer)() = ^
        {
            SCNRenderer *renderer = [SCNRenderer rendererWithContext:(__bridge void *)([EAGLContext currentContext]) options:nil];
            
            renderer.delegate = self;
            return renderer;
        };
        leftEyeRenderer  = makeEyeRenderer();
        rightEyeRenderer = makeEyeRenderer();


        [self setScene:[self createScene]];

        [scene.rootNode  addChildNode:headPositionNode];

    }
    return self;
}

- (void) updateFrameAtTime:(NSTimeInterval)timeSinceLastUpdate;
{
    [super updateFrameAtTime:timeSinceLastUpdate];
}

- (void) renderLeftTexture
{
    [leftEyeRenderer render];
}

- (void) renderRightTexture
{
    [rightEyeRenderer render];
}

- (void) updateDevicePositionWithRoll:(float)roll  yaw:(float)yaw pitch:(float)pitch
{
    [super updateDevicePositionWithRoll:roll yaw:yaw pitch:pitch];
    
    rotate += 20;
    [self setHeadRotationX:-(refYaw-yaw) Y:-(refRoll - roll) Z:0];
}

#pragma mark -
#pragma mark Accessors

- (SCNMatrix4)getCameraTranslationForEye:(int)eye
{
    // TODO: read IPD from HMD?
    float x = (-1 * eye) * (interpupillaryDistance/-2.0);
    return SCNMatrix4MakeTranslation(x, 0, 0 );
}
- (void)setInterpupillaryDistance:(CGFloat)ipd;
{
    interpupillaryDistance = ipd;
    leftEyeCameraNode.transform = [self getCameraTranslationForEye:LEFT];
    rightEyeCameraNode.transform = [self getCameraTranslationForEye:RIGHT];
}


- (SCNVector3) headPosition
{
    return headPositionNode.position;
}

// position is public, node is private
- (void)setHeadPosition:(SCNVector3) position
{
    headPositionNode.position = position;
}

- (void)setHeadRotationX:(float)x Y:(float)y Z:(float)z
{
    hrx = x;
    hry = y;
    hrz = z;
    
    SCNMatrix4 transform       = SCNMatrix4MakeRotation(x, 0, 1, 0);
    transform                  = SCNMatrix4Rotate(transform, y, 1, 0, 0);
    headRotationNode.transform = SCNMatrix4Rotate(transform, z, 0, 0, 1);
}

/*
- (BOOL)move2Direction:(Vector3f)direction
              distance:(float)distance
{
    return [self move2Direction:direction distance:distance facing:hrx];
}
- (BOOL)move2Direction:(Vector3f)direction  // in avatar space
              distance:(float)distance
                facing:(float)facing  // x rotation (yaw) in world space
{
    //NSLog(@"head position: %.2fx %.2fy %.2fz, moving %.2f radians * %.2f meters", self.headPosition.x, self.headPosition.y, self.headPosition.z, hrx, distance);
    
    Vector3f position = Vector3f(headPositionNode.position.x,
                                 headPositionNode.position.y,
                                 headPositionNode.position.z);
    
    Matrix4f rotate = Matrix4f::RotationY(facing);
    position += rotate.Transform(direction) * distance;
    
    headPositionNode.position = SCNVector3Make(position.x, position.y, position.z);
    
    //NSLog(@" new position: %.2fx %.2fy %.2fz", self.headPosition.x, self.headPosition.y, self.headPosition.z);
    // TODO: error handling, return NO if move failed
    return YES;
}
*/

- (void)linkNodeToHeadPosition:(SCNNode*)node
{
    [headPositionNode addChildNode:node];
}

- (void)linkNodeToHeadRotation:(SCNNode*)node
{
    [headRotationNode addChildNode:node];
}


#pragma mark - create scenekit scene

- (void)setScene:(SCNScene *)newScene
{
    scene = newScene;
    
    leftEyeRenderer.scene = newScene;
    rightEyeRenderer.scene = newScene;
    
    
    // create cameras
    SCNNode *(^addNodeforEye)(int) = ^(int eye)
    {
        // TODO: read these from the HMD?
        CGFloat verticalFOV = 97.5;
        CGFloat horizontalFOV = 0; //80.8;
        
        SCNCamera *camNode = [SCNCamera camera];
        camNode.xFov = 120;
        camNode.yFov = verticalFOV;
        camNode.zNear = horizontalFOV;
        camNode.zFar = 10000;
        
        SCNNode *node = [SCNNode node];
        node.camera = camNode;
        node.transform = [self getCameraTranslationForEye:eye];
        
        return node;
    };
    leftEyeRenderer.pointOfView = addNodeforEye(LEFT);
    rightEyeRenderer.pointOfView = addNodeforEye(RIGHT);
    
    headPositionNode = [SCNNode node];
    headPositionNode.position = SCNVector3Make(0, 5, 0);
    headRotationNode = [SCNNode node];
    [headPositionNode addChildNode:headRotationNode];

    [self linkNodeToHeadRotation:leftEyeRenderer.pointOfView];
    [self linkNodeToHeadRotation:rightEyeRenderer.pointOfView];
}

- (SCNScene *) createScene
{
    SCNScene *newScene = [[SCNScene alloc] init];
    
    SCNMaterial *material;
    
    SCNNode *boxNode = [SCNNode nodeWithGeometry:[SCNBox boxWithWidth:1 height:1 length:1 chamferRadius:0]];
    material = [SCNMaterial material];
    material.diffuse.contents = [UIColor blueColor];
    material.locksAmbientWithDiffuse = true;
    boxNode.geometry.firstMaterial = material;

    for ( float z = -20 ; z <= 20 ; z+=4 )
    {
        for ( float x = -20 ; x <= 20 ; x+=4 )
        {
            SCNNode *node = [boxNode clone];
            node.position = SCNVector3Make(x, 2, z);
            [newScene.rootNode addChildNode:node];
        }
    }

    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, 10, 10);
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor redColor];
    [scene.rootNode addChildNode:ambientLightNode];

    return newScene;
}
@end
