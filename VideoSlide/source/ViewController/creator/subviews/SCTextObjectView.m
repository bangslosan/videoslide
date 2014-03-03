//
//  SCTextObjectView.m
//  SlideshowCreator
//
//  Created 10/16/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCTextObjectView.h"

@implementation SCTextObjectView
@synthesize textLb = _textLb;
@synthesize delegate = _delegate;
@synthesize textComposition = _textComposition;
@synthesize textHolderView = _textHolderView;
@synthesize isFirstInit = _isFirstInit;
@synthesize duplicateBtn = _duplicateBtn;
@synthesize deleteBtn = _delegateBtn;
@synthesize editBtn = _editBtn;
@synthesize canEdit = _canEdit;

// new
- (id)initTextObjectViewWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self = [[[NSBundle mainBundle] loadNibNamed:@"SCTextObjectView" owner:self options:nil] objectAtIndex:0];
        [self setFrame:frame];
        [self loadGesturesRegister];
        
        //self.isFirstInit = YES;
        
        self.textComposition = [[SCTextComposition alloc] init];
        
        [self updateAtInit];
        
    }
    return self;
}

- (id)initFirstTimeWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self = [[[NSBundle mainBundle] loadNibNamed:@"SCTextObjectView" owner:self options:nil] objectAtIndex:0];
        [self setFrame:frame];
        [self loadGesturesRegister];
        
        self.isFirstInit = YES;
        
        self.textComposition = [[SCTextComposition alloc] init];
        self.textComposition.model.position = SCVectorMake(self.frame.origin.x, self.frame.origin.y);
        self.textComposition.model.center = SCVectorMake(self.center.x, self.center.y);

        [self update];
    }
    return self;
}

- (id)initWithDuplicateTextObjectView:(SCTextObjectView*)textObjectView {
    
    CGRect duplicateFrame = CGRectMake(textObjectView.frame.origin.x,
                                       textObjectView.frame.origin.y + textObjectView.frame.size.height,
                                       textObjectView.frame.size.width,
                                       textObjectView.frame.size.height);
    
    self = [super initWithFrame:duplicateFrame];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"SCTextObjectView" owner:self options:nil] objectAtIndex:0];
        [self setFrame:duplicateFrame];
        [self loadGesturesRegister];

        self.textComposition = [[SCTextComposition alloc] initWithTextComposition:textObjectView.textComposition];
        self.textComposition.model.position = SCVectorMake(duplicateFrame.origin.x, duplicateFrame.origin.y);
        self.textComposition.model.center = SCVectorMake(textObjectView.center.x, textObjectView.center.y + textObjectView.frame.size.height);
        [self update];
    }
    return self;
}

- (id)initWithClipboardTextObjectView:(SCTextObjectView*)textObjectView {
    
    self = [super initWithFrame:textObjectView.frame];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"SCTextObjectView" owner:self options:nil] objectAtIndex:0];
        [self setFrame:textObjectView.frame];
        [self loadGesturesRegister];
        
        self.textComposition = [[SCTextComposition alloc] initWithTextComposition:textObjectView.textComposition];
        self.textComposition.model.position = SCVectorMake(textObjectView.frame.origin.x, textObjectView.frame.origin.y);
        self.textComposition.model.center = SCVectorMake(textObjectView.center.x, textObjectView.center.y);
        [self update];
    }
    return self;
    
}

- (id)initWithTextComposition:(SCTextComposition*)textComposition {
    
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"SCTextObjectView" owner:self options:nil] objectAtIndex:0];
        [self setFrame:CGRectMake(textComposition.model.position.x,
                                  textComposition.model.position.y,
                                  textComposition.model.size.width,
                                  textComposition.model.size.height)];
        [self loadGesturesRegister];
        
        self.textComposition = [[SCTextComposition alloc] initWithTextComposition:textComposition];
        [self update];
    }
    return self;
}

