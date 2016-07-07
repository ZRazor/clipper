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
#import <pocketsphinx/pocketsphinx.h>

@interface MKRVideoSelectViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property MPMoviePlayerController *moviePlayerOld;
@property MPMoviePlayerController *moviePlayerNew;
@property (weak, nonatomic) IBOutlet UIView *moviePlaceViewOld;
@property (weak, nonatomic) IBOutlet UIView *moviePlaceViewNew;
@property (weak, nonatomic) IBOutlet UISwitch *videoSwitch;

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
    [self handleVideo:videoURL withCallback:^(NSURL *newVideoURL) {
        [self.moviePlayerNew setContentURL:videoURL];
        [self.videoSwitch setOn:YES];
        [self.moviePlayerNew prepareToPlay];
    }];

}

- (void)handleVideo:(NSURL *)videoURL withCallback:(void (^)(NSURL *newVideoURL))callback {
    //TODO do all the stuff here

    AVAsset *avAsset = [AVAsset assetWithURL:videoURL];
    NSError *error = nil;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:avAsset error:&error];
    NSArray *audioTracks = [avAsset tracksWithMediaType:AVMediaTypeAudio];
    for (AVAssetTrack *audioTrack in audioTracks) {
        NSLog(@"Track ID: %d", audioTrack.trackID);
        NSArray* formatDesc = audioTrack.formatDescriptions;
        for(unsigned int i = 0; i < [formatDesc count]; ++i) {
            CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef) formatDesc[i];
            const AudioStreamBasicDescription* bobTheDesc = CMAudioFormatDescriptionGetStreamBasicDescription (item);
            NSLog(@"mSampleRate: %lf",bobTheDesc->mSampleRate);
            NSLog(@"mFormatID: %u",(unsigned int)bobTheDesc->mFormatID);
            NSLog(@"mFormatFlags: %u",(unsigned int)bobTheDesc->mFormatFlags);
            NSLog(@"mBytesPerPacket: %u",(unsigned int)bobTheDesc->mBytesPerPacket);
            NSLog(@"mFramesPerPacket: %u",(unsigned int)bobTheDesc->mFramesPerPacket);
            NSLog(@"mBytesPerFrame: %u",(unsigned int)bobTheDesc->mBytesPerFrame);
            NSLog(@"mChannelsPerFrame: %u",(unsigned int)bobTheDesc->mChannelsPerFrame);
            NSLog(@"mBitsPerChannel: %u",(unsigned int)bobTheDesc->mBitsPerChannel);
            NSLog(@"mReserved: %u",(unsigned int)bobTheDesc->mReserved);
            NSLog(@"-------");
        }
        NSLog(@"nominalFrameRate: %f", audioTrack.nominalFrameRate);

        NSMutableDictionary* audioReadSettings = [NSMutableDictionary dictionary];
        [audioReadSettings setValue:@(kAudioFormatLinearPCM)
                             forKey:AVFormatIDKey];

        AVAssetReaderTrackOutput* readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:audioReadSettings];
        [reader addOutput:readerOutput];
        [reader startReading];

        CMSampleBufferRef sample = [readerOutput copyNextSampleBuffer];
        NSMutableData *audioData =[[NSMutableData alloc] init];
        while (sample != NULL) {
            if (sample == NULL)
                continue;
            AudioBufferList audioBufferList;
            CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer( sample );
            CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sample, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBuffer);

            for (int y = 0; y < audioBufferList.mNumberBuffers; y++) {
                AudioBuffer audioBuffer = audioBufferList.mBuffers[y];
                Float32 *frame = (Float32*)audioBuffer.mData;
                NSLog(@"Size of frame: %u", (unsigned int)audioBuffer.mDataByteSize);
                [audioData appendBytes:frame length:audioBuffer.mDataByteSize];
            }
            CFRelease(blockBuffer);
            blockBuffer=NULL;
            CFRelease(sample);
            sample = [readerOutput copyNextSampleBuffer];
        }
    }

    NSLog(@"Finish");

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask ,YES);
    NSString* documentsPath = paths[0];
    NSString *destPath = [documentsPath stringByAppendingPathComponent:[videoURL lastPathComponent]];
    [fileManager copyItemAtPath:[videoURL path] toPath:destPath error:&error];
    callback([NSURL fileURLWithPath:destPath]);
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
