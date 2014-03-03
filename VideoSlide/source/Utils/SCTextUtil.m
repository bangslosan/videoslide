//
//  SCTextUtil.m
//  SlideshowCreator
//
//  Created 10/15/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCTextUtil.h"

@implementation SCTextUtil

+ (BOOL)isEmptyString:(NSString *)string {
    if (string) {
        if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
            return YES;
        }
    } else {
        return YES;
    }
    return NO;
}

+ (CGFloat)heightWithText:(NSString *)textString size:(float)size font:(NSString*)fontName {
    
    CGSize maximumSize = CGSizeMake((SC_IS_IPHONE5?SC_TEXT_LABEL_WIDTH_DEFAULT:SC_TEXT_LABEL_WIDTH_DEFAULT_IPHONE4) , 99999);
    UIFont *font = [UIFont fontWithName:fontName size:size];
    
    CGSize heightStringSize = [textString sizeWithFont:font
                                     constrainedToSize:maximumSize
                                         lineBreakMode:NSLineBreakByWordWrapping];
    
    return heightStringSize.height;
    
}

+ (CGFloat)widthWithText:(NSString *)textString size:(float)size font:(NSString*)fontName {
    
    CGSize maximumSize = CGSizeMake(99999, SC_TEXT_LABEL_HEIGHT_DEFAULT);
    UIFont *font = [UIFont fontWithName:fontName size:size];
    
    CGSize heightStringSize = [textString sizeWithFont:font
                                     constrainedToSize:maximumSize
                                         lineBreakMode:NSLineBreakByWordWrapping];
    
    return heightStringSize.height;
    
}

+ (CGSize)sizeWithText:(NSString *)textString size:(float)size font:(NSString*)fontName {
    CGSize maximumSize = CGSizeMake(1024, 99999);
    UIFont *font = [UIFont fontWithName:fontName size:size];
    
    return [textString sizeWithFont:font
                  constrainedToSize:maximumSize
                      lineBreakMode:NSLineBreakByWordWrapping];
}

+ (CGFloat)heightWithAttributedText:(NSString *)string
                               size:(float)size
                               font:(NSString*)fontName
                        lineSpacing:(int)lineSpacing
                   characterSpacing:(int)characterSpacing {
    
    UIFont *font = [UIFont fontWithName:fontName size:size];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing:lineSpacing];
    NSNumber *numberCharacterSpacing = [NSNumber numberWithInt:characterSpacing];
    
    NSDictionary *attributes = @{ NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle , NSKernAttributeName: numberCharacterSpacing};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    
    CGRect rect = [attributedString boundingRectWithSize:CGSizeMake((SC_IS_IPHONE5?
                                                                     SC_TEXT_LABEL_WIDTH_DEFAULT:
                                                                     SC_TEXT_LABEL_WIDTH_DEFAULT_IPHONE4) ,
                                                                     10000)
                                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine)
                                                 context:nil];

    return rect.size.height;

}

+ (CGSize)sizeWithAttributedText:(NSString *)string
                            size:(float)size
                            font:(NSString*)fontName
                     lineSpacing:(int)lineSpacing
                characterSpacing:(int)characterSpacing {
    
    UIFont *font = [UIFont fontWithName:fontName size:size];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing:lineSpacing];
    NSNumber *numberCharacterSpacing = [NSNumber numberWithInt:characterSpacing];
    
    NSDictionary *attributes = @{ NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle , NSKernAttributeName: numberCharacterSpacing};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    
    CGRect rect = [attributedString boundingRectWithSize:CGSizeMake(1000,
                                                                    SC_TEXT_LABEL_HEIGHT_DEFAULT)
                                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine)
                                                 context:nil];
    
    if (rect.size.width > (SC_IS_IPHONE5?SC_TEXT_LABEL_WIDTH_DEFAULT_IPHONE5:SC_TEXT_LABEL_WIDTH_DEFAULT_IPHONE4)) {
        rect = [attributedString boundingRectWithSize:CGSizeMake((SC_IS_IPHONE5?
                                                                  SC_TEXT_LABEL_WIDTH_DEFAULT_IPHONE5:
                                                                  SC_TEXT_LABEL_WIDTH_DEFAULT_IPHONE4),
                                                                 1000)
                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine)
                                              context:nil];
    }
    
    return rect.size;
}

+ (NSTextAlignment)textAlign:(SCTextAlignment)alignment {
    switch (alignment) {
        case SCEnumTextAlignmentCenter:
            return NSTextAlignmentCenter;
            break;
        case SCEnumTextAlignmentLeft:
            return NSTextAlignmentLeft;
            break;
        case SCEnumTextAlignmentRight:
            return NSTextAlignmentRight;
            break;
        default:
            return NSTextAlignmentCenter;
            break;
    }
}

+ (SCColor)colorPickerText:(ColorPickerText)color {
    switch (color) {
        case ColorPickerTextBlue:
            return SCColorMake(1.0/255.0, 167.0/255.0, 222.0/255.0, 1.0);
            break;
        case ColorPickerTextDarkBlue:
            return SCColorMake(37.0/255.0, 63.0/255.0, 152.0/255.0, 1.0);
            break;
        case ColorPickerTextPink:
            return SCColorMake(215.0/255.0, 1.0/255.0, 132.0/255.0, 1.0);
            break;
        case ColorPickerTextRed:
            return SCColorMake(235.0/255.0, 36.0/255.0, 53.0/255.0, 1.0);
            //return SCColorMake(255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0);
            break;
        case ColorPickerTextOrange:
            //return SCColorMake(245.0/255.0, 86.0/255.0, 45.0/255.0, 1.0);
            return SCColorMake(0.0/255.0, 0.0/255.0, 0.0/255.0, 1.0);
            break;
        case ColorPickerTextYellow:
            return SCColorMake(253.0/255.0, 231.0/255.0, 45.0/255.0, 1.0);
            break;
        case ColorPickerTextGreen:
            return SCColorMake(6.0/255.0, 159.0/255.0, 83.0/255.0, 1.0);
            break;
        case ColorPickerTextBlack:
            //return SCColorMake(0.0/255.0, 0.0/255.0, 0.0/255.0, 1.0);
            return SCColorMake(245.0/255.0, 86.0/255.0, 45.0/255.0, 1.0);
            break;
        case ColorPickerTextWhite:
            return SCColorMake(255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0);
            //return SCColorMake(235.0/255.0, 36.0/255.0, 53.0/255.0, 1.0);
            break;
        case ColorPickerTextGray:
            return SCColorMake(161.0/255.0, 161.0/255.0, 161.0/255.0, 1.0);
            break;
        case ColorPickerTextViolet:
            return SCColorMake(146.0/255.0, 6.0/255.0, 176.0/255.0, 1.0);
            break;
        case ColorPickerTextBrown:
            return SCColorMake(124.0/255.0, 72.0/255.0, 7.0/255.0, 1.0);
            break;
        case ColorPickerTextLime:
            return SCColorMake(0.0/255.0, 255.0/255.0, 255.0/255.0, 1.0);
            break;
        case ColorPickerTextLightPink:
            return SCColorMake(244.0/255.0, 152.0/255.0, 158.0/255.0, 1.0);
            break;
        case ColorPickerTextLightGreen:
            return SCColorMake(172.0/255.0, 244.0/255.0, 152.0/255.0, 1.0);
            break;
        default:
            return SCColorMake(1.0/255.0, 167.0/255.0, 222.0/255.0, 1.0);
            break;
    }
}

@end
