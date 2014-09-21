//
//  Camera.h
//  City
//
//  Created by Andy Qua on 07/02/2012.
//  Copyright (c) 2012 Andy Qua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Camera : NSObject {
	GLKVector3 m_vPosition;								// The camera's position
	GLKVector3 m_vView;									// The camera's View
	GLKVector3 m_vUpVector;								// The camera's UpPoint3D
}

@property (assign) GLKVector3 m_vPosition;
@property (assign) GLKVector3 m_vView;
@property (assign) GLKVector3 m_vUpVector;

-(id) init;
-(GLKMatrix4) Look;
-(void) PositionCameraAtX:(float)positionX Y:(float)positionY Z:(float)positionZ
					   VX:(float)viewX VY:(float)viewY VZ:(float)viewZ 
					  UpX:(float)upPoint3DX UpY:(float)upPoint3DY UpZ:(float)upPoint3DZ;
-(void) rotateViewRoundX:(float)X Y:(float)Y Z:(float)Z;
-(bool) MoveCameraByMouse:(CGPoint) prevPoint newPoint:(CGPoint)mousePos;
-(void) RotateAroundPointAtX:(float)X Y:(float)Y Z:(float)Z;
-(void) setRotationAngle:(float)X Y:(float)Y Z:(float)Z;
-(void) RotateAroundPointAtCenter:(GLKVector3)vCenter X:(float)X Y:(float)Y Z:(float)Z;
-(GLKVector3) getVectorRightAnglesAwayFromCamera;
-(void) StrafeCamera:(float)speed;
-(void) StrafeCameraByAmount:(float)amount;
-(void)raiseCamera:(float)amount;
-(void)MoveCamera:(float)speed;

@end
