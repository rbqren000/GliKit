//
//  GKPhotosOptions.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/1.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKPhotosOptions.h"
#import <ImageIO/ImageIO.h>
#import "UIImage+Utils.h"

@implementation GKPhotosPickResult

+ (instancetype)resultWithData:(NSData*) data options:(GKPhotosOptions*) options
{
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, (__bridge CFDictionaryRef)@{(NSString*) kCGImageSourceShouldAllowFloat : @YES});
    if(!source)
        return nil;
    
    CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
    if(!properties)
        return nil;
    
    NSNumber *width = CFDictionaryGetValue(properties, kCGImagePropertyPixelWidth);
    NSNumber *height = CFDictionaryGetValue(properties, kCGImagePropertyPixelHeight);
    CGSize imageSize = CGSizeMake(width.doubleValue, height.doubleValue);
    
    CGFloat scale = options.scale;
    
    GKPhotosPickResult *result = [GKPhotosPickResult new];
    if(options.needOriginalImage){
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
        if(imageRef != NULL){
            result.originalImage = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
            CGImageRelease(imageRef);
        }
    }
    
    if(!CGSizeEqualToSize(CGSizeZero, options.compressedImageSize)){
        
        CGSize size = options.compressedImageSize;
        size.width *= scale;
        size.height *= scale;
        
        size = [UIImage gk_fitImageSize:imageSize size:size type:GKImageFitTypeWidth];
        
        NSDictionary *compressedImageOptions = @{(id)kCGImageSourceThumbnailMaxPixelSize : @(MAX(size.width, size.height)),
                                    (id)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                    (id)kCGImageSourceCreateThumbnailWithTransform : @YES};
        
        CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)compressedImageOptions);
        if(imageRef != NULL){
            result.compressedImage = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
            CGImageRelease(imageRef);
        }
    }
    
    if(!CGSizeEqualToSize(CGSizeZero, options.thumbnailSize)){
        
        CGSize size = options.thumbnailSize;
        size.width *= scale;
        size.height *= scale;
        
        size = [UIImage gk_fitImageSize:imageSize size:size type:GKImageFitTypeWidth];
        NSDictionary *thumbnailOptions = @{(id)kCGImageSourceThumbnailMaxPixelSize : @(MAX(size.width, size.height)),
                              (id)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                              (id)kCGImageSourceCreateThumbnailWithTransform : @YES};
        
        CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)thumbnailOptions);
        if(imageRef != NULL){
            result.thumbnail = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
            CGImageRelease(imageRef);
        }
    }
    
    CFRelease(source);
    CFRelease(properties);
    
    return result;
}

@end

@implementation GKPhotosOptions

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maxCount = 1;
        self.gridInterval = 3;
        self.numberOfItemsPerRow = 4;
        self.shouldDisplayAllPhotos = YES;
        self.displayFistCollection = YES;
        self.compressedImageSize = CGSizeMake(512, 512);
        self.scale = GKImageScale;
    }
    return self;
}

- (void)setScale:(CGFloat)scale
{
    if(_scale != scale){
        if(scale < 1.0){
            scale = 1.0;
        }
        _scale = scale;
    }
}

@end
