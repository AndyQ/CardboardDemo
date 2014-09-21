//
//  Camera.m
//  City
//
//  Created by Andy Qua on 07/02/2012.
//  Copyright (c) 2012 Andy Qua. All rights reserved.
//

#import "Camera.h"

#define MAX_PITCH               85


@implementation Camera

@synthesize m_vPosition, m_vView, m_vUpVector;
/// <summary>
/// Summary description for Camera.
/// </summary>

// This is our camera class

/////	This is the class constructor
-(id) init
{
	// Init a GLKVector3 to 0 0 0 for our position
	GLKVector3 vZero = GLKVector3Make( 0, 0, 0 );
	// Init a starting view GLKVector3 (looking up and out the screen)
	GLKVector3 vView = GLKVector3Make( 0, 1, 0.5f );
	// Init a standard up GLKVector3 (Rarely ever changes)
	GLKVector3 vUp = GLKVector3Make( 0, 1, 0 );
	
	m_vPosition	= vZero;					// Init the position to zero
	m_vView		= vView;					// Init the view to a std starting view
	m_vUpVector	= vUp;						// Init the UpGLKVector3
	
	return self;
}

-(GLKMatrix4) Look
{
    // Calculate angle
//    float dist = MathDistance (m_vPosition.x, m_vPosition.z, m_vView.x, m_vView.z);
//    state.camera.angle.y = ClampAngle (-AngleBetweenPoints (m_vPosition.x, m_vPosition.z, m_vView.x, m_vView.z));
//    state.camera.angle.x = 90.0f + AngleBetweenPoints (0, m_vPosition.y, dist, m_vView.y);

//    state.camera.position = m_vPosition;
    
    GLKMatrix4 lookAtMatrix = GLKMatrix4MakeLookAt(m_vPosition.x, m_vPosition.y, m_vPosition.z,	
                                                      m_vView.x,	 m_vView.y,     m_vView.z,	
                                                      m_vUpVector.x, m_vUpVector.y, m_vUpVector.z);

    
    return lookAtMatrix;
/*
	// Give openGL our camera position, then camera view, then camera up vector
	gluLookAt(m_vPosition.x, m_vPosition.y, m_vPosition.z,	
				  m_vView.x,	 m_vView.y,     m_vView.z,	
				  m_vUpVector.x, m_vUpVector.y, m_vUpVector.z);
	
	//            Console.WriteLine("Pos - [{0}], View - [{1}]", m_vPosition, m_vView);
*/
}


///////////////////////////////// POSITION CAMERA \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////	This function sets the camera's position and view and up point.
/////
///////////////////////////////// POSITION CAMERA \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

-(void) PositionCameraAtX:(float)positionX Y:(float)positionY Z:(float)positionZ
					   VX:(float)viewX VY:(float)viewY VZ:(float)viewZ 
					   UpX:(float)upGLKVector3X UpY:(float)upGLKVector3Y UpZ:(float)upGLKVector3Z
{
	m_vPosition	= GLKVector3Make( positionX, positionY, positionZ );
	m_vView	= GLKVector3Make( viewX, viewY, viewZ );
	m_vUpVector	= GLKVector3Make( upGLKVector3X, upGLKVector3Y, upGLKVector3Z );
}


///////////////////////////////// ROTATE VIEW \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////	This rotates the view around the position
/////
///////////////////////////////// ROTATE VIEW \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