- (void)loadGesturesRegister {
    //Double tap
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(handleDoubleTap:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    doubleTapGestureRecognizer.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:doubleTapGestureRecognizer];
    
    //Single tap
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(handleSingleTap:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    singleTapGestureRecognizer.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:singleTapGestureRecognizer];
    
    //Pan to drag
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handlePan:)];
    [self addGestureRecognizer:panGestureRecognizer];
}

- (void)updateTextComposition {
    
    self.textComposition.model.position = SCVectorMake(self.frame.origin.x, self.frame.origin.y);
    self.textComposition.model.size = SCSizeMake(self.frame.size.width, self.frame.size.height);
    self.textComposition.model.center = SCVectorMake(self.center.x, self.center.y);
    
}

- (CGRect)frameWithHeight:(CGFloat)height position:(SCVector)position{
    if (height > SC_TEXT_LABEL_HEIGHT_DEFAULT) {
        return CGRectMake(position.x,
                          position.y,
                          (SC_IS_IPHONE5?SC_TEXT_OBJECT_VIEW_WIDTH:SC_TEXT_OBJECT_VIEW_WIDTH_IPHONE4),
                          height + 24);
    }
    
    return CGRectMake(position.x,
                      position.y,
                      (SC_IS_IPHONE5?SC_TEXT_OBJECT_VIEW_WIDTH:SC_TEXT_OBJECT_VIEW_WIDTH_IPHONE4),
                      SC_TEXT_OBJECT_VIEW_HEIGHT);
}

// frame of Parent Text Object View
- (CGRect)frameWithSize:(CGSize)size position:(SCVector)position{
    
//    float widthOfEditView  = (SC_IS_IPHONE5?SC_TEXT_EDIT_VIEW_SIZE_IPHONE5:SC_TEXT_EDIT_VIEW_SIZE_IPHONE4).width;
//    float heightOfEditView = (SC_IS_IPHONE5?SC_TEXT_EDIT_VIEW_SIZE_IPHONE5:SC_TEXT_EDIT_VIEW_SIZE_IPHONE4).height;
//    
//    self.center = CGPointMake(widthOfEditView - (position.x + size.width/2),
//                              widthOfEditView - (position.y + size.height/2));
    
    CGRect newRect;
    float textObjectViewWidth = size.width + SC_TEXT_HOLDER_VIEW_MARGIN*2 + SC_TEXT_LABEL_MARGIN*2;
    
    if (textObjectViewWidth > (SC_IS_IPHONE5?SC_TEXT_EDIT_VIEW_SIZE_IPHONE5:SC_TEXT_EDIT_VIEW_SIZE_IPHONE4).width) {
        newRect =  CGRectMake(position.x,
                          position.y,
                          (SC_IS_IPHONE5?SC_TEXT_OBJECT_VIEW_WIDTH:SC_TEXT_OBJECT_VIEW_WIDTH_IPHONE4),
                          size.height + SC_TEXT_HOLDER_VIEW_MARGIN*2 + SC_TEXT_LABEL_MARGIN*2);
        [self setFrame:newRect];
        self.center = CGPointMake(self.textComposition.model.center.x, self.textComposition.model.center.y);
        [self checkValidFrame];
        return newRect;
    }
    
    newRect = CGRectMake(
                      (SC_IS_IPHONE5?SC_TEXT_EDIT_VIEW_SIZE_IPHONE5:SC_TEXT_EDIT_VIEW_SIZE_IPHONE4).width/2
                      - (size.width + SC_TEXT_HOLDER_VIEW_MARGIN*2 + SC_TEXT_LABEL_MARGIN*2)/2,
                      position.y,
                      size.width + SC_TEXT_HOLDER_VIEW_MARGIN*2 + SC_TEXT_LABEL_MARGIN*2,
                      size.height + SC_TEXT_HOLDER_VIEW_MARGIN*2 + SC_TEXT_LABEL_MARGIN*2);
    
    [self setFrame:newRect];
    self.center = CGPointMake(self.textComposition.model.center.x, self.textComposition.model.center.y);
    [self checkValidFrame];
    return newRect;
}

