//
//  GameViewController.m
//  TestVR
//
//  Created by Andy Qua on 19/09/2014.
//  Copyright (c) 2014 Andy Qua. All rights reserved.
//

#import "GameViewController.h"
#import "Camera.h"
#import "GLProgram.h"
#import <OpenGLES/ES2/glext.h>

@import GLKit;
@import SceneKit;
@import QuartzCore;
@import CoreMotion;

#define RadToDeg(radians) ((radians) * (180.0 / M_PI))


#define EYE_RENDER_RESOLUTION_X 800
#define EYE_RENDER_RESOLUTION_Y 1000

#define LEFT 0
#define RIGHT 1


#define BUFFER_OFFSET(i) ((char *)NULL + (i))

GLfloat gCubeVertexData[216] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};


@interface GameViewController () <SCNSceneRendererDelegate>
{
    GLProgram *displayProgram;
    GLint displayPositionAttribute, displayTextureCoordinateAttribute;
    GLint displayInputTextureUniform;
    
    GLint lensCenterUniform, screenCenterUniform, scaleUniform, scaleInUniform, hmdWarpParamUniform;
    
    GLuint leftEyeTexture, rightEyeTexture;
    GLuint leftEyeDepthTexture, rightEyeDepthTexture;
    GLuint leftEyeFramebuffer, rightEyeFramebuffer;
    GLuint leftEyeDepthBuffer, rightEyeDepthBuffer;

    SCNRenderer *leftEyeRenderer, *rightEyeRenderer;

    BOOL leftSceneReady, rightSceneReady;
    SCNNode *leftEyeCameraNode, *rightEyeCameraNode;
   	CGFloat interpupillaryDistance;
    
    Camera *camera;
    
    // For demo scene
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;

    
    // Core Motion stuff
    CMMotionManager *motionManager;
    CMAttitude *referenceAttitude;
    float refYaw;
    float refPitch;
    float refRoll;
    
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;


- (void)setupGL;
- (void)tearDownGL;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.enableSetNeedsDisplay = NO;
    
    camera = [[Camera alloc] init];
    
    [camera PositionCameraAtX:0 Y:3 Z:-10
                           VX:0 VY:0 VZ:100
                          UpX:0 UpY:1 UpZ:0];

    [self setupGL];
    [self setupCoreMotion];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];


    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    glEnable(GL_DEPTH_TEST);
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    [self commonInit];
    [self setScene:[self createScene]];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
}

- (void)commonInit
{
    // create storage space for OpenGL textures
    glActiveTexture(GL_TEXTURE0);
    
    void (^setupBufferWithTexture)(GLuint*, GLuint*, GLuint*) = ^(GLuint* texture, GLuint* frameBuffer, GLuint* depthBuffer)
    {
        glGenTextures(1, texture);
        glBindTexture(GL_TEXTURE_2D, *texture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glGenFramebuffers(1, frameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, *frameBuffer);
        
        glGenRenderbuffers(1, depthBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, *depthBuffer);
        
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, EYE_RENDER_RESOLUTION_X, EYE_RENDER_RESOLUTION_Y);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, *depthBuffer);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, EYE_RENDER_RESOLUTION_X, EYE_RENDER_RESOLUTION_Y, 0, GL_BGRA, GL_UNSIGNED_BYTE, 0);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, *texture, 0);
        
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete eye FBO: %d", status);
        
        glBindTexture(GL_TEXTURE_2D, 0);
    };
    
    setupBufferWithTexture(&leftEyeTexture, &leftEyeFramebuffer, &leftEyeDepthBuffer);
    setupBufferWithTexture(&rightEyeTexture, &rightEyeFramebuffer, &rightEyeDepthBuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    displayProgram = [[GLProgram alloc] initWithVertexShaderFilename:@"Shader"
                                              fragmentShaderFilename:@"Shader"];
    [displayProgram addAttribute:@"position"];
    [displayProgram addAttribute:@"inputTextureCoordinate"];
    
    if (![displayProgram link])
    {
        NSLog(@"Link failed");
        NSString *progLog = [displayProgram programLog];
        NSLog(@"Program Log: %@", progLog);
        NSString *fragLog = [displayProgram fragmentShaderLog];
        NSLog(@"Frag Log: %@", fragLog);
        NSString *vertLog = [displayProgram vertexShaderLog];
        NSLog(@"Vert Log: %@", vertLog);
        displayProgram = nil;
    }
    
    displayPositionAttribute = [displayProgram attributeIndex:@"position"];
    displayTextureCoordinateAttribute = [displayProgram attributeIndex:@"inputTextureCoordinate"];
    displayInputTextureUniform = [displayProgram uniformIndex:@"inputImageTexture"];
    
    screenCenterUniform = [displayProgram uniformIndex:@"ScreenCenter"];
    scaleUniform = [displayProgram uniformIndex:@"Scale"];
    scaleInUniform = [displayProgram uniformIndex:@"ScaleIn"];
    hmdWarpParamUniform = [displayProgram uniformIndex:@"HmdWarpParam"];
    lensCenterUniform = [displayProgram uniformIndex:@"LensCenter"];
    
    [displayProgram use];
    
    glEnableVertexAttribArray(displayPositionAttribute);
    glEnableVertexAttribArray(displayTextureCoordinateAttribute);
    
    // Depth test will always be enabled
    glEnable(GL_DEPTH_TEST);

    // create a renderer for each eye
    SCNRenderer *(^makeEyeRenderer)() = ^
    {
        SCNRenderer *renderer = [SCNRenderer rendererWithContext:(__bridge void *)([EAGLContext currentContext]) options:nil];

        renderer.delegate = self;
        return renderer;
    };
    leftEyeRenderer  = makeEyeRenderer();
    rightEyeRenderer = makeEyeRenderer();
}

