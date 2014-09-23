//
//  Constants.h
//  TestVR
//
//  Created by Andy Qua on 21/09/2014.
//  Copyright (c) 2014 Andy Qua. All rights reserved.
//

#ifndef TestVR_Constants_h
#define TestVR_Constants_h

#define GLKIT_SCENE @"GLKit"
#define SCENEKIT_SCENE @"SceneKit"


#define ARC4RANDOM_MAX      0x100000000
#define RAND_DOUBLE     ((double)arc4random() / ARC4RANDOM_MAX)

#define EYE_RENDER_RESOLUTION_X 800
#define EYE_RENDER_RESOLUTION_Y 1000

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#define LEFT -1
#define RIGHT 1

#endif