-(void) rotateViewRoundX:(float)X Y:(float)Y Z:(float)Z
{
	GLKVector3 point;
	
	// Get our view GLKVector3 (The direction we are facing)
	point.x = m_vView.x - m_vPosition.x;		// This gets the direction of the X
	point.y = m_vView.y - m_vPosition.y;		// This gets the direction of the Y
	point.z = m_vView.z - m_vPosition.z;		// This gets the direction of the Z
	
	// If we pass in a negative X Y or Z, it will rotate the opposite way,
	// so we only need one function for a left and right , up or down rotation.
	// I suppose we could have one move function too, but I decided not too.
	
	if( X != 0.0f )
	{
//		NSLog( @"v - %@ p - %@, t - %@", NSStringFromGLKVector3(m_vView), NSStringFromGLKVector3(m_vPosition), NSStringFromGLKVector3(point) );
		m_vView.z = (float)(m_vPosition.z + sin(X)*point.y + cos(X)*point.z);
		m_vView.y = (float)(m_vPosition.y + cos(X)*point.y - sin(X)*point.z);
	}
	if( Y != 0.0f )
	{
		m_vView.z = (float)(m_vPosition.z + sin(Y) * point.x + cos(Y) * point.z);
		m_vView.x = (float)(m_vPosition.x + cos(Y)*point.x - sin(Y)*point.z);
	}
	if( Z != 0.0f )
	{
		m_vView.x = (float)(m_vPosition.x + sin(Z)*point.y + cos(Z)*point.x);
		m_vView.y = (float)(m_vPosition.y + cos(Z)*point.y - sin(Z)*point.x);
	}
}


-(void) setRotationAngle:(float)X Y:(float)Y Z:(float)Z
{
	GLKVector3 point;
	
	// Get our view GLKVector3 (The direction we are facing)
	point.x = m_vView.x - m_vPosition.x;		// This gets the direction of the X
	point.y = m_vView.y - m_vPosition.y;		// This gets the direction of the Y
	point.z = m_vView.z - m_vPosition.z;		// This gets the direction of the Z
	
	// If we pass in a negative X Y or Z, it will rotate the opposite way,
	// so we only need one function for a left and right , up or down rotation.
	// I suppose we could have one move function too, but I decided not too.
	
	if( X != 0.0f )
	{
//		NSLog( @"v - %@ p - %@, t - %@", NSStringFromGLKVector3(m_vView), NSStringFromGLKVector3(m_vPosition), NSStringFromGLKVector3(point) );
		m_vView.z = (float)(m_vPosition.z + sin(X)*point.y + cos(X)*point.z);
		m_vView.y = (float)(m_vPosition.y + cos(X)*point.y - sin(X)*point.z);
	}
	if( Y != 0.0f )
	{
		m_vView.z = (float)(m_vPosition.z + sin(Y) * m_vPosition.x + cos(Y) * m_vPosition.z);
		m_vView.x = (float)(m_vPosition.x + cos(Y)*m_vPosition.x - sin(Y)*m_vPosition.z);
	}
	if( Z != 0.0f )
	{
		m_vView.x = (float)(m_vPosition.x + sin(Z)*point.y + cos(Z)*point.x);
		m_vView.y = (float)(m_vPosition.y + cos(Z)*point.y - sin(Z)*point.x);
	}
}


///////////////////////////////// MOVE CAMERA BY MOUSE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////	This allows us to look around uSing the mouse, like in most first person games.
/////
/////
///////////////////////////////// MOVE CAMERA BY MOUSE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

-(bool) MoveCameraByMouse:(CGPoint) prevPoint newPoint:(CGPoint)mousePos
{
	float deltaY  = 0.0f;							// This is the direction for looking up or down
	float rotateY = 0.0f;							// This will be the value we need to rotate around the Y axis (Left and Right)
	
	// If our cursor is still in the middle, we never moved... so don't update the screen
	if( (prevPoint.x == mousePos.x) && (prevPoint.y == mousePos.y) ) return false;
	
	// Get the direction the mouse moved in, but bring the number down to a reasonable amount
	rotateY = (float)( (prevPoint.x - mousePos.x) ) / 100;
	deltaY  = (float)( (prevPoint.y - mousePos.y) ) / 100;
	
	// Multiply the direction GLKVector3 for Y by an acceleration (The higher the faster is goes).
	m_vView.y += deltaY * 15;
	
	// Note, this is a bad way of doing this (Ideal would be spherical coordinates)
	
	// Check if the distance of our view exceeds 60 from our position, if so, stop it. (UP)
	//	if( ( m_vView.y - m_vPosition.y ) >  10)  m_vView.y = m_vPosition.y + 10;
	
	// Check if the distance of our view exceeds -60 from our position, if so, stop it. (DOWN)
	//	if( ( m_vView.y - m_vPosition.y ) < -10)  m_vView.y = m_vPosition.y - 10;
	
	// Here we rotate the view along the X avis depending on the direction (Left of Right)
	[self rotateViewRoundX:0 Y:-rotateY Z:0];
	
	// Return TRUE to say that we need to redraw the screen
	return true;
}


