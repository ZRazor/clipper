//
//  MKRAudioProcessor.m
//  clipper
//
//  Created by dev on 14.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRAudioProcessor.h"
#import "MKRExportProcessor.h"
#import "MKRAUAudioFilePlayer.h"
#import "MKRAUMixer.h"
#import "MKRAUGenericOutput.h"
#import "MKRAUTimePitch.h"
#import "MKRAudioUnits.h"

const NSInteger kMKRUnit_GIO = 0;
const NSInteger kMKRUnit_OriginalPlayer = 1;
const NSInteger kMKRUnit_PlaybackPlayer = 2;
const NSInteger kMKRUnit_TimePitch = 3;
const NSInteger kMKRUnit_Mixer = 4;

OSStatus OSSTATUS = noErr;
#define OSSTATUS_CHECK if (OSSTATUS != 0) [NSException raise:NSInternalInconsistencyException format:@"OSStatus error: %d", (int)OSSTATUS];


@interface MKRAudioProcessor()

@property (nonatomic) AUGraph graph;
@property (nonatomic) Float64 sampleRate;
@property (nonatomic) AudioStreamBasicDescription stereoStreamFormat864;
@property (nonatomic) Float64 maxSampleTime;
@property (nonatomic) NSString *originalPath;
@property (nonatomic) NSString *playbackPath;

@end

@implementation MKRAudioProcessor

- (instancetype)initWithOriginalPath:(NSString *)originalPath andPlaybackPath:(NSString *)playbackPath {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setSampleRate:44100.0];
    [self setMaxSampleTime:0];
    [self setOriginalPath:originalPath];
    [self setPlaybackPath:playbackPath];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self initializeGraph];
    
    return self;
}

- (void)setupStereoStream864 {
    size_t bytesPerSample = sizeof(AudioUnitSampleType);
    _stereoStreamFormat864.mFormatID = kAudioFormatLinearPCM;
    _stereoStreamFormat864.mFormatFlags = kAudioFormatFlagsAudioUnitCanonical;
    _stereoStreamFormat864.mBytesPerPacket = (UInt32)bytesPerSample;
    _stereoStreamFormat864.mFramesPerPacket = 1;
    _stereoStreamFormat864.mBytesPerFrame = (UInt32)bytesPerSample;
    _stereoStreamFormat864.mChannelsPerFrame = 2;
    _stereoStreamFormat864.mBitsPerChannel = (UInt32)(8 * bytesPerSample);
    _stereoStreamFormat864.mSampleRate = self.sampleRate;
}

- (void)connect:(NSInteger)srcId output:(UInt32)outputId to:(NSInteger)dstId input:(UInt32)inputId {
    MKRAudioUnit *source = [self.units objectForKey:@(srcId)];
    MKRAudioUnit *destination = [self.units objectForKey:@(dstId)];
    if (!source || !destination) {
        [NSException raise:NSInternalInconsistencyException format:@"source or desctination not found!"];
    }
    OSSTATUS = AUGraphConnectNodeInput(self.graph, source.node, outputId, destination.node, inputId); OSSTATUS_CHECK
}

