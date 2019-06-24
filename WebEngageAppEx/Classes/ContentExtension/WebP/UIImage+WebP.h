//
//  UIImage+WebP.h
//  iOS-WebP

#import <UIKit/UIKit.h>
#if __has_include("webp/decode.h") && __has_include("webp/encode.h")
#import "webp/decode.h"
#import "webp/encode.h"
#elif __has_include(<libwebp/decode.h>) && __has_include(<libwebp/encode.h>)
#import <libwebp/decode.h>
#import <libwebp/encode.h>
#endif

@interface UIImage (WebP)

+ (UIImage*)imageWithWebPData:(NSData*)imgData;

+ (UIImage*)imageWithWebP:(NSString*)filePath;

+ (NSData*)imageToWebP:(UIImage*)image quality:(CGFloat)quality;

+ (void)imageToWebP:(UIImage*)image
            quality:(CGFloat)quality
              alpha:(CGFloat)alpha
             preset:(WebPPreset)preset
    completionBlock:(void (^)(NSData* result))completionBlock
       failureBlock:(void (^)(NSError* error))failureBlock;

+ (void)imageToWebP:(UIImage*)image
            quality:(CGFloat)quality
              alpha:(CGFloat)alpha
             preset:(WebPPreset)preset
        configBlock:(void (^)(WebPConfig* config))configBlock
    completionBlock:(void (^)(NSData* result))completionBlock
       failureBlock:(void (^)(NSError* error))failureBlock;

+ (void)imageWithWebP:(NSString*)filePath
      completionBlock:(void (^)(UIImage* result))completionBlock
         failureBlock:(void (^)(NSError* error))failureBlock;

- (UIImage*)imageByApplyingAlpha:(CGFloat)alpha;

@end
