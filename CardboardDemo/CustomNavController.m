//
//  CustomNavController.m
//  CardboardDemo
//
//  Created by Andy Qua on 23/09/2014.
//  Copyright (c) 2014 Andy Qua. All rights reserved.
//

#import "CustomNavController.h"

@implementation CustomNavController

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

@end
