//
//  Created 9/6/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//
#import "UIColor+SCAdditions.h"

@implementation UIColor (SCAdditions)

- (UIColor *)lighterColor {
    float hue, saturation, brightness, alpha;
    if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        return [UIColor colorWithHue:hue saturation:saturation brightness:MIN(brightness * 1.3, 1.0) alpha:alpha];
	}
    return nil;
}

- (UIColor *)darkerColor {
    float hue, saturation, brightness, alpha;
    if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
		return [UIColor colorWithHue:hue saturation:saturation brightness:brightness * 0.85 alpha:alpha];
	}
    return nil;
}

@end
