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
#import "MKRExportProcessor.h"
#import "MKRScenesFillManager.h"
#import "MKRAudioProcessor.h"


@interface MKRVideoSelectViewController ()

@property MPMoviePlayerController *moviePlayer;
@property (weak, nonatomic) IBOutlet UIView *moviePlaceView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectTrackSegmentedControl;

- (IBAction)saveButtonClick:(id)sender;
- (IBAction)playButtonClick:(id)sender;
- (IBAction)closeButtonClick:(id)sender;

@end

@implementation MKRVideoSelectViewController {
    NSURL *videoUrl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setMoviePlayer:[[MPMoviePlayerController alloc] init]];
    [self.moviePlaceView addSubview:self.moviePlayer.view];
    [self.moviePlayer setShouldAutoplay:NO];
    [self.moviePlayer setContentURL:videoUrl];
    [self.moviePlayer prepareToPlay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.moviePlayer.view setFrame:self.moviePlaceView.bounds];
}

- (void)setVideoUrl:(NSURL *)vUrl {
    videoUrl = vUrl;
}

- (void)handleVideo:(NSURL *)videoURL onSuccess:(void (^)(NSURL *newVideoURL))success onFailure:(void (^)(NSError *error))failure {
    AVAsset *avAsset = [AVAsset assetWithURL:videoURL];

    NSString *trackName = self.selectTrackSegmentedControl.selectedSegmentIndex == 0 ? @"01" : @"02";

    NSString *playbackPath = [[NSBundle mainBundle] pathForResource:trackName ofType:@"wav"];

    MKRScenesFillManager *scenesFillManager = [[MKRScenesFillManager alloc] initWithMetaDataPath:[[NSBundle mainBundle]
            pathForResource:trackName ofType:@"plist"]];

    MKRTrack *track = [scenesFillManager tryToFillScenesWithAsset:avAsset];
    if (!track) {
        NSLog(@"Track scenes filling failed");
        failure([NSError errorWithDomain:@"MayakRed" code:0 userInfo:nil]);
        return;
    }

    AVMutableComposition *resultAsset = [track processVideo:avAsset];
    [MKRExportProcessor exportAudioFromMutableCompositionToDocuments:resultAsset onSuccess:^(NSURL *assetUrl) {
        MKRAudioProcessor *audioProcessor = [[MKRAudioProcessor alloc] initWithOriginalPath:assetUrl.path andPlaybackPath:playbackPath];
        [audioProcessor processTrack:track andPlaybackFilePath:playbackPath withOriginalFilePath:assetUrl.path completion:^(NSURL *audioURL) {
            NSArray<AVCompositionTrack *> *audioTracks = [resultAsset tracksWithMediaType:AVMediaTypeAudio];
            for (AVCompositionTrack *audioTrack in audioTracks) {
                [resultAsset removeTrack:audioTrack];
            }
            
            AVAsset *realAudio = [AVAsset assetWithURL:audioURL];
            
            NSLog(@"result asset duration = %f, realAudio duration = %f", CMTimeGetSeconds(resultAsset.duration), CMTimeGetSeconds(realAudio.duration));
            NSArray<AVAssetTrack *> *realAudioTracks = [realAudio tracksWithMediaType:AVMediaTypeAudio];
            int trackId = 10;
            for (AVAssetTrack *audioTrack in realAudioTracks) {
                AVMutableCompositionTrack *playbackTrack = [resultAsset addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:trackId++];
//                CMTime startOffset = CMTimeSubtract(CMTimeMaximum(resultAsset.duration, realAudio.duration), CMTimeMinimum(resultAsset.duration, realAudio.duration));
                [playbackTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, realAudio.duration) ofTrack:audioTrack atTime:kCMTimeZero error:nil];
            }
            [MKRExportProcessor exportMutableCompositionToDocuments:resultAsset onSuccess:success onFailure:failure];
        } failure:^(NSError *error) {
            NSLog(@"error = %@", error);
        }];
    } onFailure:failure];
    

//    [MKRExportProcessor exportMutableCompositionToDocuments:resultAsset onSuccess:success onFailure:failure];
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

- (IBAction)saveButtonClick:(id)sender {
    UISaveVideoAtPathToSavedPhotosAlbum(self.moviePlayer.contentURL.path, nil, NULL, NULL);
}

- (IBAction)playButtonClick:(id)sender {
    [self handleVideo:videoUrl onSuccess:^(NSURL *newVideoURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.moviePlayer setContentURL:newVideoURL];
            [self.moviePlayer prepareToPlay];
        });
    } onFailure:^(NSError *error) {
        return;
    }];
}

- (IBAction)closeButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