- (void)checkValidFrame {
    
    return;
    
    float widthTextEditView = (SC_IS_IPHONE5?SC_TEXT_EDIT_VIEW_SIZE_IPHONE5:SC_TEXT_EDIT_VIEW_SIZE_IPHONE4).width;
    float heightTextEditView = (SC_IS_IPHONE5?SC_TEXT_EDIT_VIEW_SIZE_IPHONE5:SC_TEXT_EDIT_VIEW_SIZE_IPHONE4).height;
    
    if (self.frame.origin.x < 0) {
        self.frame = CGRectMake(0,
                                self.frame.origin.y,
                                self.frame.size.width,
                                self.frame.size.height);
    } else if (self.frame.origin.y < 0) {
        self.frame = CGRectMake(self.frame.origin.x,
                                0,
                                self.frame.size.width,
                                self.frame.size.height);
    } else if ((self.frame.size.width + self.frame.origin.x) > widthTextEditView) {
        self.frame = CGRectMake(widthTextEditView - self.frame.size.width,
                                self.frame.origin.y,
                                self.frame.size.width,
                                self.frame.size.height);
    } else if ((self.frame.size.height + self.frame.origin.y) > heightTextEditView) {
        self.frame = CGRectMake(self.frame.origin.x,
                                heightTextEditView - self.frame.size.height,
                                self.frame.size.width,
                                self.frame.size.height);
    }
}

- (void)update {
    [self updateFrameAtFirstTime:NO];
}

- (void)updateAtFirstTime {
    [self updateFrameAtFirstTime:YES];
}

- (void)updateFrameAtFirstTime:(BOOL)isFirstTime {
    
    self.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
    
    if (isFirstTime) {
        
        // Set frame for Text Label HOLDER View
        self.textHolderView.frame = CGRectMake(SC_TEXT_HOLDER_VIEW_MARGIN,
                                               SC_TEXT_HOLDER_VIEW_MARGIN,
                                               SC_TEXT_LABEL_MIN_WIDTH + SC_TEXT_HOLDER_VIEW_MARGIN*2,
                                               SC_TEXT_LABEL_HEIGHT_DEFAULT + SC_TEXT_HOLDER_VIEW_MARGIN*2);
        
        // Set frame for Text Label
        self.textLb.frame = CGRectMake(SC_TEXT_LABEL_MARGIN,
                                       SC_TEXT_LABEL_MARGIN,
                                       SC_TEXT_LABEL_MIN_WIDTH,
                                       SC_TEXT_LABEL_HEIGHT_DEFAULT);
        
        [self addEditStatus];
        
    } else {

        CGSize sizeWithText = [SCTextUtil sizeWithAttributedText:self.textComposition.model.text
                                                            size:self.textComposition.model.fontSize
                                                            font:self.textComposition.model.fontName
                                                     lineSpacing:self.textComposition.model.lineSpacing
                                                characterSpacing:self.textComposition.model.characterSpacing];
        
        // Set frame for Parent Text Object View
        CGRect frame = [self frameWithSize:sizeWithText position:self.textComposition.model.position];
        //self.frame = frame;
        
        // Set frame for Text Label HOLDER View
        self.textHolderView.frame = CGRectMake(SC_TEXT_HOLDER_VIEW_MARGIN,
                                               SC_TEXT_HOLDER_VIEW_MARGIN,
                                               frame.size.width - SC_TEXT_HOLDER_VIEW_MARGIN*2,
                                               frame.size.height - SC_TEXT_HOLDER_VIEW_MARGIN*2);

        // Set frame for Text Label
        self.textLb.frame = CGRectMake(SC_TEXT_LABEL_MARGIN,
                                       SC_TEXT_LABEL_MARGIN,
                                       sizeWithText.width,
                                       sizeWithText.height);
        
        [self addEditStatus];
        
    }
    
    // display text
    UIFont *font;
    if ([UIFont fontWithName:self.textComposition.model.fontName size:self.textComposition.model.fontSize]) {
        font = [UIFont fontWithName:self.textComposition.model.fontName size:self.textComposition.model.fontSize];
    } else {
        font = [UIFont systemFontOfSize:self.textComposition.model.fontSize];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing:self.textComposition.model.lineSpacing];
    NSNumber *number = [NSNumber numberWithInt:self.textComposition.model.characterSpacing];
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:font forKey:NSFontAttributeName];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setObject:number forKey:NSKernAttributeName];
  
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.textComposition.model.text
                                                                           attributes:attributes];
    self.textLb.attributedText = attributedString;
    
    // alignment
    self.textLb.textAlignment = [SCTextUtil textAlign:self.textComposition.model.txtAlignment];
    
    // opacity
    self.textLb.alpha = self.textComposition.model.opacity;
    
    // color
    self.textLb.textColor = [SCHelper colorFromSCColor:self.textComposition.model.color];
    
    [self updateTextComposition];
    
    self.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(self.textComposition.model.angle));
}

