//
//  Shader.fsh
//  TestVR
//
//  Created by Andy Qua on 19/09/2014.
//  Copyright (c) 2014 Andy Qua. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