///////////////////////////////// ROTATE AROUND POINT \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////	This rotates the camera position around a given point
/////
///////////////////////////////// ROTATE AROUND POINT \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

-(void) RotateAroundPointAtX:(float)X Y:(float)Y Z:(float)Z
{
	GLKVector3 point;
	
	// Get the GLKVector3 from our position to the center we are rotating around
	point.x = m_vPosition.x - m_vView.x;		// This gets the direction of the X
	point.y = m_vPosition.y - m_vView.y;		// This gets the direction of the Y
	point.z = m_vPosition.z - m_vView.z;		// This gets the direction of the Z
	
	// Rotate the position along the desired axis around the desired point vCenter
	if(X != 0)
	{
		// Rotate the position up or down, then add it to the center point
		m_vPosition.z = (float)(m_vView.z + sin(X)*point.y + cos(X)*point.z);
		m_vPosition.y = (float)(m_vView.y + cos(X)*point.y - sin(X)*point.z);
	}
	if(Y != 0 )
	{
		// Rotate the position right or left, then add it to the center point
		m_vPosition.z = (float)(m_vView.z + sin(Y)*point.x + cos(Y)*point.z);
		m_vPosition.x = (float)(m_vView.x + cos(Y)*point.x - sin(Y)*point.z);
	}
	if(Z != 0)
	{
		// Rotate the position diagnally right or diagnally down, then add it to the center point
		m_vPosition.x = (float)(m_vView.x + sin(Z)*point.y + cos(Z)*point.x);
		m_vPosition.y = (float)(m_vView.y + cos(Z)*point.y - sin(Z)*point.x);
	}
}


-(void) RotateAroundPointAtCenter:(GLKVector3)vCenter X:(float)X Y:(float)Y Z:(float)Z
{
	GLKVector3 point;
	
	// Get the GLKVector3 from our position to the center we are rotating around
	point.x = m_vPosition.x - vCenter.x;		// This gets the direction of the X
	point.y = m_vPosition.y - vCenter.y;		// This gets the direction of the Y
	point.z = m_vPosition.z - vCenter.z;		// This gets the direction of the Z
	
	// Rotate the position along the desired axis around the desired point vCenter
	if(X != 0)
	{
		// Rotate the position up or down, then add it to the center point
		m_vPosition.z = (float)(vCenter.z + sin(X)*point.y + cos(X)*point.z);
		m_vPosition.y = (float)(vCenter.y + cos(X)*point.y - sin(X)*point.z);
	}
	if(Y != 0 )
	{
		// Rotate the position right or left, then add it to the center point
		m_vPosition.z = (float)(vCenter.z + sin(Y)*point.x + cos(Y)*point.z);
		m_vPosition.x = (float)(vCenter.x + cos(Y)*point.x - sin(Y)*point.z);
	}
	if(Z != 0)
	{
		// Rotate the position diagnally right or diagnally down, then add it to the center point
		m_vPosition.x = (float)(vCenter.x + sin(Z)*point.y + cos(Z)*point.x);
		m_vPosition.y = (float)(vCenter.y + cos(Z)*point.y - sin(Z)*point.x);
	}
}


/////// * /////////// * /////////// * NEW * /////// * /////////// * /////////// *

///////////////////////////////// STRAFE CAMERA \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////	This strafes the camera left and right depending on the speed (-/+)
/////
///////////////////////////////// STRAFE CAMERA \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

