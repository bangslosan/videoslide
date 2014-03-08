//
//  SCImageUtil.m
//  SlideshowCreator
//
//  Created 9/8/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCImageUtil.h"

@implementation SCImageUtil


+ (UIImage*) imageWithColor:(UIColor*)color size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    UIBezierPath* rPath = [UIBezierPath bezierPathWithRect:CGRectMake(0., 0., size.width, size.height)];
    [color setFill];
    [rPath fill];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    image = nil;
    return newImage;
}

+ (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize
{
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationMedium);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)newImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    //    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    UIGraphicsBeginImageContext(newSize);
    //[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    image = nil;
    return newImage;
}

+ (UIImage *)thumbnailWithImage:(UIImage *)image withSize:(CGSize)size {
    
    CGSize _prepareThumbSize;
    UIImage *_prepareThumbImage;
    if (image.size.width > image.size.height) {
        _prepareThumbSize = CGSizeMake(image.size.width/(image.size.height/size.height),
                                       size.height);
    } else {
        _prepareThumbSize = CGSizeMake(size.width,
                                       image.size.height/(image.size.width/size.width));
    }
    _prepareThumbImage = [_prepareThumbImage resizedImageWithMaximumSize:_prepareThumbSize];//[self newImageWithImage:image scaledToSize:_prepareThumbSize];
    
    
    float x, y;
    if (_prepareThumbImage.size.width > _prepareThumbImage.size.height) {
        x = _prepareThumbImage.size.width/2 - size.width/2;
        y = 0;
    } else {
        x = 0;
        y = _prepareThumbImage.size.height/2 - size.height/2;
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(_prepareThumbImage.CGImage,
                                                       CGRectMake(x,
                                                                  y,
                                                                  size.width,
                                                                  size.height));
    UIImage *thumbImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    image = nil;
    _prepareThumbImage = nil;
    
    return thumbImage;
}

// rectangle image, not square, before crop.
+ (UIImage*)reduceImage:(UIImage*)image minEdge:(float)minEdge {
    
    CGSize _reduceSize;
    if (image.size.width > image.size.height) {
        _reduceSize = CGSizeMake(image.size.width/(image.size.height/minEdge), minEdge);
    } else if (image.size.width < image.size.height) {
        _reduceSize = CGSizeMake(minEdge, image.size.height/(image.size.width/minEdge));
    } else if (image.size.width == image.size.height) {
        _reduceSize = CGSizeMake(minEdge, minEdge);
    }
    
    return [self newImageWithImage:image scaledToSize:_reduceSize];
}

// create text photo
+ (UIImage*)imageTextWithSlideComposition:(SCSlideComposition*)slideComposition previewSize:(CGSize)size {
    
    float exportEdge = SC_CROP_PHOTO_SIZE.width;
    float previewEdge = MIN(size.width, size.height);
    
    float scale = exportEdge / previewEdge;
    
    UIImage *plainImage;
    if (slideComposition.filterComposition.filteredImage) {
        plainImage = slideComposition.filterComposition.filteredImage;
    } else {
        plainImage = slideComposition.image;
    }
    
    // parent view
    UIView *exportView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, exportEdge, exportEdge)];
    
    
    // main image
    UIImageView *imageView = [[UIImageView alloc] initWithImage:plainImage];
    imageView.frame = exportView.bounds;
    [exportView addSubview:imageView];
    
    // text view objects
    for (int i = 0; i < slideComposition.texts.count; i++) {
        SCTextObjectView *textObjectView = [[SCTextObjectView alloc] initWithTextObjectView:(SCTextObjectView*)[slideComposition.texts objectAtIndex:i]
                                                                                   andScale:scale];
        [exportView addSubview:textObjectView];
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(exportEdge, exportEdge), NO, 0.0);
	[exportView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return image;
    
}


