//
//  MKRVideoProcessViewController.m
//  clipper
//
//  Created by Anton Zlotnikov on 14.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <AVKit/AVKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MKRVideoProcessViewController.h"
#import "MKRTrackCollectionViewCell.h"
#import "MKRScenesFillManager.h"
#import "MKRExportProcessor.h"
#import "MKRAudioProcessor.h"
#import "MKRTrack.h"

@class AVMutableVideoCompositionInstruction;

@interface MKRVideoProcessViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIImageView *loadingImageView;
@property (weak, nonatomic) IBOutlet UIView *exportView;
@property (weak, nonatomic) IBOutlet UIButton *saveToCameraRollButton;
@property (weak, nonatomic) IBOutlet UIButton *exportButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportViewRightConstraint;
@property (nonatomic) AVPlayerViewController *playerViewController;
- (IBAction)backButtonClick:(id)sender;
- (IBAction)exportButtonClick:(id)sender;
- (IBAction)saveToCameraRollClick:(id)sender;

@end

static NSString *const kMKRPlayerSegueIdentifier = @"playerSegue";
static NSString *const kMKRTrackCellIdentifier = @"trackCell";

@implementation MKRVideoProcessViewController {
    NSURL *assetUrl;
    NSURL *clippedVideoUrl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.exportView setHidden:YES];
    [self.view layoutIfNeeded];
    [self animateLoadingImageViewWithAngle:M_PI];
}

- (void)animateLoadingImageViewWithAngle:(CGFloat)angle {
    [UIView animateWithDuration:1.2 animations:^{
        self.loadingImageView.transform = CGAffineTransformMakeRotation(angle);
    } completion:^(BOOL finished) {
        [self animateLoadingImageViewWithAngle:angle + M_PI];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAssetUrl:(NSURL *)aUrl {
    assetUrl = aUrl;
}


- (void)handleVideo:(NSURL *)videoURL withTrackName:(NSString *)trackName onSuccess:(void (^)(NSURL *newVideoURL))success onFailure:(void (^)(NSError *error))failure {
    if (!trackName) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVAsset *avAsset = [AVAsset assetWithURL:videoURL];
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
        NSArray<AVMutableVideoCompositionInstruction *>* instructionsResult = [track getVideoLayerInstartions];
        
        [MKRExportProcessor exportAudioFromMutableCompositionToDocuments:resultAsset onSuccess:^(NSURL *newAssetUrl) {
            MKRAudioProcessor *audioProcessor = [[MKRAudioProcessor alloc] initWithOriginalPath:newAssetUrl.path andPlaybackPath:playbackPath];
            [audioProcessor processTrack:track andPlaybackFilePath:playbackPath withOriginalFilePath:newAssetUrl.path completion:^(NSURL *audioURL) {
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
                [MKRExportProcessor exportMutableCompositionToDocuments:resultAsset layerInstructions:instructionsResult onSuccess:success onFailure:failure];
            } failure:^(NSError *error) {
                NSLog(@"error = %@", error);
            }];
        } onFailure:failure];
    });
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MKRTrackCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMKRTrackCellIdentifier forIndexPath:indexPath];
    NSString *trackName = indexPath.row == 0 ? @"01" : @"02";
    [cell.trackTitleLabel setText:trackName];
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return !([collectionView.indexPathsForSelectedItems count] && collectionView.indexPathsForSelectedItems[0].row == indexPath.row);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *trackName = indexPath.row == 0 ? @"01" : @"02";
    [self.collectionView setUserInteractionEnabled:NO];
    [self.loadingView setHidden:NO];
    [self hideExportView];
    void (^finishBlock)() = ^void () {
        [self.collectionView setUserInteractionEnabled:YES];
        [self.loadingView setHidden:YES];
    };
    [self handleVideo:assetUrl withTrackName:trackName onSuccess:^(NSURL *newVideoURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            clippedVideoUrl = newVideoURL;
            [self.playerViewController setPlayer:[AVPlayer playerWithURL:clippedVideoUrl]];
            [self showExportView];
            finishBlock();
        });
    } onFailure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [collectionView deselectItemAtIndexPath:indexPath animated:YES];
            finishBlock();
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"Video is too short for this track :("
                                                                    preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];

            }];

            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }];
}

- (void)hideExportView {
    [self.exportViewRightConstraint setConstant:-120];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)showExportView {
    [self.exportView setHidden:NO];
    [self.exportViewRightConstraint setConstant:0];
    [UIView animateWithDuration:1.0 animations:^{
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kMKRPlayerSegueIdentifier]) {
        self.playerViewController = segue.destinationViewController;
        [self.playerViewController setPlayer:[AVPlayer playerWithURL:assetUrl]];
//        [self.playerViewController setShowsPlaybackControls:NO];
    }
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - User Actions

- (IBAction)backButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)exportButtonClick:(id)sender {
    [self.exportButton setEnabled:NO];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
            initWithActivityItems:@[@"Yo, Check it out! It is awesome!", clippedVideoUrl] applicationActivities:nil];
    NSArray *excludeActivities = @[
            UIActivityTypeAirDrop,
            UIActivityTypePrint,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToFacebook
    ];

    [activityVC setExcludedActivityTypes:excludeActivities];
    [self presentViewController:activityVC animated:YES completion:^(){
        [self.exportButton setEnabled:YES];
    }];
}

- (IBAction)saveToCameraRollClick:(id)sender {
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(clippedVideoUrl.path)) {
        [self.saveToCameraRollButton setEnabled:NO];
        UISaveVideoAtPathToSavedPhotosAlbum(clippedVideoUrl.path,self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.saveToCameraRollButton setEnabled:YES];
        NSString *msgTitle = @"Yo";
        NSString *msgSubtitle = @"Clipped video is saved to your camera roll";
        if (error) {
            msgTitle = @"Error";
            msgSubtitle = [error localizedDescription];
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:msgTitle
                                 message:msgSubtitle
                          preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                            [alert dismissViewControllerAnimated:YES completion:nil];

                        }];

        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    });
}



@end
