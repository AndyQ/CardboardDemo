//
//  Camera.h
//  CardboardDemo
//
//  Created by Andy Qua on 07/02/2012.
//  Copyright (c) 2012 Andy Qua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Camera : NSObject

@property (assign) GLKVector3 m_vPosition;
@property (assign) GLKVector3 m_vView;
@property (assign) GLKVector3 m_vUpVector;

-(id) init;
-(GLKMatrix4) lookAt;
-(void) positionCameraAtX:(float)positionX Y:(float)positionY Z:(float)positionZ
					   VX:(float)viewX VY:(float)viewY VZ:(float)viewZ 
					  UpX:(float)upPoint3DX UpY:(float)upPoint3DY UpZ:(float)upPoint3DZ;
-(void) rotateViewRoundX:(float)X Y:(float)Y Z:(float)Z;
-(void) rotateCameraAroundPointAtX:(float)X Y:(float)Y Z:(float)Z;
-(void) moveCameraByfromPointToPoint:(CGPoint) prevPoint newPoint:(CGPoint)mousePos;
-(void) setRotationAngle:(float)X Y:(float)Y Z:(float)Z;
-(void) rotateAroundPointAtCenter:(GLKVector3)vCenter X:(float)X Y:(float)Y Z:(float)Z;
-(GLKVector3) getVectorRightAnglesAwayFromCamera;
-(void) strafeCamera:(float)speed;
-(void) raiseCamera:(float)amount;
-(void) moveCamera:(float)speed;

@end
