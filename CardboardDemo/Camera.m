//
//  Camera.m
//  CardboardDemo
//
//  Created by Andy Qua on 07/02/2012.
//  Copyright (c) 2012 Andy Qua. All rights reserved.
//

#import "Camera.h"


@implementation Camera

-(id) init
{
	GLKVector3 vZero = GLKVector3Make( 0, 0, 0 );
	GLKVector3 vView = GLKVector3Make( 0, 1, 0.5f );
	GLKVector3 vUp = GLKVector3Make( 0, 1, 0 );
	
    _m_vPosition	= vZero;
    _m_vView		= vView;
	_m_vUpVector	= vUp;
	
	return self;
}

-(GLKMatrix4) lookAt
{
    GLKMatrix4 lookAtMatrix = GLKMatrix4MakeLookAt(_m_vPosition.x, _m_vPosition.y, _m_vPosition.z,
                                                      _m_vView.x,	 _m_vView.y,     _m_vView.z,	
                                                      _m_vUpVector.x, _m_vUpVector.y, _m_vUpVector.z);

    
    return lookAtMatrix;
}



 
/*
 * This function sets the camera's position, view and up point.
 */
-(void) positionCameraAtX:(float)positionX Y:(float)positionY Z:(float)positionZ
					   VX:(float)viewX VY:(float)viewY VZ:(float)viewZ 
					   UpX:(float)upGLKVector3X UpY:(float)upGLKVector3Y UpZ:(float)upGLKVector3Z
{
	_m_vPosition	= GLKVector3Make( positionX, positionY, positionZ );
	_m_vView	= GLKVector3Make( viewX, viewY, viewZ );
	_m_vUpVector	= GLKVector3Make( upGLKVector3X, upGLKVector3Y, upGLKVector3Z );
}


/*
  * This rotates the camera view around point
 */
-(void) rotateViewRoundX:(float)X Y:(float)Y Z:(float)Z
{
	GLKVector3 point;
	
	point.x = _m_vView.x - _m_vPosition.x;
	point.y = _m_vView.y - _m_vPosition.y;
	point.z = _m_vView.z - _m_vPosition.z;
	
	if( X != 0.0f )
	{
		_m_vView.z = (float)(_m_vPosition.z + sin(X)*point.y + cos(X)*point.z);
		_m_vView.y = (float)(_m_vPosition.y + cos(X)*point.y - sin(X)*point.z);
	}
	if( Y != 0.0f )
	{
		_m_vView.z = (float)(_m_vPosition.z + sin(Y) * point.x + cos(Y) * point.z);
		_m_vView.x = (float)(_m_vPosition.x + cos(Y)*point.x - sin(Y)*point.z);
	}
	if( Z != 0.0f )
	{
		_m_vView.x = (float)(_m_vPosition.x + sin(Z)*point.y + cos(Z)*point.x);
		_m_vView.y = (float)(_m_vPosition.y + cos(Z)*point.y - sin(Z)*point.x);
	}
}

/*
 * Rotates the camera position around a specific point
 */
-(void) rotateCameraAroundPointAtX:(float)X Y:(float)Y Z:(float)Z
{
    GLKVector3 point;
    
    point.x = _m_vPosition.x - _m_vView.x;
    point.y = _m_vPosition.y - _m_vView.y;
    point.z = _m_vPosition.z - _m_vView.z;
    
    if(X != 0)
    {
        _m_vPosition.z = (float)(_m_vView.z + sin(X)*point.y + cos(X)*point.z);
        _m_vPosition.y = (float)(_m_vView.y + cos(X)*point.y - sin(X)*point.z);
    }
    if(Y != 0 )
    {
        _m_vPosition.z = (float)(_m_vView.z + sin(Y)*point.x + cos(Y)*point.z);
        _m_vPosition.x = (float)(_m_vView.x + cos(Y)*point.x - sin(Y)*point.z);
    }
    if(Z != 0)
    {
        _m_vPosition.x = (float)(_m_vView.x + sin(Z)*point.y + cos(Z)*point.x);
        _m_vPosition.y = (float)(_m_vView.y + cos(Z)*point.y - sin(Z)*point.x);
    }
}


/*
 * Sets a specific rotation angle
 */
-(void) setRotationAngle:(float)X Y:(float)Y Z:(float)Z
{
	GLKVector3 point;
	
	point.x = _m_vView.x - _m_vPosition.x;
	point.y = _m_vView.y - _m_vPosition.y;
	point.z = _m_vView.z - _m_vPosition.z;
	
	if( X != 0.0f )
	{
		_m_vView.z = (float)(_m_vPosition.z + sin(X)*point.y + cos(X)*point.z);
		_m_vView.y = (float)(_m_vPosition.y + cos(X)*point.y - sin(X)*point.z);
	}
	if( Y != 0.0f )
	{
		_m_vView.z = (float)(_m_vPosition.z + sin(Y) * _m_vPosition.x + cos(Y) * _m_vPosition.z);
		_m_vView.x = (float)(_m_vPosition.x + cos(Y)*_m_vPosition.x - sin(Y)*_m_vPosition.z);
	}
	if( Z != 0.0f )
	{
		_m_vView.x = (float)(_m_vPosition.x + sin(Z)*point.y + cos(Z)*point.x);
		_m_vView.y = (float)(_m_vPosition.y + cos(Z)*point.y - sin(Z)*point.x);
	}
}


