//
//  MKRAudioProcessor.m
//  clipper
//
//  Created by dev on 14.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRAudioProcessor.h"
#import "MKRExportProcessor.h"

OSStatus OSSTATUS = noErr;
#define OSSTATUS_CHECK if (OSSTATUS != 0) [NSException raise:NSInternalInconsistencyException format:@"OSStatus error: %d", (int)OSSTATUS];

@interface MKRAudioProcessor()

@property (nonatomic) AUGraph graph;
@property (nonatomic) AudioUnit GIOUnit;
@property (nonatomic) AudioUnit mixerUnit;
@property (nonatomic) AudioUnit originalPlayerUnit;
@property (nonatomic) AudioUnit playbackPlayerUnit;
@property (nonatomic) AudioUnit timePitchUnit;

@property (nonatomic) AUNode GIONode;
@property (nonatomic) AUNode mixerNode;
@property (nonatomic) AUNode originalPlayerNode;
@property (nonatomic) AUNode playbackPlayerNode;
@property (nonatomic) AUNode timePitchNode;

@property (nonatomic) Float64 sampleRate;
@property (nonatomic) SInt32 framesPerSlice;
@property (nonatomic) AudioStreamBasicDescription stereoStreamFormat864;
@property (nonatomic) Float64 maxSampleTime;

@property (nonatomic) NSString *originalPath;
@property (nonatomic) NSString *playbackPath;
@property (nonatomic) AudioFileID originalFile;
@property (nonatomic) AudioFileID playbackFile;
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

- (void)initializeGraph {
    [self setupStereoStream864];
    OSSTATUS = NewAUGraph(&_graph); OSSTATUS_CHECK
    
    AudioComponentDescription originalPlayerDesc;
    originalPlayerDesc.componentType = kAudioUnitType_Generator;
    originalPlayerDesc.componentSubType = kAudioUnitSubType_AudioFilePlayer;
    originalPlayerDesc.componentFlags = 0;
    originalPlayerDesc.componentFlagsMask = 0;
    originalPlayerDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    AudioComponentDescription playbackPlayerDesc;
    playbackPlayerDesc.componentType = kAudioUnitType_Generator;
    playbackPlayerDesc.componentSubType = kAudioUnitSubType_AudioFilePlayer;
    playbackPlayerDesc.componentFlags = 0;
    playbackPlayerDesc.componentFlagsMask = 0;
    playbackPlayerDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    AudioComponentDescription mixerDesc;
    mixerDesc.componentType = kAudioUnitType_Mixer;
    mixerDesc.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    mixerDesc.componentFlags = 0;
    mixerDesc.componentFlagsMask = 0;
    mixerDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    AudioComponentDescription GIODesc;
    GIODesc.componentType = kAudioUnitType_Output;
    GIODesc.componentSubType = kAudioUnitSubType_GenericOutput;
    GIODesc.componentFlags = 0;
    GIODesc.componentFlagsMask = 0;
    GIODesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    AudioComponentDescription timePitchDesc;
    timePitchDesc.componentType = kAudioUnitType_FormatConverter;
    timePitchDesc.componentSubType = kAudioUnitSubType_NewTimePitch;
    timePitchDesc.componentFlags = 0;
    timePitchDesc.componentFlagsMask = 0;
    timePitchDesc.componentManufacturer = kAudioUnitManufacturer_Apple;

    OSSTATUS = AUGraphAddNode(self.graph, &originalPlayerDesc, &_originalPlayerNode); OSSTATUS_CHECK
    OSSTATUS = AUGraphAddNode(self.graph, &playbackPlayerDesc, &_playbackPlayerNode); OSSTATUS_CHECK
    OSSTATUS = AUGraphAddNode(self.graph, &mixerDesc, &_mixerNode); OSSTATUS_CHECK
    OSSTATUS = AUGraphAddNode(self.graph, &GIODesc, &_GIONode); OSSTATUS_CHECK
    OSSTATUS = AUGraphAddNode(self.graph, &timePitchDesc, &_timePitchNode); OSSTATUS_CHECK
    
    OSSTATUS = AUGraphOpen(self.graph); OSSTATUS_CHECK
    
    OSSTATUS = AUGraphNodeInfo(self.graph, self.originalPlayerNode, NULL, &_originalPlayerUnit); OSSTATUS_CHECK
    OSSTATUS = AUGraphNodeInfo(self.graph, self.playbackPlayerNode, NULL, &_playbackPlayerUnit); OSSTATUS_CHECK
    OSSTATUS = AUGraphNodeInfo(self.graph, self.mixerNode, NULL, &_mixerUnit); OSSTATUS_CHECK
    OSSTATUS = AUGraphNodeInfo(self.graph, self.GIONode, NULL, &_GIOUnit); OSSTATUS_CHECK
    OSSTATUS = AUGraphNodeInfo(self.graph, self.timePitchNode, NULL, &_timePitchUnit); OSSTATUS_CHECK
    
    OSSTATUS = AUGraphConnectNodeInput(self.graph, self.originalPlayerNode, 0, self.timePitchNode, 0); OSSTATUS_CHECK
    OSSTATUS = AUGraphConnectNodeInput(self.graph, self.timePitchNode, 0, self.mixerNode, 0); OSSTATUS_CHECK
    OSSTATUS = AUGraphConnectNodeInput(self.graph, self.playbackPlayerNode, 0, self.mixerNode, 1); OSSTATUS_CHECK
    OSSTATUS = AUGraphConnectNodeInput(self.graph, self.mixerNode, 0, self.GIONode, 0); OSSTATUS_CHECK
    
    //setup mixer
    UInt32 busCount = 2;
    OSSTATUS = AudioUnitSetProperty(self.mixerUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &busCount, sizeof(busCount)); OSSTATUS_CHECK
    
    UInt32 onValue = 1;
    OSSTATUS = AudioUnitSetProperty(self.mixerUnit, kAudioUnitProperty_MeteringMode, kAudioUnitScope_Input, 0, &onValue, sizeof(onValue)); OSSTATUS_CHECK
    
    UInt32 maximumFramesPerSlice = 4096;
    OSSTATUS = AudioUnitSetProperty(self.mixerUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maximumFramesPerSlice, sizeof(maximumFramesPerSlice)); OSSTATUS_CHECK
    
    OSSTATUS = AudioUnitSetProperty(self.mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &_stereoStreamFormat864, sizeof(_stereoStreamFormat864)); OSSTATUS_CHECK
    
    OSSTATUS = AUGraphInitialize(self.graph); OSSTATUS_CHECK
    
    [self setupOriginalPlayer];
    [self setupPlaybackPlayer];
}

