//
//  MKROpenGLRenderer.h
//  clipper
//
//  Created by Mikhail Zinov on 18.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>


enum
{
    UNIFORM_Y,
    UNIFORM_UV,
    UNIFORM_RENDER_TRANSFORM_Y,
    UNIFORM_RENDER_TRANSFORM_UV,
   	NUM_UNIFORMS
};


enum
{
    ATTRIB_VERTEX_Y,
    ATTRIB_TEXCOORD_Y,
    ATTRIB_VERTEX_UV,
    ATTRIB_TEXCOORD_UV,
   	NUM_ATTRIBUTES
};

@interface MKROpenGLRenderer : NSObject {
    GLint uniforms[NUM_UNIFORMS];
}

@property GLuint programY;
@property GLuint programUV;
@property CGAffineTransform renderTransform;
@property CVOpenGLESTextureCacheRef videoTextureCache;
@property EAGLContext *currentContext;
@property GLuint offscreenBufferHandle;

@property GLuint frame;

- (CVOpenGLESTextureRef)lumaTextureForPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (CVOpenGLESTextureRef)chromaTextureForPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)renderPixelBuffer:(CVPixelBufferRef)destinationPixelBuffer usingForegroundSourceBuffer:(CVPixelBufferRef)foregroundPixelBuffer andBackgroundSourceBuffer:(CVPixelBufferRef)backgroundPixelBuffer forTweenFactor:(float)tween;
- (void)renderPixelBuffer:(CVPixelBufferRef)destinationPixelBuffer usingSourceBuffer:(CVPixelBufferRef)pixelBuffer;
@end
