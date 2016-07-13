//
//  MKRVideoSelectViewController.m
//  clipper
//
//  Created by Anton Zlotnikov on 06.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRVideoSelectViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "MKRVad.h"
#import "MKRTrack.h"
#import "MKRScene.h"
#import "MKRBarManager.h"
#import "MKRBar.h"
#import "MKRAudioPostProcessor.h"
#import "MKRRawDataProcessor.h"
#import "MKRExportProcessor.h"


@interface MKRVideoSelectViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property MPMoviePlayerController *moviePlayerOld;
@property MPMoviePlayerController *moviePlayerNew;
@property (weak, nonatomic) IBOutlet UIView *moviePlaceViewOld;
@property (weak, nonatomic) IBOutlet UIView *moviePlaceViewNew;
@property (weak, nonatomic) IBOutlet UISwitch *videoSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectTrackSegmentedControl;

- (IBAction)changeVideoAction:(UISwitch *)sender;

- (IBAction)selectVideoClick:(UIBarButtonItem *)sender;

@end

@implementation MKRVideoSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setMoviePlayerOld:[[MPMoviePlayerController alloc] init]];
    [self.moviePlaceViewOld addSubview:self.moviePlayerOld.view];
    [self.moviePlayerOld setShouldAutoplay:NO];
    [self setMoviePlayerNew:[[MPMoviePlayerController alloc] init]];
    [self.moviePlaceViewNew addSubview:self.moviePlayerNew.view];
    [self.moviePlayerNew setShouldAutoplay:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.moviePlayerOld.view setFrame:self.moviePlaceViewOld.bounds];
    [self.moviePlayerNew.view setFrame:self.moviePlaceViewNew.bounds];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *videoURL = info[UIImagePickerControllerMediaURL];
    NSLog(@"VideoURL = %@", videoURL);
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self.moviePlayerOld setContentURL:videoURL];
    [self.moviePlayerOld prepareToPlay];
    [self handleVideo:videoURL onSuccess:^(NSURL *newVideoURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.moviePlayerNew setContentURL:newVideoURL];
            [self.videoSwitch setOn:YES];
            [self.moviePlayerNew prepareToPlay];
        });
    } onFailure:^(NSError *error) {
        return;
    }];

}

- (void)handleVideo:(NSURL *)videoURL onSuccess:(void (^)(NSURL *newVideoURL))success onFailure:(void (^)(NSError *error))failure {
    AVAsset *avAsset = [AVAsset assetWithURL:videoURL];
    NSArray *audioTracks = [avAsset tracksWithMediaType:AVMediaTypeAudio];
    AVAssetTrack *audioTrack = audioTracks[0];

    NSData *audioData = [MKRRawDataProcessor audioRawDataForTrack:audioTrack withReaderSettings:@{
            AVSampleRateKey: @16000,
            AVLinearPCMBitDepthKey: @16,
            AVFormatIDKey: @(kAudioFormatLinearPCM),
            AVLinearPCMIsFloatKey: @NO
    }];
    
    CMTime audioDuration = avAsset.duration;
    NSInteger audioMsDuration = round(CMTimeGetSeconds(audioDuration) * 1000);
    
    MKRVad *vad = [[MKRVad alloc] init];
    NSMutableArray<MKRInterval *> *speechIntervals = [vad gotAudioWithSamples:audioData andAudioMsDuration:audioMsDuration];
    
    NSLog(@"VAD complete, found %lu speech intervals", [speechIntervals count]);
    for (MKRInterval *interval in speechIntervals) {
        NSLog(@"[%f, %f]", interval.start / 1000.0, interval.end / 1000.0);
    }
    
    NSString *trackName = self.selectTrackSegmentedControl.selectedSegmentIndex == 0 ? @"01" : @"02";
    NSString *trackMetaDataPath = [[NSBundle mainBundle] pathForResource:trackName ofType:@"plist"];
    MKRTrack *track = [[MKRTrack alloc] initWithMetaDataPath:trackMetaDataPath andFeaturesInterval:speechIntervals];
    if (![track fillScenes]) {
        NSLog(@"Track scenes filling failed");
        failure([NSError errorWithDomain:@"MayakRed" code:0 userInfo:nil]);
        return;
    }
    
    NSString *playbackPath = [[NSBundle mainBundle] pathForResource:trackName ofType:@"wav"];
    AVAsset *playback = [AVAsset assetWithURL:[NSURL fileURLWithPath:playbackPath]];
    
    AVMutableComposition *resultAsset = [track processVideo:avAsset andAudio:playback];
    [MKRExportProcessor exportMutableCompositionToDocuments:resultAsset onSuccess:success onFailure:failure];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - User actions

- (IBAction)changeVideoAction:(UISwitch *)sender {
    if (sender.isOn) {
        [self.moviePlayerNew prepareToPlay];
    } else {
        [self.moviePlayerOld prepareToPlay];
    }
}

- (IBAction)selectVideoClick:(UIBarButtonItem *)sender {
    // Present videos from which to choose
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
    [videoPicker setDelegate:self]; // ensure you set the delegate so when a video is chosen the right method can be called

    [videoPicker setModalPresentationStyle:UIModalPresentationCurrentContext];
    // This code ensures only videos are shown to the end user
    [videoPicker setMediaTypes:@[(NSString *) kUTTypeMovie, (NSString *) kUTTypeAVIMovie, (NSString *) kUTTypeVideo, (NSString *) kUTTypeMPEG4]];

    [videoPicker setVideoQuality:UIImagePickerControllerQualityTypeHigh];
    [self presentViewController:videoPicker animated:YES completion:nil];
}
@end
