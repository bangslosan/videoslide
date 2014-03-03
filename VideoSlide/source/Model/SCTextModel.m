//
//  SCTextModel.m
//  SlideshowCreator
//
//  Created 9/12/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCTextModel.h"

@implementation SCTextModel

@synthesize position = _position;
@synthesize size = _size;
@synthesize center = _center;
@synthesize text = _text;
@synthesize fontSize = _fontSize;
@synthesize lineSpacing = _lineSpacing;
@synthesize characterSpacing = _characterSpacing;
@synthesize opacity = _opacity;
@synthesize txtAlignment = _txtAlignment;
@synthesize fontName = _fontName;
@synthesize color = _color;
@synthesize angle = _angle;
@synthesize indexColorPickerText = _indexColorPickerText;

- (id)init
{
    self = [super init];
    if(self)
    {
        self.position               = SCVectorMake(0, 0);
        self.size                   = SCSizeMake(0, 0);
        self.center                 = SCVectorMake(self.position.x + self.size.width/2, self.position.y + self.size.height/2);
        self.text                   = SC_MESSAGE_DOUBLE_ENTER_TEXT;
        self.fontSize               = 16.0;
        self.lineSpacing            = 0;
        self.characterSpacing       = 0;
        self.opacity                = 1.0;
        self.txtAlignment           = SCEnumTextAlignmentCenter;
        self.fontName               = SC_TEXT_FONT_NAME_DEFAULT;
        self.color                  = SCColorMake(1.0f, 1.0f, 1.0f, 1.0f);
        self.indexColorPickerText   = ColorPickerTextWhite;
        self.angle                  = 0;
    }
    
    return self;
}

- (id)initWithTextModel:(SCTextModel*)textModel {
    self = [super init];
    if (self) {
        self.position               = textModel.position;
        self.size                   = textModel.size;
        self.center                 = textModel.center;
        self.text                   = textModel.text;
        self.fontSize               = textModel.fontSize;
        self.lineSpacing            = textModel.lineSpacing;
        self.characterSpacing       = textModel.characterSpacing;
        self.opacity                = textModel.opacity;
        self.txtAlignment           = textModel.txtAlignment;
        self.fontName               = textModel.fontName;
        self.color                  = textModel.color;
        self.indexColorPickerText   = textModel.indexColorPickerText;
        self.angle                  = textModel.angle;
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    if(!dict)
        return nil;
    self = [super initWithDictionary:dict];
    if(self)
    {
        self.center     = [SCHelper vectorFromArray:[dict valueForKey:@"center" withDefaultValue:SCDictionaryDefaultArray]];
        self.position   = [SCHelper vectorFromArray:[dict valueForKey:@"position" withDefaultValue:SCDictionaryDefaultArray]];

        self.color      = [SCHelper colorFromArray:[dict valueForKey:@"color" withDefaultValue:SCDictionaryDefaultArray]];
        self.size       = [SCHelper SCSizeFromArray:[dict valueForKey:@"size" withDefaultValue:SCDictionaryDefaultArray]];

    }
    
    return self;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dict = [super toDictionary];
    [dict setObject:[SCHelper arrayFromSCColor:self.color] forKey:@"color"];
    [dict setObject:[SCHelper arrayFromVector:self.center] forKey:@"center"];
    [dict setObject:[SCHelper arrayFromVector:self.position] forKey:@"position"];
    [dict setObject:[SCHelper arrayFromSCSize:self.size] forKey:@"size"];


    return dict;
}

- (void)clearAll
{
    [super clearAll];
}

@end
