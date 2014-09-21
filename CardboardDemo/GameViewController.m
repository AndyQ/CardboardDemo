//
//  GameViewController.m
//  TestVR
//
//  Created by Andy Qua on 19/09/2014.
//  Copyright (c) 2014 Andy Qua. All rights reserved.
//

#import "GameViewController.h"
#import "TextureRenderer.h"
#import "SceneKitTextureRenderer.h"
#import "GLKitTextureRenderer.h"
#import "Camera.h"
#import "GLProgram.h"
#import "Constants.h"
#import <OpenGLES/ES2/glext.h>

@import GLKit;
@import SceneKit;
@import QuartzCore;
@import CoreMotion;


@interface GameViewController () <SCNSceneRendererDelegate>
{
    GLProgram *displayProgram;
    GLint displayPositionAttribute, displayTextureCoordinateAttribute;
    GLint displayInputTextureUniform;
    
    GLint lensCenterUniform, screenCenterUniform, scaleUniform, scaleInUniform, hmdWarpParamUniform;
    
    GLuint leftEyeTexture, rightEyeTexture;
    GLuint leftEyeFramebuffer, rightEyeFramebuffer;
    GLuint leftEyeDepthBuffer, rightEyeDepthBuffer;

    
    // Core Motion stuff
    CMMotionManager *motionManager;
    
    TextureRenderer *renderer;
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


    glEnable(GL_DEPTH_TEST);
    
    [self commonInit];
    
    glUniform4f(hmdWarpParamUniform, 1.0, 0.22, 0.24, 0.0);

    if ( [self.sceneType isEqualToString:GLKIT_SCENE] )
    {
        renderer = [[GLKitTextureRenderer alloc] initWithFrameSize:self.view.bounds.size];
    }
    else
    {
        renderer = [[SceneKitTextureRenderer alloc] initWithFrameSize:self.view.bounds.size];
    }
    
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteFramebuffers(1, &leftEyeFramebuffer);
    glDeleteRenderbuffers(1, &leftEyeDepthBuffer);
    glDeleteTextures(1, &leftEyeTexture);
    glDeleteFramebuffers(1, &rightEyeFramebuffer);
    glDeleteRenderbuffers(1, &rightEyeDepthBuffer);
    glDeleteTextures(1, &rightEyeTexture);
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

}


#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    [self updateDeviceMotion];
    [renderer updateFrameAtTime:self.timeSinceLastUpdate];
    
    glBindFramebuffer(GL_FRAMEBUFFER, leftEyeFramebuffer);
    
    glViewport(0, 0, EYE_RENDER_RESOLUTION_X, EYE_RENDER_RESOLUTION_Y);
    glClearColor(0, 1, 1, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [renderer renderLeftTexture];
    
    
    glBindFramebuffer(GL_FRAMEBUFFER, rightEyeFramebuffer);
    glViewport(0, 0, EYE_RENDER_RESOLUTION_X, EYE_RENDER_RESOLUTION_Y);
    glClearColor(0, 1, 1, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [renderer renderLeftTexture];
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

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



#pragma mark - touch event
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [renderer resetDevicePosition];
}


#pragma mark - CoreMotion
- (void) setupCoreMotion
{
    motionManager = [[CMMotionManager alloc] init];
    
    [self enableMotion];
}

-(void) enableMotion{
    [motionManager startDeviceMotionUpdates];
}

-(void) updateDeviceMotion
{
    CMDeviceMotion *deviceMotion = motionManager.deviceMotion;
    if ( deviceMotion == nil )
        return;
    
    CMAttitude *attitude = deviceMotion.attitude;
    
    [renderer updateDevicePositionWithRoll:attitude.roll yaw:attitude.yaw pitch:attitude.pitch];
}


#pragma mark - UIAlert for info popup
- (IBAction) infoPressed:(id)sender
{
    UIAlertController * alert= [UIAlertController alertControllerWithTitle:@"Info"
                                  message:@"Tap on the screen to reset the view position"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}
@end