// new
- (void)updateAtInit {
    
    self.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
    
    // Set frame for Text Label HOLDER View
    self.textHolderView.frame = CGRectMake(SC_TEXT_HOLDER_VIEW_MARGIN,
                                           SC_TEXT_HOLDER_VIEW_MARGIN,
                                           SC_TEXT_LABEL_MIN_WIDTH + SC_TEXT_HOLDER_VIEW_MARGIN*2,
                                           SC_TEXT_LABEL_HEIGHT_DEFAULT + SC_TEXT_HOLDER_VIEW_MARGIN*2);
    // Set frame for Text Label
    self.textLb.frame = CGRectMake(SC_TEXT_LABEL_MARGIN,
                                   SC_TEXT_LABEL_MARGIN,
                                   SC_TEXT_LABEL_MIN_WIDTH,
                                   SC_TEXT_LABEL_HEIGHT_DEFAULT);
    
    [self addDottedBorder];
    
    // display text
    UIFont *font;
    if ([UIFont fontWithName:self.textComposition.model.fontName size:self.textComposition.model.fontSize]) {
        font = [UIFont fontWithName:self.textComposition.model.fontName size:self.textComposition.model.fontSize];
    } else {
        font = [UIFont systemFontOfSize:self.textComposition.model.fontSize];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing:self.textComposition.model.lineSpacing];
    NSNumber *number = [NSNumber numberWithInt:self.textComposition.model.characterSpacing];
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:font forKey:NSFontAttributeName];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setObject:number forKey:NSKernAttributeName];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.textComposition.model.text
                                                                           attributes:attributes];
    self.textLb.attributedText = attributedString;
    
    // alignment
    self.textLb.textAlignment = [SCTextUtil textAlign:self.textComposition.model.txtAlignment];
    
    // opacity
    self.textLb.alpha = self.textComposition.model.opacity;
    
    // color
    self.textLb.textColor = [SCHelper colorFromSCColor:self.textComposition.model.color];
    
    [self updateTextComposition];
    
    self.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(self.textComposition.model.angle));
}

#pragma mark - Dotted border

- (void)addDottedBorder {
    
    [self removeDottedBorder];
    
    self.textHolderView.layer.cornerRadius = 10;

    //Border
    shapeLayer_ = [CAShapeLayer layer];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.textHolderView.bounds);
    shapeLayer_.path = path;
    CGPathRelease(path);
    shapeLayer_.backgroundColor = [[UIColor clearColor] CGColor];
    shapeLayer_.frame = self.textHolderView.bounds;
    
    [shapeLayer_ setValue:[NSNumber numberWithBool:NO] forKey:@"isCircle"];
    shapeLayer_.fillColor = [[UIColor clearColor] CGColor];
    shapeLayer_.strokeColor = [[UIColor whiteColor] CGColor];
    shapeLayer_.lineWidth = 2.;
    [shapeLayer_ setLineJoin:kCALineJoinRound];
    shapeLayer_.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:3], nil];
    shapeLayer_.lineCap = kCALineCapSquare;
    
    UIBezierPath *path1 = [UIBezierPath bezierPathWithRoundedRect:self.textHolderView.bounds cornerRadius:10.0];
    [shapeLayer_ setPath:path1.CGPath];
    
    [self.textHolderView.layer addSublayer:shapeLayer_];
    
    self.canEdit = YES;
}

