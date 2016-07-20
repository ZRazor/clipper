//
//  APLCustomVideoCompositor.m
//  clipper
//
//  Created by Mikhail Zinov on 13.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRCustomVideoCompositor.h"
#import "MKRRenderer.h"
#import "MKRCustomVideoCompositionInstruction.h"

#import <CoreVideo/CoreVideo.h>

@interface MKRCustomVideoCompositor()
{
    BOOL								_shouldCancelAllRequests;
    BOOL								_renderContextDidChange;
    dispatch_queue_t					_renderingQueue;
    dispatch_queue_t					_renderContextQueue;
    AVVideoCompositionRenderContext*	_renderContext;
    CVPixelBufferRef					_previousBuffer;
    CIFilter*                           _filter;
    CIContext *_context;
    
    double count;
}

@property (nonatomic, strong) MKROpenGLRenderer *oglRenderer;

@end


@implementation MKRCustomVideoCompositor

#pragma mark - AVVideoCompositing protocol

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _renderingQueue = dispatch_queue_create("com.apple.aplcustomvideocompositor.renderingqueue", DISPATCH_QUEUE_SERIAL);
        _renderContextQueue = dispatch_queue_create("com.apple.aplcustomvideocompositor.rendercontextqueue", DISPATCH_QUEUE_SERIAL);
        _previousBuffer = nil;
        _renderContextDidChange = NO;
        self.oglRenderer = [[MKRRenderer alloc] init];

//        _filter = [CIFilter filterWithName:@"CIColorMonochrome"];
//        [_filter setValue:@0.8f forKey:kCIInputIntensityKey];
        
        
//        _filter = [CIFilter filterWithName:@"CITriangleKaleidoscope"];
        
        
        _context = [CIContext contextWithOptions:nil];
        
        count = 1.0;

    }
    return self;
}

- (NSDictionary *)sourcePixelBufferAttributes
{
    return @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange],
              (NSString*)kCVPixelBufferOpenGLESCompatibilityKey : [NSNumber numberWithBool:YES]};
}

- (NSDictionary *)requiredPixelBufferAttributesForRenderContext
{
    return @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange],
              (NSString*)kCVPixelBufferOpenGLESCompatibilityKey : [NSNumber numberWithBool:YES]};
}

- (void)renderContextChanged:(AVVideoCompositionRenderContext *)newRenderContext
{
    dispatch_sync(_renderContextQueue, ^() {
        _renderContext = newRenderContext;
        _renderContextDidChange = YES;
    });
}

- (void)startVideoCompositionRequest:(AVAsynchronousVideoCompositionRequest *)request
{
    //	@autoreleasepool {
    //		dispatch_async(_renderingQueue,^() {
    
    // Check if all pending requests have been cancelled
    if (_shouldCancelAllRequests) {
        [request finishCancelledRequest];
    } else {
        NSError *err = nil;
        // Get the next rendererd pixel buffer
        CVPixelBufferRef resultPixels = [self newRenderedPixelBufferForRequest:request error:&err];
        
        if (resultPixels) {
            // The resulting pixelbuffer from OpenGL renderer is passed along to the request
            [request finishWithComposedVideoFrame:resultPixels];
            CFRelease(resultPixels);
        } else {
            [request finishWithError:err];
        }
        //			}
        //		});
    }
}

- (void)cancelAllPendingVideoCompositionRequests
{
    // pending requests will call finishCancelledRequest, those already rendering will call finishWithComposedVideoFrame
    _shouldCancelAllRequests = YES;
    
    dispatch_barrier_async(_renderingQueue, ^() {
        // start accepting requests again
        _shouldCancelAllRequests = NO;
    });
}

#pragma mark - Utilities

static Float64 factorForTimeInRange(CMTime time, CMTimeRange range) /* 0.0 -> 1.0 */
{
    CMTime elapsed = CMTimeSubtract(time, range.start);
    return CMTimeGetSeconds(elapsed) / CMTimeGetSeconds(range.duration);
}

- (CVPixelBufferRef)newRenderedPixelBufferForRequest:(AVAsynchronousVideoCompositionRequest *)request error:(NSError **)errOut
{
    CVPixelBufferRef dstPixels = nil;
    
    // tweenFactor indicates how far within that timeRange are we rendering this frame. This is normalized to vary between 0.0 and 1.0.
    // 0.0 indicates the time at first frame in that videoComposition timeRange
    // 1.0 indicates the time at last frame in that videoComposition timeRange
//    float tweenFactor = factorForTimeInRange(request.compositionTime, request.videoCompositionInstruction.timeRange);
//    
//    MKRCustomVideoCompositionInstruction *currentInstruction = request.videoCompositionInstruction;
    
//     Source pixel buffers are used as inputs while rendering the transition
    CVPixelBufferRef foregroundSourceBuffer = [request sourceFrameByTrackID:1];
    
    // Destination pixel buffer into which we render the output
    dstPixels = [_renderContext newPixelBuffer];
//
//    // Recompute normalized render transform everytime the render context changes
    if (_renderContextDidChange) {
//        // The renderTransform returned by the renderContext is in X: [0, w] and Y: [0, h] coordinate system
//        // But since in this sample we render using OpenGLES which has its coordinate system between [-1, 1] we compute a normalized transform
        CGSize renderSize = _renderContext.size;
        CGSize destinationSize = CGSizeMake(CVPixelBufferGetWidth(dstPixels), CVPixelBufferGetHeight(dstPixels));
        CGAffineTransform renderContextTransform = {renderSize.width/2, 0, 0, renderSize.height/2, renderSize.width/2, renderSize.height/2};
        CGAffineTransform destinationTransform = {2/destinationSize.width, 0, 0, 2/destinationSize.height, -1, -1};
        CGAffineTransform normalizedRenderTransform = CGAffineTransformConcat(CGAffineTransformConcat(renderContextTransform, _renderContext.renderTransform), destinationTransform);
        _oglRenderer.renderTransform = normalizedRenderTransform;
//
        _renderContextDidChange = NO;
    }
    
    [_oglRenderer renderPixelBuffer:dstPixels usingSourceBuffer:foregroundSourceBuffer];
    
    double currentMs = CMTimeGetSeconds(request.compositionTime) * 1000.0;
    
    [self.filtersManager applyFiltersToBuffer:dstPixels atMs:currentMs];
    
    
//    CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:dstPixels options:nil];
//    [_filter setValue:sourceImage forKey:kCIInputImageKey];
//    [_context render:[_filter outputImage] toCVPixelBuffer:dstPixels];
//    
//    [_filter setValue:@(count) forKey:kCIInputWidthKey];
//    
//    count+=6;
//    count = MIN(700, count);
    
    
    return dstPixels;
}


@end