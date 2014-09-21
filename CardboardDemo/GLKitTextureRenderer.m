//
//  GLKitSceneRenderer.m
//  TestVR
//
//  Created by Andy Qua on 21/09/2014.
//  Copyright (c) 2014 Andy Qua. All rights reserved.
//

#import "GLKitTextureRenderer.h"
#import "Camera.h"
#import "Constants.h"
#import <OpenGLES/ES2/glext.h>

@import GLKit;


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



@implementation GLKitTextureRenderer
{
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    Camera *camera;
    
    GLKBaseEffect *effect;
}

- (instancetype)initWithFrameSize:(CGSize)frameSize
{
    self = [super initWithFrameSize:frameSize];
    if (self) {
        camera = [[Camera alloc] init];
        
        [camera positionCameraAtX:0 Y:3 Z:-10
                               VX:0 VY:0 VZ:100
                              UpX:0 UpY:1 UpZ:0];
        
        [self setup:frameSize];
    }
    return self;
}

- (void) dealloc
{
    glDeleteBuffers(1, &_vertexBuffer );
    glDeleteVertexArraysOES(1, &_vertexArray );
}

- (void) updateFrameAtTime:(NSTimeInterval)timeSinceLastUpdate;
{
    [super updateFrameAtTime:timeSinceLastUpdate];
//    _rotation += timeSinceLastUpdate * 0.5f;
    
}

- (void) resetDevicePosition
{
    [super resetDevicePosition];
    [camera positionCameraAtX:0 Y:3 Z:-10
                           VX:0 VY:0 VZ:100
                          UpX:0 UpY:1 UpZ:0];

}

- (void) updateDevicePositionWithRoll:(float)roll  yaw:(float)yaw pitch:(float)pitch
{
    [super updateDevicePositionWithRoll:roll yaw:yaw pitch:pitch];

    [camera rotateViewRoundX:-(refRoll - roll) Y:(refYaw - yaw) Z:0];
    
    refRoll = roll;
    refYaw = yaw;
    refPitch = pitch;
}

- (void)renderLeftTexture
{
    [camera strafeCamera:-0.003];
    GLKMatrix4 modelViewMatrix = [camera lookAt];
    effect.transform.modelviewMatrix = modelViewMatrix;
    
    [self renderScene];
    [camera strafeCamera:0.003];
}


- (void)renderRightTexture
{
    // Right Eye
    [camera strafeCamera:0.003];
    GLKMatrix4 modelViewMatrix = [camera lookAt];
    effect.transform.modelviewMatrix = modelViewMatrix;
    [self renderScene];
    
    [camera strafeCamera:-0.003];
}


- (void) setup:(CGSize)frameSize
{
    effect = [[GLKBaseEffect alloc] init];
    effect.light0.enabled = GL_TRUE;
    effect.light0.diffuseColor = GLKVector4Make(1.0f, 1.f, 0.f, 1.0f);
    
    float aspect = fabsf(frameSize.width / frameSize.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    effect.transform.projectionMatrix = projectionMatrix;
    
    // Create buffers
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
}



- (void) renderScene
{
    glViewport(0, 0, EYE_RENDER_RESOLUTION_X, EYE_RENDER_RESOLUTION_Y);
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArrayOES(_vertexArray);
    
    GLKMatrix4 origM = effect.transform.modelviewMatrix;
    for ( float z = -20 ; z <= 20 ; z+=4 )
    {
        for ( float x = -20 ; x <= 20 ; x+=4 )
        {
            GLKMatrix4 m = origM;
            m = GLKMatrix4Translate(m, x, 0, z);
            m = GLKMatrix4Rotate(m, _rotation, 1.0f, 1.0f, 1.0f);
            effect.transform.modelviewMatrix = m;
            
            // Render the object with GLKit
            [effect prepareToDraw];
            
            glDrawArrays(GL_TRIANGLES, 0, 36);
            
        }
        
    }
    
    glBindVertexArrayOES(0);
}

@end
