/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIButton+WebCache.h"
#import "SDWebImageManager.h"

@implementation UIButton (WebCache)

- (void)setBackgroundImageWithURL:(NSURL *)url {
    [self setBackgroundImageWithURL:url placeholderBackgroundImage:nil];
}

- (void)setBackgroundImageWithURL:(NSURL *)url  placeholderBackgroundImage:(UIImage *)placeholder {
    [self setBackgroundImage:placeholder forState:UIControlStateNormal];
    
    dispatch_queue_t download = dispatch_queue_create("download", NULL);
    dispatch_async(download, ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *img = [UIImage imageWithData:data];
            [self setBackgroundImage:img forState:UIControlStateNormal];
            
            //dispatch_release(download);
        });
    });
}

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];

    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    [self setImage:placeholder forState:UIControlStateNormal];

    if (url)
    {
        [manager downloadWithURL:url delegate:self];
    }
}

- (void)cancelCurrentImageLoad
{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    [self setImage:image forState:UIControlStateNormal];
}

@end
