//
//  MKRCameraViewController.m
//  clipper
//
//  Created by Anton Zlotnikov on 13.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRCameraViewController.h"
#import "MKRVideoSelectViewController.h"
#import "MKRRecordButton.h"
#import "UIColor+MKRColor.h"
#import <Photos/PHAsset.h>
#import <Photos/PHFetchOptions.h>
#import <Photos/PHImageManager.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface MKRCameraViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIButton *libraryButton;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIImageView *lockedCameraImageView;
@property (weak, nonatomic) IBOutlet MKRRecordButton *recordButton;
@property (nonatomic) UIImagePickerController *picker;
- (IBAction)libraryButtonClick:(id)sender;
- (IBAction)switchCameraClick:(id)sender;
- (IBAction)changeFlashClick:(id)sender;
- (IBAction)recordButtonClick:(MKRRecordButton *)sender;
@end

static NSString *const kMKRSelectVideoIdentifier = @"selectVideo";

@implementation MKRCameraViewController {
    NSURL *pickedVideoUrl;
    UIImagePickerControllerCameraDevice pickerCameraDevice;
    UIImagePickerControllerCameraFlashMode pickerFlashMode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkPermissions];
    [self setUpInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkPermissions {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized) {
        // all is ok
    } else {
        NSLog(@"No permissions for video");
        [self.lockedCameraImageView setHidden:NO];
        [self.recordButton setEnabled:NO];
        NSLog(@"Enabled %d", self.recordButton.enabled);
    }
}

- (void)setUpInterface {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    [fetchOptions setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]]];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:fetchOptions];
    PHAsset *lastAsset = [fetchResult lastObject];
    if (!lastAsset) {
        [self.libraryButton setBackgroundColor:[UIColor mkr_lightGrayColor]];
    }
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
        NSLog(@"No camera on simulator!");
    } else {
        pickerCameraDevice = UIImagePickerControllerCameraDeviceRear;
        pickerFlashMode = UIImagePickerControllerCameraFlashModeOff;

        [self setPicker:[[UIImagePickerController alloc] init]];
        [self.picker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self.picker setMediaTypes:@[(NSString *) kUTTypeMovie, (NSString *) kUTTypeAVIMovie, (NSString *) kUTTypeVideo, (NSString *) kUTTypeMPEG4]];
        [self.picker setVideoQuality:UIImagePickerControllerQualityTypeHigh];
        [self.picker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo];
        [self.picker setCameraDevice:pickerCameraDevice];
        [self.picker setCameraFlashMode:pickerFlashMode];
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

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)updateFlashButtonState {
    if (pickerCameraDevice == UIImagePickerControllerCameraDeviceFront) {
        [self.flashButton setBackgroundImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
        [self.flashButton setEnabled:NO];
    } else {
        if (pickerFlashMode == UIImagePickerControllerCameraFlashModeOff) {
            [self.flashButton setBackgroundImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
        } else if (pickerFlashMode == UIImagePickerControllerCameraFlashModeAuto) {
            [self.flashButton setBackgroundImage:[UIImage imageNamed:@"flash_auto"] forState:UIControlStateNormal];
        } else if (pickerFlashMode == UIImagePickerControllerCameraFlashModeOn) {
            [self.flashButton setBackgroundImage:[UIImage imageNamed:@"flash_on"] forState:UIControlStateNormal];
        }
        [self.flashButton setEnabled:YES];
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

- (IBAction)switchCameraClick:(id)sender {
    if (pickerCameraDevice == UIImagePickerControllerCameraDeviceRear) {
        pickerCameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
    else {
        pickerCameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    [self updateFlashButtonState];
    [self.picker setCameraDevice:pickerCameraDevice];
}

- (IBAction)changeFlashClick:(id)sender {
    if (pickerFlashMode == UIImagePickerControllerCameraFlashModeOff) {
        pickerFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    } else if (pickerFlashMode == UIImagePickerControllerCameraFlashModeAuto) {
        pickerFlashMode = UIImagePickerControllerCameraFlashModeOn;
    } else if (pickerFlashMode == UIImagePickerControllerCameraFlashModeOn) {
        pickerFlashMode = UIImagePickerControllerCameraFlashModeOff;
    }
    [self updateFlashButtonState];
    [self.picker setCameraFlashMode:pickerFlashMode];
}

- (IBAction)recordButtonClick:(MKRRecordButton *)sender {
    NSLog(@"Enabled %d", self.recordButton.enabled);
    [sender clickRecording];
    if (sender.isRecording) {
        [self.picker startVideoCapture];
    } else {
        [self.picker stopVideoCapture];
    }
}
@end