/*
 * This allows us to look around by dragging around, like in most first person games.
 */
-(void) moveCameraByfromPointToPoint:(CGPoint) prevPoint newPoint:(CGPoint)mousePos
{
	float deltaY  = 0.0f;
	float rotateY = 0.0f;
	
	if( (prevPoint.x == mousePos.x) && (prevPoint.y == mousePos.y) )
        return;
	
	rotateY = (float)( (prevPoint.x - mousePos.x) ) / 100;
	deltaY  = (float)( (prevPoint.y - mousePos.y) ) / 100;
	
	_m_vView.y += deltaY * 15;
	
	[self rotateViewRoundX:0 Y:-rotateY Z:0];
}



-(void) rotateAroundPointAtCenter:(GLKVector3)vCenter X:(float)X Y:(float)Y Z:(float)Z
{
	GLKVector3 point;
	
	point.x = _m_vPosition.x - vCenter.x;
	point.y = _m_vPosition.y - vCenter.y;
	point.z = _m_vPosition.z - vCenter.z;
	
	if(X != 0)
	{
		_m_vPosition.z = (float)(vCenter.z + sin(X)*point.y + cos(X)*point.z);
		_m_vPosition.y = (float)(vCenter.y + cos(X)*point.y - sin(X)*point.z);
	}
	if(Y != 0 )
	{
		_m_vPosition.z = (float)(vCenter.z + sin(Y)*point.x + cos(Y)*point.z);
		_m_vPosition.x = (float)(vCenter.x + cos(Y)*point.x - sin(Y)*point.z);
	}
	if(Z != 0)
	{
		_m_vPosition.x = (float)(vCenter.x + sin(Z)*point.y + cos(Z)*point.x);
		_m_vPosition.y = (float)(vCenter.y + cos(Z)*point.y - sin(Z)*point.x);
	}
}


-(GLKVector3) getVectorRightAnglesAwayFromCamera
{
	GLKVector3 vCross;
	
	GLKVector3 vViewPoint = GLKVector3Make( _m_vView.x - _m_vPosition.x, _m_vView.y - _m_vPosition.y, _m_vView.z - _m_vPosition.z );
	vCross.x = ((_m_vUpVector.y * vViewPoint.z) - (_m_vUpVector.z * vViewPoint.y));
	vCross.y = ((_m_vUpVector.z * vViewPoint.x) - (_m_vUpVector.x * vViewPoint.z));
	vCross.z = ((_m_vUpVector.x * vViewPoint.y) - (_m_vUpVector.y * vViewPoint.x));
	
	return vCross;
}

/*
 * Strafes the camera left or right by a set amount
 */
-(void) strafeCamera:(float)amount
{
    GLKVector3 vCross;
    
    GLKVector3 vViewPoint = GLKVector3Make( _m_vView.x - _m_vPosition.x, _m_vView.y - _m_vPosition.y, _m_vView.z - _m_vPosition.z );
    vCross.x = ((_m_vUpVector.y * vViewPoint.z) - (_m_vUpVector.z * vViewPoint.y));
    vCross.y = ((_m_vUpVector.z * vViewPoint.x) - (_m_vUpVector.x * vViewPoint.z));
    vCross.z = ((_m_vUpVector.x * vViewPoint.y) - (_m_vUpVector.y * vViewPoint.x));
    
    _m_vPosition.x += vCross.x * amount;
    _m_vPosition.z += vCross.z * amount;
    
    _m_vView.x += vCross.x * amount;
    _m_vView.z += vCross.z * amount;
}

/*
 * Raises or lowers the camera
 */
-(void)raiseCamera:(float)amount
{
	_m_vPosition.y += amount;
	_m_vView.y += amount;
}

/*
 * Move camera forwards or backwards by a set amount
 */
-(void)moveCamera:(float)amount
{
	GLKVector3 point;
	
	point.x = _m_vView.x - _m_vPosition.x;
	point.y = _m_vView.y - _m_vPosition.y;
	point.z = _m_vView.z - _m_vPosition.z;
	
	_m_vPosition.x += point.x * amount;
	_m_vPosition.z += point.z * amount;
	_m_vView.x += point.x * amount;
	_m_vView.z += point.z * amount;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"p - %@ v - %@, u - %@", NSStringFromGLKVector3(_m_vPosition), NSStringFromGLKVector3(_m_vView), NSStringFromGLKVector3(_m_vUpVector) ];
}

@end