- (void)setupOriginalPlayer {
    CFURLRef originalURL = (__bridge CFURLRef)[NSURL fileURLWithPath:self.originalPath];
    OSSTATUS = AudioFileOpenURL(originalURL, kAudioFileReadPermission, 0, &_originalFile); OSSTATUS_CHECK
    
    AudioStreamBasicDescription originalASBD;
    UInt32 propSize = sizeof(originalASBD);
    OSSTATUS = AudioFileGetProperty(self.originalFile, kAudioFilePropertyDataFormat, &propSize, &originalASBD); OSSTATUS_CHECK
    
    OSSTATUS = AudioUnitSetProperty(self.originalPlayerUnit, kAudioUnitProperty_ScheduledFileIDs, kAudioUnitScope_Global, 0, &_originalFile, sizeof(self.originalFile)); OSSTATUS_CHECK
    
    UInt64 nPackets;
    propSize = sizeof(nPackets);
    OSSTATUS = AudioFileGetProperty(self.originalFile, kAudioFilePropertyAudioDataPacketCount, &propSize, &nPackets); OSSTATUS_CHECK
    
    ScheduledAudioFileRegion rgn;
    memset(&rgn.mTimeStamp, 0, sizeof(rgn.mTimeStamp));
    rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    rgn.mTimeStamp.mSampleTime = 0;
    rgn.mCompletionProc = NULL;
    rgn.mCompletionProcUserData = NULL;
    rgn.mAudioFile = self.originalFile;
    rgn.mLoopCount = 0;
    rgn.mStartFrame = 0;
    rgn.mFramesToPlay = (UInt32)nPackets * originalASBD.mFramesPerPacket;
    
    if (self.maxSampleTime < rgn.mFramesToPlay) {
        self.maxSampleTime = rgn.mFramesToPlay;
    }
    
    OSSTATUS = AudioUnitSetProperty(self.originalPlayerUnit, kAudioUnitProperty_ScheduledFileRegion, kAudioUnitScope_Global, 0, &rgn, sizeof(rgn)); OSSTATUS_CHECK
    
    UInt32 defaultVal = 0;
    OSSTATUS = AudioUnitSetProperty(self.originalPlayerUnit, kAudioUnitProperty_ScheduledFilePrime, kAudioUnitScope_Global, 0, &defaultVal, sizeof(defaultVal));
    
    AudioTimeStamp startTime;
    memset(&startTime, 0, sizeof(startTime));
    startTime.mFlags = kAudioTimeStampSampleTimeValid;
    startTime.mSampleTime = 0;
    OSSTATUS = AudioUnitSetProperty(self.originalPlayerUnit, kAudioUnitProperty_ScheduleStartTimeStamp, kAudioUnitScope_Global, 0, &startTime, sizeof(startTime)); OSSTATUS_CHECK
}

