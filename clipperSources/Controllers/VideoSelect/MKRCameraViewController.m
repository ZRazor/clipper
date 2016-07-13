//
//  MKRCameraViewController.m
//  clipper
//
//  Created by Anton Zlotnikov on 13.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRCameraViewController.h"
#import "MKRVideoSelectViewController.h"
#import <Photos/PHAsset.h>
#import <Photos/PHFetchOptions.h>
#import <Photos/PHImageManager.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface MKRCameraViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIButton *libraryButton;
@property (nonatomic) UIImagePickerController *picker;
- (IBAction)libraryButtonClick:(id)sender;
@end

static NSString *const kMKRSelectVideoIdentifier = @"selectVideo";

@implementation MKRCameraViewController {
    NSURL *pickedVideoUrl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpInterface {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    [fetchOptions setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]]];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    PHAsset *lastAsset = [fetchResult lastObject];
    [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                               targetSize:CGSizeMake(50, 50)
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self.libraryButton setBackgroundImage:result forState:UIControlStateNormal];
                                                });
                                            }];

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];

        [myAlertView show];

    } else {
        [self setPicker:[[UIImagePickerController alloc] init]];
        [self.picker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self.picker setMediaTypes:@[(NSString *) kUTTypeMovie, (NSString *) kUTTypeAVIMovie, (NSString *) kUTTypeVideo, (NSString *) kUTTypeMPEG4]];
        [self.picker setVideoQuality:UIImagePickerControllerQualityTypeHigh];
        [self.picker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo];
        [self.picker setCameraDevice:UIImagePickerControllerCameraDeviceRear];
        [self.picker setShowsCameraControls:NO];
        [self.picker setNavigationBarHidden:YES];
        [self.picker setToolbarHidden:YES];
        //TODO add transfor
        //self.picker.cameraViewTransform = CGAffineTransformMakeTranslation(0.0, 71.0);

        [self.picker setDelegate:self];
        [self.cameraView setClipsToBounds:YES];
        [self.cameraView addSubview:self.picker.view];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    pickedVideoUrl = info[UIImagePickerControllerMediaURL];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self performSegueWithIdentifier:kMKRSelectVideoIdentifier sender:self];

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kMKRSelectVideoIdentifier]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        [(MKRVideoSelectViewController *)navController.visibleViewController setVideoUrl:pickedVideoUrl];
    }
}


#pragma mark - User Actions

- (IBAction)libraryButtonClick:(id)sender {
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
    [videoPicker setDelegate:self]; // ensure you set the delegate so when a video is chosen the right method can be called
    [videoPicker setModalPresentationStyle:UIModalPresentationCurrentContext];
    [videoPicker setMediaTypes:@[(NSString *) kUTTypeMovie, (NSString *) kUTTypeAVIMovie, (NSString *) kUTTypeVideo, (NSString *) kUTTypeMPEG4]];
    [videoPicker setVideoQuality:UIImagePickerControllerQualityTypeHigh];
    [self presentViewController:videoPicker animated:YES completion:nil];
}
@end