- (void)initializeGraph {
    [self setupStereoStream864];
    OSSTATUS = NewAUGraph(&_graph); OSSTATUS_CHECK
    _units = @{
               @(kMKRUnit_OriginalPlayer): [[MKRAUAudioFilePlayer alloc] initWithIdentifier:kMKRUnit_OriginalPlayer],
               @(kMKRUnit_PlaybackPlayer): [[MKRAUAudioFilePlayer alloc] initWithIdentifier:kMKRUnit_PlaybackPlayer],
               @(kMKRUnit_Mixer): [[MKRAUMixer alloc] initWithIdentifier:kMKRUnit_Mixer],
               @(kMKRUnit_GIO): [[MKRAUGenericOutput alloc] initWithIdentifier:kMKRUnit_GIO],
               @(kMKRUnit_TimePitch): [[MKRAUTimePitch alloc] initWithIdentifier:kMKRUnit_TimePitch]
               };
    
    [self.units enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, MKRAudioUnit * _Nonnull obj, BOOL * _Nonnull stop) {
        OSSTATUS = [obj addToGraph:self.graph]; OSSTATUS_CHECK
    }];
    
    OSSTATUS = AUGraphOpen(self.graph); OSSTATUS_CHECK
    
    [self.units enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, MKRAudioUnit * _Nonnull obj, BOOL * _Nonnull stop) {
        OSSTATUS = [obj graphNodeInfo:self.graph]; OSSTATUS_CHECK
    }];
    
    [self connect:kMKRUnit_OriginalPlayer output:0 to:kMKRUnit_TimePitch input:0];
    [self connect:kMKRUnit_TimePitch output:0 to:kMKRUnit_Mixer input:0];
    [self connect:kMKRUnit_PlaybackPlayer output:0 to:kMKRUnit_Mixer input:1];
    [self connect:kMKRUnit_Mixer output:0 to:kMKRUnit_GIO input:0];
    
    MKRAUMixer *mixer = (MKRAUMixer *)[self.units objectForKey:@(kMKRUnit_Mixer)];
    
    OSSTATUS = [mixer setInputElementCount:2]; OSSTATUS_CHECK
    OSSTATUS = [mixer setInputMeteringMode:1]; OSSTATUS_CHECK
    OSSTATUS = [mixer setGlobalMaximumFramesPerSlice:4096]; OSSTATUS_CHECK
    OSSTATUS = [mixer setOutputStreamFormat:_stereoStreamFormat864]; OSSTATUS_CHECK
    
    OSSTATUS = AUGraphInitialize(self.graph); OSSTATUS_CHECK
    
    MKRAUAudioFilePlayer *originalPlayer = (MKRAUAudioFilePlayer *)[self.units objectForKey:@(kMKRUnit_OriginalPlayer)];
    [originalPlayer setupWithFilePath:self.originalPath];
    
    MKRAUAudioFilePlayer *playbackPlayer = (MKRAUAudioFilePlayer *)[self.units objectForKey:@(kMKRUnit_PlaybackPlayer)];
    [playbackPlayer setupWithFilePath:self.playbackPath];
    
    self.maxSampleTime = MAX(originalPlayer.sampleTime, playbackPlayer.sampleTime);
}