- (void)removeDottedBorder {
    if (shapeLayer_) {
        [shapeLayer_ removeFromSuperlayer];
    }
    
    self.canEdit = NO;
}

- (void)addEditStatus {
    [self addDottedBorder];
    self.duplicateBtn.hidden = NO;
    self.editBtn.hidden = NO;
    self.deleteBtn.hidden = NO;
    
    [self bringSubviewToFront:self.duplicateBtn];
    [self bringSubviewToFront:self.editBtn];
    [self bringSubviewToFront:self.deleteBtn];
    
    // disable all gesture
    self.canEdit = YES;
}

- (void)removeEditStatus {

    [self removeDottedBorder];
    
    self.duplicateBtn.hidden = YES;
    self.editBtn.hidden = YES;
    self.deleteBtn.hidden = YES;
    
    // disable all gesture
    self.canEdit = NO;
}

#pragma mark - Gesture process
- (void)handleDoubleTap:(UITapGestureRecognizer*)recognizer {
    
    if (!self.canEdit) {
        return;
    }
    
    [self.delegate onBeginInputText:self];
}

- (void)handleSingleTap:(UITapGestureRecognizer*)recognizer {
    //[self addDottedBorder];
    [self.delegate draggingTextObject:self];
}


- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    if (!self.canEdit) {
        return;
    }
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self.delegate draggingTextObject:self];
        [[self superview] bringSubviewToFront:self];

    }
    else if(recognizer.state == UIGestureRecognizerStateChanged)
    {

        CGPoint translation = [recognizer translationInView:self.superview];
      
        /*
        if ((translation.y <= 0) && (translation.x <= 0)) {
            recognizer.view.center = CGPointMake(MAX(recognizer.view.center.x + translation.x,
                                                     recognizer.view.frame.size.width/2),
                                                 MAX(recognizer.view.center.y + translation.y,
                                                     recognizer.view.frame.size.height/2));
        } else if ((translation.y <= 0) && (translation.x >= 0)) {
            recognizer.view.center = CGPointMake(MIN(recognizer.view.center.x + translation.x,
                                                     (SC_IS_IPHONE5?SC_TEXT_EDIT_VIEW_SIZE_IPHONE5:SC_TEXT_EDIT_VIEW_SIZE_IPHONE4).width
                                                     - recognizer.view.frame.size.width/2),
                                                 MAX(recognizer.view.center.y + translation.y,
                                                     recognizer.view.frame.size.height/2));
        } else if ((translation.y >= 0) && (translation.x <= 0) ){
            recognizer.view.center = CGPointMake(MAX(recognizer.view.center.x + translation.x,
                                                     recognizer.view.frame.size.width/2),
                                                 MIN(recognizer.view.center.y + translation.y,
                                                     ((SC_IS_IPHONE5) ? 225 : 156) - recognizer.view.frame.size.height/2));
        } else if ((translation.y >= 0) && (translation.x >= 0) ){
            recognizer.view.center = CGPointMake(MIN(recognizer.view.center.x + translation.x,
                                                     (SC_IS_IPHONE5?SC_TEXT_EDIT_VIEW_SIZE_IPHONE5:SC_TEXT_EDIT_VIEW_SIZE_IPHONE4).width
                                                     - recognizer.view.frame.size.width/2),
                                                 MIN(recognizer.view.center.y + translation.y,
                                                     ((SC_IS_IPHONE5) ? 225 : 156) - recognizer.view.frame.size.height/2));
        }
         */
        
        recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                             recognizer.view.center.y + translation.y);
        
        [self updateTextComposition];
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
        if([self.delegate respondsToSelector:@selector(didEndDragTextObject:)])
           [self.delegate didEndDragTextObject:self];
    }

}

#pragma mark - IBActions
- (IBAction)onDuplicateBtn {
    if (self.isFirstInit || [self.textComposition.model.text isEqualToString:@""]) {
        [self showAlertCannotDoBeforeEnterText];
        return;
    }
    
    [self.delegate onDuplicateTextObjectView:self];
}

