//
//  MKRVad.m
//  MKR
//
//  Created by Aric Lasry on 8/6/14.
//  Copyright (c) 2014 Willy Blandin. All rights reserved.
//

#import "MKRVad.h"

static int const kMKRAudioSampleRate = 16000;
static int const kMKRAudioBitDepth = 16;

@implementation MKRVad {
    s_wv_detector_cvad_state *vad_state;
    FFTSetup fft_setup;
    double msDuration;
    NSData *samplesData;

    /**
     * Set VAD sensitivity (0-100):
     * - Lower values are for strong voice signals like for a cellphone or personal mic.
     * - Higher values are for use with a fixed-position mic or any application with voice buried in ambient noise.
     * - Defaults to 0
     */
    int vadSensitivity;
    /**
     * Set the maximum length of time recorded by the VAD in ms
     * Set to -1 for no timeout
     * Defaults to 7000
     */
    int vadTimeout;
}

- (void)setVadTimeout:(int)newTimeout {
    vadTimeout = newTimeout;
    [self reInitVadState];
}

- (void)setVadSensitivity:(int)newSensitivity {
    vadSensitivity = newSensitivity;
    [self reInitVadState];
}

- (void)reInitVadState {
    if (self->vad_state) {
        wv_detector_cvad_clean(self->vad_state);
    }
    self->vad_state = wv_detector_cvad_init(kMKRAudioSampleRate, vadSensitivity, vadTimeout);
}

- (instancetype)initWithAudioSamples:(NSData *)aSamples andAudioMsDuration:(NSInteger)aMsDuration {
    self = [super init];
    if (!self) {
        return nil;
    }
    vadSensitivity = 99; //default value
    vadTimeout = 3000; //default value
    samplesData = aSamples;
    msDuration = aMsDuration;

    self->vad_state = wv_detector_cvad_init(kMKRAudioSampleRate, vadSensitivity, vadTimeout);
    //!!! if we want to change Sample Rate - We need to re calc FFT!
    //get the next power of 2 that'll fit our data
    int logN = log2(self->vad_state->samples_per_frame);  //samples_per_frame will be a power of 2
    //store the FFT setup for many later uses
    self->fft_setup = vDSP_create_fftsetup(logN, kFFTRadix2);

    return self;
}

- (void)dealloc {
    wv_detector_cvad_clean(self->vad_state);
}

- (NSMutableArray<MKRInterval *> *)findSpeechIntervals {
    UInt32 size = (UInt32)[samplesData length] / sizeof(short);
    short *bytes = (short*)[samplesData bytes];
    NSMutableArray<MKRInterval *> *intervals = [NSMutableArray new];
    double speechStartsAtMs = -1;
    double speechEndsAtMs = -1;
    double msInSample = (msDuration) / size;

    for (int sampleOffset = 0; sampleOffset + self->vad_state->samples_per_frame < size; sampleOffset += self->vad_state->samples_per_frame) {
        int nonZero = 0;

        //check to make sure buffer actually has audio data
        for(int i = 0; i < self->vad_state->samples_per_frame; i++) {
            if (bytes[sampleOffset + i] != 0) {
                nonZero = 1;
                break;
            }
        }

        //skip frame if it has nothing
        if(!nonZero) {
            continue;
        }

        float *fft_mags = [self get_fft:(bytes + sampleOffset)];
        int detected_speech = wvs_cvad_detect_talking(self->vad_state, bytes + sampleOffset, fft_mags);
        free(fft_mags);

        if (detected_speech == 1) {
            if (speechStartsAtMs == -1) {
                speechStartsAtMs = sampleOffset * msInSample;
            } else {
                NSLog(@"Some problem found: double detect_speech == 1!");
            }
        } else if (detected_speech == 0) {
            if (speechStartsAtMs != -1) {
                speechEndsAtMs = sampleOffset * msInSample;
                int startSample = (int)(speechStartsAtMs / msInSample);
                short maxValue = abs(bytes[startSample]);
                int maxValueSampleNum = startSample;
                
                int j = startSample;
                int windowSize = MIN(1000, sampleOffset - startSample);
                for (j = 0; j < windowSize; j++) {
                    short value = abs(bytes[j + startSample]);
                    if (value > maxValue) {
                        maxValue = value;
                        maxValueSampleNum = j + startSample;
                    }
                }
                
                speechStartsAtMs = maxValueSampleNum * msInSample;
                MKRInterval *foundInterval = [[MKRInterval alloc] initWithStart:speechStartsAtMs andEnd:speechEndsAtMs];
                [intervals addObject:foundInterval];
                speechStartsAtMs = -1;
                speechEndsAtMs = -1;
            } else {
                NSLog(@"Some problem found: double detect_speech == 0!");
            }
        }
    }
    
    return intervals;
}

- (float*)get_fft:(short *)samples {
    int N = self->vad_state->samples_per_frame; //guarenteed to be a power of 2

    //dynamically allocate an array for our results since we don't want to mutate the input samples
    float *fft_mags = malloc(N/2 * sizeof(float));
    float *fsamples = malloc(N * sizeof(float));
    for (int i = 0; i < N; i++){
        if (i < self->vad_state->samples_per_frame) {
            fsamples[i] = samples[i];
        } else {
            fsamples[i] = 0;
        }
    }

    DSPSplitComplex tempSplitComplex;
    tempSplitComplex.realp = malloc(N/2 * sizeof(float));
    tempSplitComplex.imagp = malloc(N/2 * sizeof(float));

    //pack the real data into a split form for accelerate
    vDSP_ctoz((DSPComplex*)fsamples, 2, &tempSplitComplex, 1, N/2);

    //do the FFT
    vDSP_fft_zrip(self->fft_setup, &tempSplitComplex, 1, (int)log2(N), kFFTDirection_Forward);

    //get the magnitudes
    vDSP_zvabs(&tempSplitComplex, 1, fft_mags, 1, N/2);

    //clear up memory
    free(fsamples);
    free(tempSplitComplex.realp);
    free(tempSplitComplex.imagp);

    return fft_mags;
}

@end