//create rounded image
+ (UIImage *)makeRoundedImage:(UIImage *) image
                      radius: (float) radius;
{
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    imageLayer.contents = (id) image.CGImage;
    
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = radius;
    
    UIGraphicsBeginImageContext(image.size);
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

#pragma mark - Filter
+ (UIImage*)filterImage:(UIImage*)image mode:(SCImageFilterMode)mode {
    
    switch (mode) {
        case SCImageFilterModeNormal:
            return image;
            break;
        case SCImageFilterModeOne:
            return [self filterWithName:@"02" image:image];
            break;
        case SCImageFilterModeTwo:
            return [self filterWithName:@"06" image:image];
            break;
        case SCImageFilterModeThree:
            return [self filterWithName:@"17" image:image];
            break;
        case SCImageFilterModeFour:
            return [self filterWithName:@"aqua" image:image];
            break;
        case SCImageFilterModeFive:
            return [self filterWithName:@"Country" image:image];
            break;
        case SCImageFilterModeSix:
            return [self filterWithName:@"desert" image:image];
            break;
        case SCImageFilterModeSeven:
            return [self filterWithName:@"Brannan" image:image];
            break;
        case SCImageFilterModeEight:
            return [self filterWithName:@"fogy_blue" image:image];
            break;
        case SCImageFilterModeNine:
            return [self filterWithName:@"pink" image:image];
            break;
        case SCImageFilterModeTen:
            return [self filterWithName:@"purple-green" image:image];
            break;
        case SCImageFilterModeEleven:
            return [self filterWithName:@"yellow-blue" image:image];
            break;
        case SCImageFilterModeTwelve:
            return [self filterWithName:@"yellow-blue6" image:image];
            break;
        case SCImageFilterModeThirteen:
            return [self filterWithName:@"yellow" image:image];
            break;
        case SCImageFilterModeFourteen:
            return [self filterWithName:@"creamy" image:image];
            break;
        case SCImageFilterModeFifteen:
            return [self filterWithName:@"dark_green" image:image];
            break;
        default:
            break;
    }
    return nil;
}

+ (UIImage*)filterWithName:(NSString*)filterName image:(UIImage*)image {
    
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:image];
    
    GPUImageToneCurveFilter *stillImageFilter =  [[GPUImageToneCurveFilter alloc] initWithACV:filterName];
    [stillImageSource addTarget:stillImageFilter];
    [stillImageSource processImage];
    
    UIImage *filted = [stillImageFilter imageFromCurrentlyProcessedOutput];
    return filted;
    
}

// Draw a full image into a crop-sized area and offset to produce a cropped, rotated image
+ (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)aperture withOrientation:(UIImageOrientation)orientation
{
    // convert y coordinate to origin bottom-left
    CGFloat orgY = aperture.origin.y + aperture.size.height - imageToCrop.size.height,
    orgX = -aperture.origin.x,
    scaleX = 1.0,
    scaleY = 1.0,
    rot = 0.0;
    CGSize size;
    
    switch (orientation) {
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            size = CGSizeMake(aperture.size.height, aperture.size.width);
            break;
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            size = aperture.size;
            break;
        default:
            assert(NO);
            return nil;
    }
    
    
    switch (orientation) {
        case UIImageOrientationRight:
            rot = 1.0 * M_PI / 2.0;
            orgY -= aperture.size.height;
            break;
        case UIImageOrientationRightMirrored:
            rot = 1.0 * M_PI / 2.0;
            scaleY = -1.0;
            break;
        case UIImageOrientationDown:
            scaleX = scaleY = -1.0;
            orgX -= aperture.size.width;
            orgY -= aperture.size.height;
            break;
        case UIImageOrientationDownMirrored:
            orgY -= aperture.size.height;
            scaleY = -1.0;
            break;
        case UIImageOrientationLeft:
            rot = 3.0 * M_PI / 2.0;
            orgX -= aperture.size.height;
            break;
        case UIImageOrientationLeftMirrored:
            rot = 3.0 * M_PI / 2.0;
            orgY -= aperture.size.height;
            orgX -= aperture.size.width;
            scaleY = -1.0;
            break;
        case UIImageOrientationUp:
            break;
        case UIImageOrientationUpMirrored:
            orgX -= aperture.size.width;
            scaleX = -1.0;
            break;
    }
    
    // set the draw rect to pan the image to the right spot
    CGRect drawRect = CGRectMake(orgX, orgY, imageToCrop.size.width, imageToCrop.size.height);
    
    // create a context for the new image
    UIGraphicsBeginImageContextWithOptions(size, NO, imageToCrop.scale);
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    // apply rotation and scaling
    //CGContextRotateCTM(gc, M_PI);
   // CGContextScaleCTM(gc, scaleX, scaleY);
    
    // draw the image to our clipped context using the offset rect
    CGContextDrawImage(gc, drawRect, imageToCrop.CGImage);
    
    // pull the image from our cropped context
    UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
    
    // pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    // Note: this is autoreleased
    return cropped;
}