- (void)processTrack:(MKRTrack *)track andPlaybackFilePath:(NSString *)playbackPath withOriginalFilePath:(NSString *)originalPath completion:(void (^)(NSURL *))completionBlock failure:(void (^)(NSError *))failureBlock {
    AudioStreamBasicDescription dstFormat;
    memset(&dstFormat, 0, sizeof(dstFormat));
    dstFormat.mChannelsPerFrame = 2;
    dstFormat.mFormatID = kAudioFormatMPEG4AAC;
    UInt32 size = sizeof(dstFormat);
    OSSTATUS = AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &size, &dstFormat); OSSTATUS_CHECK
    
    NSString *dstFilePath = [MKRExportProcessor generateFilePathWithFormat:@"m4a"].path;
    CFURLRef dstURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)dstFilePath, kCFURLPOSIXPathStyle, false);
    ExtAudioFileRef extAudioFile;
    
    OSSTATUS = ExtAudioFileCreateWithURL(dstURL, kAudioFileM4AType, &dstFormat, NULL, kAudioFileFlags_EraseFile, &extAudioFile); OSSTATUS_CHECK
    CFRelease(dstURL);
    
    MKRAUGenericOutput *GIO = (MKRAUGenericOutput *)[self.units objectForKey:@(kMKRUnit_GIO)];
    
    AudioStreamBasicDescription clientFormat;
    UInt32 fsize = sizeof(clientFormat);
    memset(&clientFormat, 0, sizeof(clientFormat));
    OSSTATUS = [GIO getProperty:kAudioUnitProperty_StreamFormat inScope:kAudioUnitScope_Output to:&clientFormat withSize:&fsize]; OSSTATUS_CHECK
    OSSTATUS = ExtAudioFileSetProperty(extAudioFile, kExtAudioFileProperty_ClientDataFormat, sizeof(clientFormat), &clientFormat); OSSTATUS_CHECK
    
    UInt32 codec = kAppleHardwareAudioCodecManufacturer;
    OSSTATUS = ExtAudioFileSetProperty(extAudioFile, kExtAudioFileProperty_CodecManufacturer, sizeof(codec), &codec); OSSTATUS_CHECK
    OSSTATUS = ExtAudioFileWriteAsync(extAudioFile, 0, NULL); OSSTATUS_CHECK
    
    AudioUnitRenderActionFlags flags = 0;
    AudioTimeStamp inTimeStamp;
    memset(&inTimeStamp, 0, sizeof(inTimeStamp));
    inTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    UInt32 busNumber = 0;
    UInt32 numberFrames = 512;
    CMTime timeInIteration = CMTimeMakeWithSeconds(numberFrames / self.sampleRate, 600000);
    inTimeStamp.mSampleTime = 0;
    int channelCount = 2;
    
    int totalFrames = self.maxSampleTime;
    NSLog(@"totalframes = %d aprox time = %f", totalFrames, totalFrames / self.sampleRate);

    CMTime currentTime = kCMTimeInvalid;
    while (totalFrames > 0) {
        currentTime = CMTimeMakeWithSeconds((self.maxSampleTime - totalFrames) / self.sampleRate, 600000);
        for (MKRAutomationLane *lane in track.automations) {
            MKRAutomationPoint *previousPoint = [lane getPointBefore:currentTime];
            MKRAutomationPoint *nextPoint = [lane getPointAfterOrAt:currentTime];
            if (!nextPoint && !previousPoint) {
                continue;
            }
            
            if (!previousPoint) {
                CMTime delta = CMTimeSubtract(nextPoint.position, currentTime);
                if (CMTimeGetSeconds(delta) <= CMTimeGetSeconds(timeInIteration)) {
                    MKRAudioUnit *unit = [self.units objectForKey:@(lane.audioUnitIdentifier)];
                    OSSTATUS = [unit setParameter:lane.parameterID to:[nextPoint.value floatValue]]; OSSTATUS_CHECK
                }
                continue;
            }
            if (!nextPoint) {
                MKRAudioUnit *unit = [self.units objectForKey:@(lane.audioUnitIdentifier)];
                OSSTATUS = [unit setParameter:lane.parameterID to:[previousPoint.value floatValue]]; OSSTATUS_CHECK
                continue;
            }
            
            if (nextPoint && previousPoint) {
                NSNumber *previousValue = previousPoint.value;
                NSNumber *nextValue = nextPoint.value;
                Float64 delta = [nextValue floatValue] - [previousValue floatValue];
                Float64 duration = CMTimeGetSeconds(CMTimeSubtract(nextPoint.position, previousPoint.position)) * 1000.0;
                Float64 offset = CMTimeGetSeconds(CMTimeSubtract(currentTime, previousPoint.position)) * 1000.0;
                Float64 value;
                if (delta != 0) {
                    value = [previousValue floatValue] + delta * (offset / duration);
                } else {
                    value = [nextValue floatValue];
                }
                MKRAudioUnit *unit = [self.units objectForKey:@(lane.audioUnitIdentifier)];
                OSSTATUS = [unit setParameter:lane.parameterID to:value]; OSSTATUS_CHECK
            }
        }
        
        if (totalFrames < numberFrames) {
            numberFrames = totalFrames;
        } else {
            totalFrames -= numberFrames;
        }
        AudioBufferList *bufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList) + sizeof(AudioBuffer) * (channelCount - 1));
        bufferList->mNumberBuffers = channelCount;
        for (int j = 0; j < channelCount; j++) {
            AudioBuffer buffer = {0};
            buffer.mNumberChannels = 1;
            buffer.mDataByteSize = numberFrames * sizeof(AudioUnitSampleType);
            buffer.mData = calloc(numberFrames, sizeof(AudioUnitSampleType));
            
            bufferList->mBuffers[j] = buffer;
        }
        
        OSSTATUS = AudioUnitRender(GIO.unit, &flags, &inTimeStamp, busNumber, numberFrames, bufferList); OSSTATUS_CHECK
        inTimeStamp.mSampleTime += numberFrames;
//        lastTime = currentMs;
        
        OSSTATUS = ExtAudioFileWrite(extAudioFile, numberFrames, bufferList); OSSTATUS_CHECK
    }
    
    OSSTATUS = ExtAudioFileDispose(extAudioFile); OSSTATUS_CHECK
    
    completionBlock([NSURL fileURLWithPath:dstFilePath]);
}

@end