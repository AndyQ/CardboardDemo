//
//  StereoImageViewController.m
//  CardboardDemo
//
//  Created by Andy Qua on 21/09/2014.
//  Copyright (c) 2014 Andy Qua. All rights reserved.
//

@import AVFoundation;
@import MobileCoreServices;

#import "StereoImageViewController.h"
#import "Constants.h"

typedef enum StereoMode
{
    Parallel = 1,
    CrossEye
} StereoMode;



@interface StereoImageViewController () <UIImagePickerControllerDelegate>
{
    UIImage *leftImage;
    UIImage *rightImage;
    
    StereoMode mode;
    
    int captureState;
    AVCaptureSession *session;
    AVCaptureStillImageOutput *snapper;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
}

@property (nonatomic, weak) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnStereoType;
@property (nonatomic, weak) IBOutlet UIImageView *rightImageView;
@end

@implementation StereoImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage *image = [UIImage imageNamed:@"sample"];
    [self splitStereoImageFromImage:image];
    
    self.leftImageView.image = leftImage;
    self.rightImageView.image = rightImage;
    mode = Parallel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Split up stero image
- (void) splitStereoImageFromImage:(UIImage *)image
{
    CGImageRef tmpImgRef = image.CGImage;
    CGImageRef leftImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, 0, image.size.width/2.0, image.size.height));
    leftImage = [UIImage imageWithCGImage:leftImgRef];
    CGImageRelease(leftImgRef);
    
    CGImageRef rightImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(image.size.width/2.0, 0, image.size.width / 2.0,  image.size.height));
    rightImage = [UIImage imageWithCGImage:rightImgRef];
    CGImageRelease(rightImgRef);
}

- (UIImage *) createStereoImage
{
    // Join two images
    UIImage *left = mode == Parallel ? self.leftImageView.image : self.rightImageView.image;
    UIImage *right = mode == Parallel ? self.rightImageView.image : self.leftImageView.image;
    
    CGSize size = CGSizeMake(left.size.width + right.size.width, left.size.height);
    
    UIGraphicsBeginImageContext(size);
    
    [left drawInRect:CGRectMake(0, 0, left.size.width, left.size.height)];
    [right drawInRect:CGRectMake(left.size.width, 0, right.size.width, right.size.height)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (IBAction) changeStereoMode:(id)sender
{
    mode = (mode == Parallel) ? CrossEye : Parallel;
    if ( mode == Parallel )
    {
        self.leftImageView.image = leftImage;
        self.rightImageView.image = rightImage;
        
        [self.btnStereoType setTitle:@"Parallel" forState:UIControlStateNormal];
    }
    else
    {
        self.leftImageView.image = rightImage;
        self.rightImageView.image = leftImage;
        [self.btnStereoType setTitle:@"Cross-Eye" forState:UIControlStateNormal];
    }
}

- (IBAction) capturePressed:(id)sender
{
    if ( captureState == 0 )
    {
        [self startCam:LEFT];
        captureState++;
    }
    else if ( captureState == 1 )
    {
        // Capture image
        [self captureImage];
    }
    else if ( captureState == 2 )
    {
        // Capture image
        [self captureImage];
    }
}

- (IBAction) savePressed:(id)sender
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *img = [self createStereoImage];
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    });
}

- (IBAction) selectImagePressed:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePicker.mediaTypes = @[(NSString *) kUTTypeImage, (NSString *) kUTTypeMovie];
    
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}


-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if ( [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft)
    {
        captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    else if ( [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)
    {
        captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }
}

#pragma mark - Camera Capture 
- (void) stopCam
{
    [session stopRunning];
    session = nil;
    
    [captureVideoPreviewLayer removeFromSuperlayer];
    captureVideoPreviewLayer = nil;
}

-(void) startCam:(int)side
{
    AVCaptureDevice *device = [self CameraIfAvailable];
    if (device) {
        if (!session) {
            session = [[AVCaptureSession alloc] init];
        }
        session.sessionPreset = AVCaptureSessionPreset640x480;
        
        snapper = [AVCaptureStillImageOutput new];
        snapper.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG, AVVideoQualityKey:@0.6};
        [session addOutput:snapper];

        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (!input) {
            // Handle the error appropriately.
            NSLog(@"ERROR: trying to open camera: %@", error);
        }
        else
        {
            if ([session canAddInput:input]) {
                [session addInput:input];
                
                captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
                
                captureVideoPreviewLayer.frame = self.leftImageView.bounds;
                captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

                if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft)
                    captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                else
                    captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                
                if ( side == LEFT )
                    [self.leftImageView.layer addSublayer:captureVideoPreviewLayer];
                else
                    [self.rightImageView.layer addSublayer:captureVideoPreviewLayer];
                
                [session startRunning];
            } else {
                NSLog(@"Couldn't add input");
            }
        }
    } else {
        NSLog(@"Camera not available");
    }
}

- (void) captureImage
{
    AVCaptureConnection *vc = [snapper connectionWithMediaType:AVMediaTypeVideo];
    vc.videoOrientation = captureVideoPreviewLayer.connection.videoOrientation;
    
    typedef void(^MyBufBlock)(CMSampleBufferRef, NSError*);
    
    MyBufBlock h = ^(CMSampleBufferRef buf, NSError *err)
    {
        NSData* data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:buf];
        UIImage* im = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ( captureState == 1 )
            {
                leftImage = im;
                self.leftImageView.image = leftImage;
                [captureVideoPreviewLayer removeFromSuperlayer];
                [self.rightImageView.layer addSublayer:captureVideoPreviewLayer];
                captureState ++;
            }
            else
            {
                rightImage = im;
                self.rightImageView.image = rightImage;
                
                // Stop camera session
                [self stopCam];
                captureState = 0;

            }
        });
    };
    [snapper captureStillImageAsynchronouslyFromConnection:vc completionHandler:h];
}

-(AVCaptureDevice *)CameraIfAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            captureDevice = device;
            break;
        }
    }
    
    //just in case
    if (!captureDevice) {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    return captureDevice;
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *) picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        [self splitStereoImageFromImage:image];
        
        self.leftImageView.image = leftImage;
        self.rightImageView.image = rightImage;
        mode = Parallel;
        [self.btnStereoType setTitle:@"Parallel" forState:UIControlStateNormal];

    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Media is a video
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