- (IBAction)onDeleteBtn {
    [self.delegate onDeleteTextObjectView:self];
}

- (IBAction)onEditBtn {
    if (self.isFirstInit || [self.textComposition.model.text isEqualToString:@""]) {
        [self showAlertCannotDoBeforeEnterText];
        return;
    }
    [self.delegate onEditTextObjectView:self];
}

- (void)showAlertCannotDoBeforeEnterText {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You should enter text before duplicate, copy or edit." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - SCView
- (void)clearAll {
    [super clearAll];
}

#pragma mark - New Text Object View with Scale
- (id)initWithTextObjectView:(SCTextObjectView*)textObjectView andScale:(float)scale {
    
    CGPoint deltaPoint = (SC_IS_IPHONE5?SC_PREVIEW_4INCH_POSITION_DELTA:SC_PREVIEW_3INCH5_POSITION_DELTA);
    
    CGRect duplicateFrame = CGRectMake((textObjectView.frame.origin.x + deltaPoint.x) * scale,
                                       (textObjectView.frame.origin.y + deltaPoint.y) * scale,
                                       textObjectView.frame.size.width * scale,
                                       textObjectView.frame.size.height * scale);
    
    self = [super initWithFrame:duplicateFrame];
    
    if (self) {
        
        self = [[[NSBundle mainBundle] loadNibNamed:@"SCTextObjectView" owner:self options:nil] objectAtIndex:0];
        [self setFrame:duplicateFrame];
        
        //self.backgroundColor = [UIColor redColor];
        
        self.textHolderView.frame = CGRectMake(SC_TEXT_HOLDER_VIEW_MARGIN * scale,
                                               SC_TEXT_HOLDER_VIEW_MARGIN * scale,
                                               duplicateFrame.size.width - (SC_TEXT_HOLDER_VIEW_MARGIN * scale) * 2,
                                               duplicateFrame.size.height - (SC_TEXT_HOLDER_VIEW_MARGIN * scale) * 2);
        
        //self.textHolderView.backgroundColor = [UIColor greenColor];
        
        self.textLb.frame = CGRectMake(SC_TEXT_LABEL_MARGIN * scale,
                                       SC_TEXT_LABEL_MARGIN * scale,
                                       self.textHolderView.frame.size.width - (SC_TEXT_LABEL_MARGIN * scale) * 2,
                                       self.textHolderView.frame.size.height - (SC_TEXT_LABEL_MARGIN * scale) * 2);
        
        //self.textLb.backgroundColor = [UIColor yellowColor];
        
        // display text
        UIFont *font;
        if ([UIFont fontWithName:textObjectView.textComposition.model.fontName size:textObjectView.textComposition.model.fontSize*scale]) {
            font = [UIFont fontWithName:textObjectView.textComposition.model.fontName size:textObjectView.textComposition.model.fontSize*scale];
        } else {
            font = [UIFont systemFontOfSize:textObjectView.textComposition.model.fontSize*scale];
        }
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setLineSpacing:textObjectView.textComposition.model.lineSpacing*scale];
        NSNumber *number = [NSNumber numberWithInt:textObjectView.textComposition.model.characterSpacing*scale];
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
        [attributes setObject:font forKey:NSFontAttributeName];
        [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
        [attributes setObject:number forKey:NSKernAttributeName];
        
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:textObjectView.textComposition.model.text
                                                                               attributes:attributes];
        self.textLb.attributedText = attributedString;
        
        // alignment
        self.textLb.textAlignment = [SCTextUtil textAlign:textObjectView.textComposition.model.txtAlignment];
        
        // opacity
        self.textLb.alpha = textObjectView.textComposition.model.opacity;
        
        // color
        self.textLb.textColor = [SCHelper colorFromSCColor:textObjectView.textComposition.model.color];
        
        self.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(textObjectView.textComposition.model.angle));
        
        [self removeEditStatus];
    }
    return self;
}

@end
