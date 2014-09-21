//
//  Shader.vsh
//  TestVR
//
//  Created by Andy Qua on 19/09/2014.
//  Copyright (c) 2014 Andy Qua. All rights reserved.
//
/*
attribute vec4 position;
attribute vec3 normal;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
                 
    colorVarying = diffuseColor * nDotVP;
    
    gl_Position = modelViewProjectionMatrix * position;
}
*/
//
//  Shader.vsh
//  TestVR
//
//  Created by Andy Qua on 19/09/2014.
//  Copyright (c) 2014 Andy Qua. All rights reserved.
//

attribute vec4 position;
attribute vec4 inputTextureCoordinate;
varying vec2 textureCoordinate;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main()
{
    gl_Position = position;
    textureCoordinate = inputTextureCoordinate.xy;
}
