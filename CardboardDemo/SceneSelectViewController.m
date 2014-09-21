//
//  SceneSelectViewController.m
//  TestVR
//
//  Created by Andy Qua on 21/09/2014.
//  Copyright (c) 2014 Andy Qua. All rights reserved.
//

#import "SceneSelectViewController.h"
#import "GameViewController.h"
#import "Constants.h"

@interface SceneSelectViewController ()

@end

@implementation SceneSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue
{
    
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.identifier isEqualToString:@"showGLKit"] )
    {
        GameViewController *vc = [segue destinationViewController];
        vc.sceneType = GLKIT_SCENE;
    }
    else if ( [segue.identifier isEqualToString:@"showSceneKit"] )
    {
        GameViewController *vc = [segue destinationViewController];
        vc.sceneType = SCENEKIT_SCENE;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


#pragma mark - UIAlert for info popup
- (IBAction) infoPressed:(id)sender
{
    NSString *msg = @"Cardboard demo uses code from the following people/projects.\n\n" \
        "OculusRiftSceneKit by Brad Larson / Sunset Lake Software\n\n" \
        "Jeff LaMarche - GLProgram OpenGL shader wrapper\n";
    
    UIAlertController * alert= [UIAlertController alertControllerWithTitle:@"Acknowledgments"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


@end