- (void)setScene:(SCNScene *)newScene
{
    leftSceneReady = NO;
    rightSceneReady = NO;
    
    glUniform4f(hmdWarpParamUniform, 1.0, 0.22, 0.24, 0.0);
    
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
    
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    [self getDeviceGLRotationMatrix];
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    [camera StrafeCamera:-0.003];
    GLKMatrix4 modelViewMatrix = [camera Look];
    self.effect.transform.modelviewMatrix = modelViewMatrix;

    glBindFramebuffer(GL_FRAMEBUFFER, leftEyeFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, leftEyeDepthBuffer);
    
    [self renderScene];
    
    
    // Right Eye
    [camera StrafeCamera:0.006];
    modelViewMatrix = [camera Look];
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    [camera StrafeCamera:-0.003];

    _rotation += self.timeSinceLastUpdate * 0.5f;
    
    glBindFramebuffer(GL_FRAMEBUFFER, rightEyeFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, rightEyeDepthBuffer);
    [self renderScene];
    _rotation += self.timeSinceLastUpdate * 0.5f;
}


- (void) renderScene
{
    glViewport(0, 0, EYE_RENDER_RESOLUTION_X, EYE_RENDER_RESOLUTION_Y);
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glBindVertexArrayOES(_vertexArray);
    
    GLKMatrix4 origM = self.effect.transform.modelviewMatrix;
    for ( float z = -20 ; z <= 20 ; z+=4 )
    {
        for ( float x = -20 ; x <= 20 ; x+=4 )
        {
            GLKMatrix4 m = origM;
            m = GLKMatrix4Translate(m, x, 0, z);
            m = GLKMatrix4Rotate(m, _rotation, 1.0f, 1.0f, 1.0f);
            self.effect.transform.modelviewMatrix = m;
            
            
            // Render the object with GLKit
            [self.effect prepareToDraw];
            
            glDrawArrays(GL_TRIANGLES, 0, 36);

        }
        
    }

    glBindVertexArrayOES(0);
}