- (void)setupPlaybackPlayer {
    CFURLRef playbackURL = (__bridge CFURLRef)[NSURL fileURLWithPath:self.playbackPath];
    OSSTATUS = AudioFileOpenURL(playbackURL, kAudioFileReadPermission, 0, &_playbackFile); OSSTATUS_CHECK
    
    AudioStreamBasicDescription playbackASBD;
    UInt32 propSize = sizeof(playbackASBD);
    OSSTATUS = AudioFileGetProperty(self.playbackFile, kAudioFilePropertyDataFormat, &propSize, &playbackASBD); OSSTATUS_CHECK
    
    OSSTATUS = AudioUnitSetProperty(self.playbackPlayerUnit, kAudioUnitProperty_ScheduledFileIDs, kAudioUnitScope_Global, 0, &_playbackFile, sizeof(self.playbackFile)); OSSTATUS_CHECK
    
    UInt64 nPackets;
    propSize = sizeof(nPackets);
    OSSTATUS = AudioFileGetProperty(self.playbackFile, kAudioFilePropertyAudioDataPacketCount, &propSize, &nPackets); OSSTATUS_CHECK
    
    ScheduledAudioFileRegion rgn;
    memset(&rgn.mTimeStamp, 0, sizeof(rgn.mTimeStamp));
    rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    rgn.mTimeStamp.mSampleTime = 0;
    rgn.mCompletionProc = NULL;
    rgn.mCompletionProcUserData = NULL;
    rgn.mAudioFile = self.playbackFile;
    rgn.mLoopCount = 0;
    rgn.mStartFrame = 0;
    rgn.mFramesToPlay = (UInt32)nPackets * playbackASBD.mFramesPerPacket;
    
    if (self.maxSampleTime < rgn.mFramesToPlay) {
        self.maxSampleTime = rgn.mFramesToPlay;
    }
    
    OSSTATUS = AudioUnitSetProperty(self.playbackPlayerUnit, kAudioUnitProperty_ScheduledFileRegion, kAudioUnitScope_Global, 0, &rgn, sizeof(rgn)); OSSTATUS_CHECK
    
    UInt32 defaultVal = 0;
    OSSTATUS = AudioUnitSetProperty(self.playbackPlayerUnit, kAudioUnitProperty_ScheduledFilePrime, kAudioUnitScope_Global, 0, &defaultVal, sizeof(defaultVal));
    
    AudioTimeStamp startTime;
    memset(&startTime, 0, sizeof(startTime));
    startTime.mFlags = kAudioTimeStampSampleTimeValid;
    startTime.mSampleTime = 0;
    OSSTATUS = AudioUnitSetProperty(self.playbackPlayerUnit, kAudioUnitProperty_ScheduleStartTimeStamp, kAudioUnitScope_Global, 0, &startTime, sizeof(startTime)); OSSTATUS_CHECK
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
    
    AudioStreamBasicDescription clientFormat;
    UInt32 fsize = sizeof(clientFormat);
    memset(&clientFormat, 0, sizeof(clientFormat));
    OSSTATUS = AudioUnitGetProperty(self.GIOUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &clientFormat, &fsize); OSSTATUS_CHECK
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
    inTimeStamp.mSampleTime = 0;
    int channelCount = 2;
    
    int totalFrames = self.maxSampleTime;
    while (totalFrames > 0) {
        
//        if (totalFrames / numberFrames > 26880 / 1000 * self.sampleRate && totalFrames / numberFrames < 38400 / 1000 * self.sampleRate) {
//            OSSTATUS = AudioUnitSetParameter(self.timePitchUnit, kNewTimePitchParam_Pitch, kAudioUnitScope_Global, 0, (i += 10) % 2400, 0); OSSTATUS_CHECK
//        } else if (totalFrames / numberFrames > 38400 / 1000 * self.sampleRate) {
//            OSSTATUS = AudioUnitSetParameter(self.timePitchUnit, kNewTimePitchParam_Pitch, kAudioUnitScope_Global, 0, 0, 0); OSSTATUS_CHECK
//        }
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
        
        OSSTATUS = AudioUnitRender(self.GIOUnit, &flags, &inTimeStamp, busNumber, numberFrames, bufferList); OSSTATUS_CHECK
        inTimeStamp.mSampleTime++;
        
        OSSTATUS = ExtAudioFileWrite(extAudioFile, numberFrames, bufferList); OSSTATUS_CHECK
    }
    
    OSSTATUS = ExtAudioFileDispose(extAudioFile); OSSTATUS_CHECK
    
    completionBlock([NSURL fileURLWithPath:dstFilePath]);
}

@end