+ (UIImage*)cropImageWith:(UIImage*)imageToCrop  rect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    CGContextClipToRect( currentContext, clippedRect);
    
    CGRect drawRect = CGRectMake(rect.origin.x * -1,
                                 rect.origin.y * -1,
                                 imageToCrop.size.width,
                                 imageToCrop.size.height);
    
    CGContextDrawImage(currentContext, drawRect, imageToCrop.CGImage);
    UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cropped = [self rotateImage:cropped withAngle:90];
    //CGContextRelease(currentContext);

    return cropped;
}

+ (UIImage*)rotateImage:(UIImage*)image withAngle:(float)angle
{
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, CGRectMake(0 , 0, image.size.width , image.size.height), [image CGImage]);
    CGContextRotateCTM (context, M_PI * angle / 180);
    
    CGImageRef cgImage = nil;
    
    cgImage = CGBitmapContextCreateImage(context);
    
    UIImage *img = [UIImage imageWithCGImage:cgImage];
    
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    //CGContextRelease(context);
    
    return img;
    
}

+ (UIImage*)imageWithCenterCrop:(UIImage*)scrImage  size:(CGSize)size
{
    UIImage *finalImage;
    UIImage *temp = [scrImage resizedImageWithMinimumSize:size];
    
    float x = 0;
    float y = 0;
    //create fram for crop the center of the image
    if (temp.size.width > temp.size.height) {
        x = temp.size.width/2 - size.width/2;
        y = 0;
    } else {
        x = 0;
        y = temp.size.height/2 - size.height/2;
    }
    
    finalImage = [SCImageUtil cropImageWith:temp rect:CGRectMake(x, y, size.width, size.height)];
    temp = nil;
    scrImage = nil;
    return finalImage;
}

+ (void)cropImageFromURLAsset:(NSURL*)assetURL  size:(CGSize)size completionBlock:(void (^)(UIImage *result))completionBlock  completionBlock:(void (^)(void))failureBlock
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    [library assetForURL:assetURL
             resultBlock:^(ALAsset *asset)
     {
         UIImage *fullImage  = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
         UIImage *result = [SCImageUtil imageWithCenterCrop:fullImage size:size];
         asset = nil;
         fullImage = nil;
         completionBlock(result);
         
     }
    failureBlock:^(NSError *error){
                [SVProgressHUD dismiss];
        failureBlock();
        } ];
}



+ (void)getImageFromURLAsset:(NSURL*)assetURL  completionBlock:(void (^)(UIImage *result))completionBlock  completionBlock:(void (^)(void))failureBlock
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    [library assetForURL:assetURL
             resultBlock:^(ALAsset *asset)
     {
         UIImage *fullImage  = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
         asset = nil;
         completionBlock(fullImage);
         
     }
            failureBlock:^(NSError *error){
                [SVProgressHUD dismiss];
                failureBlock();
            } ];
}

+ (UIImage *)getSubImageFrom:(UIImage*)image rect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, image.size.width, image.size.height);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [image drawInRect:drawRect];
    
    // grab image
    UIImage* croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return croppedImage;
}



@end