- (void)update2
{
    glBindFramebuffer(GL_FRAMEBUFFER, leftEyeFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, leftEyeDepthBuffer);
    
    glViewport(0, 0, EYE_RENDER_RESOLUTION_X, EYE_RENDER_RESOLUTION_Y);
    glClearColor(0, 1, 1, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [leftEyeRenderer render];
    
    glBindFramebuffer(GL_FRAMEBUFFER, rightEyeFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, rightEyeDepthBuffer);
    
    glViewport(0, 0, EYE_RENDER_RESOLUTION_X, EYE_RENDER_RESOLUTION_Y);

    glClearColor(0, 1, 1, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [rightEyeRenderer render];

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self renderStereoscopicScene];  // apply distortion
    
//    NSLog( @"GLError - %i", glGetError());
}


- (void)renderStereoscopicScene
{
    static const GLfloat leftEyeVertices[] = {
        -1.0f, -1.0f,
        0.0f, -1.0f,
        -1.0f,  1.0f,
        0.0f,  1.0f,
    };
    
    static const GLfloat rightEyeVertices[] = {
        0.0f, -1.0f,
        1.0f, -1.0f,
        0.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    static const GLfloat textureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    [displayProgram use];
    
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    
    glEnableVertexAttribArray(displayPositionAttribute);
    glEnableVertexAttribArray(displayTextureCoordinateAttribute);
    
    float w = 1.0;
    float h = 1.0;
    float x = 0.0;
    float y = 0.0;
    
    // Left eye
    float distortion = 0.151976 * 2.0;
    float scaleFactor = 0.583225;
    float as = 640.0 / 800.0;
//    float as = 320.0 / 568;
    glUniform2f(scaleUniform, (w/2) * scaleFactor, (h/2) * scaleFactor * as);
    glUniform2f(scaleInUniform, (2/w), (2/h) / as);
    glUniform4f(hmdWarpParamUniform, 1.0, 0.22, 0.24, 0.0);
    glUniform2f(lensCenterUniform, x + (w + distortion * 0.5f)*0.5f, y + h*0.5f);
    glUniform2f(screenCenterUniform, x + w*0.5f, y + h*0.5f);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, leftEyeTexture);
    glUniform1i(displayInputTextureUniform, 0);
    glVertexAttribPointer(displayPositionAttribute, 2, GL_FLOAT, 0, 0, leftEyeVertices);
    glVertexAttribPointer(displayTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    // Right eye
    distortion = -0.151976 * 2.0;
    glUniform2f(lensCenterUniform, x + (w + distortion * 0.5f)*0.5f, y + h*0.5f);
    glUniform2f(screenCenterUniform, 0.5f, 0.5f);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, rightEyeTexture);
    glUniform1i(displayInputTextureUniform, 1);
    glVertexAttribPointer(displayPositionAttribute, 2, GL_FLOAT, 0, 0, rightEyeVertices);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindTexture(GL_TEXTURE_2D, 0);
}


- (void) initShader
{
    displayProgram = [[GLProgram alloc] initWithVertexShaderFilename:@"Shader"
                                          fragmentShaderFilename:@"Shader"];
    [displayProgram addAttribute:@"position"];
    [displayProgram addAttribute:@"inputTextureCoordinate"];

    if (![displayProgram link])
    {
        NSLog(@"Link failed");
        NSString *progLog = [displayProgram programLog];
        NSLog(@"Program Log: %@", progLog);
        NSString *fragLog = [displayProgram fragmentShaderLog];
        NSLog(@"Frag Log: %@", fragLog);
        NSString *vertLog = [displayProgram vertexShaderLog];
        NSLog(@"Vert Log: %@", vertLog);
        displayProgram = nil;
    }
    
    displayPositionAttribute = [displayProgram attributeIndex:@"position"];
    displayTextureCoordinateAttribute = [displayProgram attributeIndex:@"inputTextureCoordinate"];
    displayInputTextureUniform = [displayProgram uniformIndex:@"inputImageTexture"];
    
    screenCenterUniform = [displayProgram uniformIndex:@"ScreenCenter"];
    scaleUniform = [displayProgram uniformIndex:@"Scale"];
    scaleInUniform = [displayProgram uniformIndex:@"ScaleIn"];
    hmdWarpParamUniform = [displayProgram uniformIndex:@"HmdWarpParam"];
    lensCenterUniform = [displayProgram uniformIndex:@"LensCenter"];

    [displayProgram use];

    glEnableVertexAttribArray(displayPositionAttribute);
    glEnableVertexAttribArray(displayTextureCoordinateAttribute);
}




#pragma mark - create scenekit scene

- (SCNScene *) createScene
{
//    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.dae"];
    SCNScene *scene = [[SCNScene alloc] init];
    
    SCNNode *node1 = [SCNNode nodeWithGeometry:[SCNBox boxWithWidth:1 height:1 length:1 chamferRadius:0]];
    node1.position = SCNVector3Make( 0, 0, -7 );
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [UIColor blueColor];
    material.locksAmbientWithDiffuse = true;
    material.writesToDepthBuffer = true;
    node1.geometry.firstMaterial = material;
    
    
    SCNNode *node2 = [SCNNode nodeWithGeometry:[SCNBox boxWithWidth:1 height:1 length:1 chamferRadius:0]];
    node2.position = SCNVector3Make( -2, 0, -5 );
    material = [SCNMaterial material];
    material.diffuse.contents = [UIColor redColor];
    material.locksAmbientWithDiffuse = true;
    material.writesToDepthBuffer = true;
    node2.geometry.firstMaterial = material;
    
    SCNNode *node3 = [SCNNode nodeWithGeometry:[SCNBox boxWithWidth:1 height:1 length:1 chamferRadius:0]];
    node3.position = SCNVector3Make( 2, 0, -3 );
    material = [SCNMaterial material];
    material.diffuse.contents = [UIColor greenColor];
    material.locksAmbientWithDiffuse = true;
    material.writesToDepthBuffer = true;
    node3.geometry.firstMaterial = material;

    
    [scene.rootNode addChildNode:node1];
    [scene.rootNode addChildNode:node3];
    [scene.rootNode addChildNode:node2];
    
    
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
    
    // Animate Node 1
    SCNAction *m1 = [SCNAction moveTo:SCNVector3Make(-2, 0, -7) duration:1];
    SCNAction *m2 = [SCNAction moveTo:SCNVector3Make(2, 0, -7) duration:2];
    SCNAction *m3 = [SCNAction moveTo:SCNVector3Make(0, 0, -7) duration:1];
    SCNAction *s = [SCNAction sequence:@[m1, m2, m3]];
    [node1 runAction:[SCNAction repeatActionForever:s]];

    
    // Animate Node 2
    m1 = [SCNAction moveTo:SCNVector3Make(2, 0, -5) duration:2];
    m2 = [SCNAction moveTo:SCNVector3Make(-2, 0, -5) duration:2];
    s = [SCNAction sequence:@[m1, m2]];
    [node2 runAction:[SCNAction repeatActionForever:s]];
    
    // Animate Node 3
    m1 = [SCNAction moveTo:SCNVector3Make(-2, 0, -3) duration:2];
    m2 = [SCNAction moveTo:SCNVector3Make(2, 0, -3) duration:2];
    s = [SCNAction sequence:@[m1, m2]];
    [node3 runAction:[SCNAction repeatActionForever:s]];
    
    return scene;
}

#pragma mark -
#pragma mark Accessors

- (SCNMatrix4)getCameraTranslationForEye:(int)eye
{
    // TODO: read IPD from HMD?
    float x = (-1 * eye) * (interpupillaryDistance/-2.0);
    return SCNMatrix4MakeTranslation(x, 0.0, 0 );
}
- (void)setInterpupillaryDistance:(CGFloat)ipd;
{
    NSLog(@"IPD: %f", ipd);
    interpupillaryDistance = ipd;
    leftEyeCameraNode.transform = [self getCameraTranslationForEye:LEFT];
    rightEyeCameraNode.transform = [self getCameraTranslationForEye:RIGHT];
}


#pragma mark - CoreMotion
- (void) setupCoreMotion
{
    motionManager = [[CMMotionManager alloc] init];
    referenceAttitude = nil;
    
    [self enableMotion];
}

-(void) enableMotion{
    [motionManager startDeviceMotionUpdates];
}

-(void) getDeviceGLRotationMatrix
{
    if (referenceAttitude == nil)
    {
        CMDeviceMotion *deviceMotion = motionManager.deviceMotion;
        CMAttitude *attitude = deviceMotion.attitude;
        referenceAttitude = attitude;
        refYaw = referenceAttitude.yaw;
        refPitch = referenceAttitude.pitch;
        refRoll = referenceAttitude.roll;
        return;
    }
    CMDeviceMotion *deviceMotion = motionManager.deviceMotion;
    CMAttitude *attitude = deviceMotion.attitude;
    [camera rotateViewRoundX:-(refRoll - attitude.roll) Y:refYaw - attitude.yaw Z:0];
    
    refYaw = attitude.yaw;
    refPitch = attitude.pitch;
    refRoll = attitude.roll;
}

@end
