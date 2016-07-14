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
#import "MKRCustomVideoCompositor.h"
#import "MKRScenesFillManager.h"
#import "MKRExportProcessor.h"


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

    MKRScenesFillManager *scenesFillManager = [[MKRScenesFillManager alloc] initWithMetaDataPath:[[NSBundle mainBundle]
            pathForResource:trackName ofType:@"plist"]];

    MKRTrack *track = [scenesFillManager tryToFillScenesWithAsset:avAsset];
    if (!track) {
        NSLog(@"Track scenes filling failed");
        failure([NSError errorWithDomain:@"MayakRed" code:0 userInfo:nil]);
        return;
    }
    
    NSString *playbackPath = [[NSBundle mainBundle] pathForResource:trackName ofType:@"wav"];
    AVAsset *playback = [AVAsset assetWithURL:[NSURL fileURLWithPath:playbackPath]];
    
    AVMutableComposition *result = [track processVideo:avAsset andAudio:playback];
    
    AVAssetExportSession *export = [[AVAssetExportSession alloc] initWithAsset:result presetName:AVAssetExportPresetHighestQuality];
    export.outputFileType = AVFileTypeQuickTimeMovie;

    AVMutableComposition *resultAsset = [track processVideo:avAsset andAudio:playback];
    [MKRExportProcessor exportMutableCompositionToDocuments:resultAsset layerInstructions:nil onSuccess:success onFailure:failure];
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