-(GLKVector3) getVectorRightAnglesAwayFromCamera
{
	GLKVector3 vCross;
	
	// Get the view GLKVector3 of our camera and store it in a local variable
	GLKVector3 vViewPoint = GLKVector3Make( m_vView.x - m_vPosition.x, m_vView.y - m_vPosition.y, m_vView.z - m_vPosition.z );							// GLKVector3 for the position/view.

	// Here we calculate the cross product of our up GLKVector3 and view GLKVector3
	
	// The X value for the GLKVector3 is:  (V1.y * V2.z) - (V1.z * V2.y)
	vCross.x = ((m_vUpVector.y * vViewPoint.z) - (m_vUpVector.z * vViewPoint.y));
	
	// The Y value for the GLKVector3 is:  (V1.z * V2.x) - (V1.x * V2.z)
	vCross.y = ((m_vUpVector.z * vViewPoint.x) - (m_vUpVector.x * vViewPoint.z));
	
	// The Z value for the GLKVector3 is:  (V1.x * V2.y) - (V1.y * V2.x)
	vCross.z = ((m_vUpVector.x * vViewPoint.y) - (m_vUpVector.y * vViewPoint.x));
	
	return vCross;
}

-(void) StrafeCamera:(float)speed
{
    // Strafing is quite simple if you understand what the cross product is.
    // If you have 2 GLKVector3s (say the up GLKVector3 and the view GLKVector3) you can
    // use the cross product formula to get a GLKVector3 that is 90 degrees from the 2 GLKVector3s.
    // For a better explanation on how this works, check out the OpenGL "Normals" tutorial at our site.
    
    // Initialize a variable for the cross product result
    GLKVector3 vCross;
    
    // Get the view GLKVector3 of our camera and store it in a local variable
    GLKVector3 vViewPoint = GLKVector3Make( m_vView.x - m_vPosition.x, m_vView.y - m_vPosition.y, m_vView.z - m_vPosition.z );							// GLKVector3 for the position/view.
    
    // Here we calculate the cross product of our up GLKVector3 and view GLKVector3
    
    // The X value for the GLKVector3 is:  (V1.y * V2.z) - (V1.z * V2.y)
    vCross.x = ((m_vUpVector.y * vViewPoint.z) - (m_vUpVector.z * vViewPoint.y));
    
    // The Y value for the GLKVector3 is:  (V1.z * V2.x) - (V1.x * V2.z)
    vCross.y = ((m_vUpVector.z * vViewPoint.x) - (m_vUpVector.x * vViewPoint.z));
    
    // The Z value for the GLKVector3 is:  (V1.x * V2.y) - (V1.y * V2.x)
    vCross.z = ((m_vUpVector.x * vViewPoint.y) - (m_vUpVector.y * vViewPoint.x));
    
    // Now we want to just add this new GLKVector3 to our position and view, as well as
    // multiply it by our speed factor.  If the speed is negative it will strafe the
    // opposite way.
    
    // Add the resultant GLKVector3 to our position
    m_vPosition.x += vCross.x * speed;
    m_vPosition.z += vCross.z * speed;
    
    // Add the resultant GLKVector3 to our view
    m_vView.x += vCross.x * speed;
    m_vView.z += vCross.z * speed;
}
// Raises or lowers the camera
-(void)raiseCamera:(float)amount
{
	m_vPosition.y += amount;
	m_vView.y += amount;
}

/////// * /////////// * /////////// * NEW * /////// * /////////// * /////////// *


///////////////////////////////// MOVE CAMERA \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////	This will move the camera forward or backward depending on the speed
/////
///////////////////////////////// MOVE CAMERA \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

-(void)MoveCamera:(float)speed
{
	GLKVector3 point;
	
	// Get our view GLKVector3 (The direciton we are facing)
	point.x = m_vView.x - m_vPosition.x;		// This gets the direction of the X
	point.y = m_vView.y - m_vPosition.y;		// This gets the direction of the Y
	point.z = m_vView.z - m_vPosition.z;		// This gets the direction of the Z
	
	m_vPosition.x += point.x * speed;		// Add our acceleration to our position's X
//	m_vPosition.y += point.y * speed;		// Add our acceleration to our position's Y
	m_vPosition.z += point.z * speed;		// Add our acceleration to our position's Z
	m_vView.x += point.x * speed;			// Add our acceleration to our view's X
//	m_vView.y += point.y * speed;			// Add our acceleration to our view's Y
	m_vView.z += point.z * speed;			// Add our acceleration to our view's Z
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"p - %@ v - %@, u - %@", NSStringFromGLKVector3(m_vPosition), NSStringFromGLKVector3(m_vView), NSStringFromGLKVector3(m_vUpVector) ];
}

@end
