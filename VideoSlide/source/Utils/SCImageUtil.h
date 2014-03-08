//
//  SCImageUtil.h
//  SlideshowCreator
//
//  Created 9/8/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCImageUtil : NSObject

+ (UIImage*) imageWithColor:(UIColor*)color size:(CGSize)size;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

+ (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize;

+ (UIImage *)newImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

+ (UIImage *)thumbnailWithImage:(UIImage *)image withSize:(CGSize)size;

+ (UIImage*)reduceImage:(UIImage*)image minEdge:(float)minEdge;

+ (UIImage*)imageTextWithSlideComposition:(SCSlideComposition*)slideComposition previewSize:(CGSize)size;

+ (UIImage *)makeRoundedImage:(UIImage *) image radius: (float) radius;

+ (UIImage*)filterImage:(UIImage*)image mode:(SCImageFilterMode)mode;

+ (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)aperture withOrientation:(UIImageOrientation)orientation;

+ (UIImage*)cropImageWith:(UIImage*)imageToCrop  rect:(CGRect)rect;

+ (UIImage*)rotateImage:(UIImage*)image withAngle:(float)angle;

+ (UIImage*)imageWithCenterCrop:(UIImage*)scrImage  size:(CGSize)size;

+ (UIImage *)getSubImageFrom:(UIImage*)image rect:(CGRect)rect;

+ (void)cropImageFromURLAsset:(NSURL*)assetURL  size:(CGSize)size completionBlock:(void (^)(UIImage *result))completionBlock  completionBlock:(void (^)(void))failureBlock;

+ (void)getImageFromURLAsset:(NSURL*)assetURL  completionBlock:(void (^)(UIImage *result))completionBlock  completionBlock:(void (^)(void))failureBlock;



@end
