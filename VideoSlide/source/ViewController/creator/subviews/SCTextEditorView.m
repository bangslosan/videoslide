//
//  SCTextEditorView.m
//  SlideshowCreator
//
//  Created 10/14/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCTextEditorView.h"

@interface SCTextEditorView () <SCTextObjectViewDelegate, UITextFieldDelegate, IAInfiniteGridDataSource, IAInfiniteGridDelegate>

@property (nonatomic,strong) NSMutableArray                 *colorArray;
@property (nonatomic,assign) SCTextInputMode                currentTextInputMode;
@property (nonatomic,strong) SCTextObjectView               *currentTextObjectView;

// font view
@property (nonatomic,strong) IBOutlet UIButton              *chooseFontBtn;
@property (nonatomic,strong) IBOutlet UIView                *fontView;
@property (nonatomic,strong) IBOutlet UITableView           *fontTableView;
@property (nonatomic,strong) IBOutlet SCFontCell            *fontCell;
@property (nonatomic,assign) BOOL                           isShowFontView;;
@property (nonatomic,strong) NSMutableArray                 *fontNamesArray;

// editor
@property (nonatomic,strong) IBOutlet UILabel               *numberOfDegreeLb;
@property (nonatomic,strong) NSString                       *currentFontName;
@property (nonatomic,assign) int                            currentFontSize;
@property (nonatomic,assign) SCTextAlignment                currentTextAlignment;
@property (nonatomic,assign) float                          currentOpacity;
@property (nonatomic,strong) NSTimer                        *holdTimer;
@property (nonatomic,assign) SCTextTool                     currentToolHoldOn;
@property (nonatomic,assign) int                            totalTextObjectViewOnScreen;

// scroll infi
@property (nonatomic,strong) IBOutlet   IAInfiniteGridView  *colorGridView;

- (IBAction)onStartEditText:(id)sender;
- (IBAction)onDone:(id)sender;
- (IBAction)onChooseFontBtn:(id)sender;

- (IBAction)onCopyBtn:(id)sender;
- (IBAction)onDuplicateBtn:(id)sender;
- (IBAction)onCloseContextMenuBtn:(id)sender;

@end

@implementation SCTextEditorView

@synthesize textAreaView = _textAreaView;
@synthesize slideCompostion = _slideCompostion;
@synthesize delegate = _delegate;
@synthesize textObjectArray;
@synthesize inpuTextHolderView = _inpuTextHolderView;
@synthesize inputTf = _inputTf;
@synthesize currentTextInputMode = _currentTextInputMode;
@synthesize currentTextObjectView = _currentTextObjectView;
@synthesize chooseFontBtn = _chooseFontBtn;
@synthesize fontCell = _fontCell;
@synthesize holdTimer = _holdTimer;
@synthesize currentToolHoldOn = _currentToolHoldOn;
@synthesize contextMenuView = _contextMenuView;
@synthesize contextTextObjectView = _contextTextObjectView;
@synthesize pasteMenuView = _pasteMenuView;
@synthesize canPasteTextObjectView = _canPasteTextObjectView;
@synthesize pointToPaste = _pointToPaste;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"SCTextEditorView" owner:self options:nil] objectAtIndex:0];
    if(self)
    {
        
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.currentFontName = SC_TEXT_FONT_NAME_DEFAULT;
    self.currentFontSize = SC_TEXT_FONT_SIZE_DEFAULT;
    self.currentTextAlignment = SCEnumTextAlignmentCenter;
    self.currentOpacity = 1.0;
    
    self.totalTextObjectViewOnScreen = 0;
    
    self.textObjectArray = [[NSMutableArray alloc] init];
    
    self.currentTextInputMode = SCTextInputModeNew;
    
    self.textAreaView.clipsToBounds = YES;
    self.chooseFontBtn.layer.cornerRadius = 4;
    self.isShowFontView = NO;
    
    [self loadFontView];
    [self updateChooseFontBtn];
    
    self.contextMenuView.hidden = YES;
    
    self.pasteMenuView.hidden = YES;
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(handleSingleTapOnTextAreaView:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    singleTapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.textAreaView addGestureRecognizer:singleTapGestureRecognizer];
    
    self.canPasteTextObjectView = NO;
    
    self.colorGridView.layer.borderColor = [UIColor blackColor].CGColor;
    self.colorGridView.layer.borderWidth = 1.0f;
    self.colorGridView.clipsToBounds = YES;
    [self.colorGridView setCircular:YES];
    [self.colorGridView jumpToIndex:0];
}

- (void)clearAll
{
    [super clearAll];
    
    self.slideCompostion = nil;
}

- (void)handleSingleTapOnTextAreaView:(UITapGestureRecognizer*)recognizer {

    CGPoint point = [recognizer locationInView:self.textAreaView];
    [self showPasteMenuAtPoint:point];
}

- (SCTextObjectView*)loadFirstTextObjectViewFromContextMenu {
    
    SCTextObjectView *firstTextObjectView = [[SCTextObjectView alloc]
                                             initFirstTimeWithFrame:CGRectMake(
                        self.textAreaView.frame.size.width/2
                        - ((SC_TEXT_LABEL_MIN_WIDTH + SC_TEXT_LABEL_MARGIN*2 + SC_TEXT_HOLDER_VIEW_MARGIN*2)/2),
                        self.textAreaView.frame.size.height/2
                        - ((SC_TEXT_LABEL_HEIGHT_DEFAULT  + SC_TEXT_LABEL_MARGIN*2 + SC_TEXT_HOLDER_VIEW_MARGIN*2 )/2),
                        (SC_TEXT_LABEL_MIN_WIDTH + SC_TEXT_LABEL_MARGIN*2 + SC_TEXT_HOLDER_VIEW_MARGIN*2),
                        (SC_TEXT_LABEL_HEIGHT_DEFAULT  + SC_TEXT_LABEL_MARGIN*2 + SC_TEXT_HOLDER_VIEW_MARGIN*2))];
    
    firstTextObjectView.delegate = self;
    [self.textAreaView addSubview:firstTextObjectView];
    
    self.totalTextObjectViewOnScreen++;
    
    return firstTextObjectView;
}

#pragma mark - actions

- (IBAction)onChooseFontBtn:(id)sender {
    if (self.isShowFontView) {
        [self hideFontView];
    } else {
        [self showFontView];
    }
}

- (IBAction)onStartEditText:(id)sender
{
    // 2 ojects
//    self.slideCompostion.texts // textcomposition
    
    //check if this view is not laying main editor at this time
    if([self.delegate respondsToSelector:@selector(startToEditText)])
    {
        [self.delegate startToEditText];
    }
}

- (IBAction)onDoneTextEditorBtn:(id)sender
{
    if (self.isShowFontView) {
        [self hideFontView];
        return;
    }
    
    if([self.delegate respondsToSelector:@selector(didFinishEditingText:)])
    {
        self.slideCompostion.needToUpdate = YES;
        [self.delegate didFinishEditingText:self.slideCompostion];
    }
    
    //remove from super view
    [self moveDownWithCompletion:^
     {
         [self removeFromSuperview];
         if([self.delegate respondsToSelector:@selector(didEndEditting)])
         {
             [self.delegate didEndEditting];
         }
     }];

}

#pragma mark - UItextField delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    if ((textField.tag == 10) && (textField.returnKeyType == UIReturnKeyDone)) {
        
        [self onDoneBtn:nil];
        
        [self updateChooseFontBtn];
        [self updateChoosenColor];
        [self updateChoosenAngelRotation];
        
    } else if ((textField.tag == 10) && (textField.returnKeyType == UIReturnKeyDefault)) {
        
        if (self.currentTextInputMode == SCTextInputModeEdit) {
            [self onDeleteTextObjectView:self.currentTextObjectView];
        }
        
//        if (self.currentTextInputMode == SCTextInputModeNew) {
//
//        }
        
        [self onDoneTextEditorBtn:nil];
        [self onDoneWithDefaultReturnKey];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([SCTextUtil isEmptyString:newString]) {
        //[self onDoneInstant:SC_MESSAGE_DOUBLE_ENTER_TEXT];
        [self onDoneInstant:newString];
        
        self.inputTf.returnKeyType = UIReturnKeyDefault;
        if ([self.inputTf isFirstResponder]) {
            [self.inputTf reloadInputViews];
        }
        
    } else {
//        self.currentTextObjectView.isFirstInit = NO;
        [self onDoneInstant:newString];
        
        self.inputTf.returnKeyType = UIReturnKeyDone;
        if ([self.inputTf isFirstResponder]) {
            [self.inputTf reloadInputViews];
        }
    }
    return YES;
}


#pragma mark - SCTextObjectView delegate methods
- (void)onBeginInputText:(id)textObjectView {
    
    self.currentTextObjectView = (SCTextObjectView*)textObjectView;
    
    if([self.delegate respondsToSelector:@selector(startToEditText)])
    {
        if (self.currentTextObjectView.isFirstInit) {
            self.currentTextInputMode = SCTextInputModeNew;
            self.inputTf.text         = @"";
            
            self.inputTf.returnKeyType = UIReturnKeyDefault;
            if ([self.inputTf isFirstResponder]) {
                [self.inputTf reloadInputViews];
            }
        } else {
            self.currentTextInputMode = SCTextInputModeEdit;
            self.inputTf.text         = self.currentTextObjectView.textComposition.model.text;
            
            self.inputTf.returnKeyType = UIReturnKeyDone;
            if ([self.inputTf isFirstResponder]) {
                [self.inputTf reloadInputViews];
            }
        }
        
        self.inpuTextHolderView.hidden  = NO;
        NSLog(@"#1 keyboard appear");
        [self.inputTf becomeFirstResponder];
        NSLog(@"#2 keyboard appear");
        [self.delegate startToEditText];
    }
}

- (void)onDeleteTextObjectView:(id)textObjectView {
    
    [self hideContextMenu];
    [self hidePasteMenu];
    
    [self.slideCompostion.texts removeObject:(SCTextObjectView*)textObjectView];
    
    [((SCTextObjectView*)textObjectView) removeFromSuperview];
    self.totalTextObjectViewOnScreen--;

    [self hideTextToolsWhenDeleteInstant];
    
    /*
    if (self.totalTextObjectViewOnScreen <= 0) {
        [self loadFirstTextObjectViewFromContextMenu];
    }
    */
    
}

- (void)onDuplicateTextObjectView:(id)textObjectView {
    
    self.contextTextObjectView = (SCTextObjectView*)textObjectView;
    
    [self onDuplicateBtn:nil];
    
    // disable paste
    //[self showContextMenu];
    
    /*
    SCTextObjectView *duplicateTextObjectView = [[SCTextObjectView alloc] initWithDuplicateTextObjectView:(SCTextObjectView*)textObjectView];
    
    duplicateTextObjectView.delegate = self;
    
    if (((SCTextObjectView*)textObjectView).isFirstInit) {
        duplicateTextObjectView.isFirstInit = YES;
    } else {
        duplicateTextObjectView.isFirstInit = NO;
        [self.slideCompostion.texts addObject:duplicateTextObjectView];
        if([self.delegate respondsToSelector:@selector(didFinishEditingText:)])
        {
            self.slideCompostion.needToUpdate = YES;
            [self.delegate didFinishEditingText:self.slideCompostion];
        }
    }
    
    self.currentTextObjectView = duplicateTextObjectView;
    
    [self.textAreaView addSubview:duplicateTextObjectView];
    [self.textAreaView bringSubviewToFront:self.currentTextObjectView];
    
    self.totalTextObjectViewOnScreen++;
     */
}

- (void)onEditTextObjectView:(id)textObjectView {
    
    [self hideContextMenu];
    [self hidePasteMenu];
    
    [self hideInputText];
    
    self.currentTextObjectView = (SCTextObjectView*)textObjectView;
    
    [self updateChooseFontBtn];
    [self updateChoosenColor];
    [self updateChoosenAngelRotation];
    
    if([self.delegate respondsToSelector:@selector(startToEditText)])
    {
        /*
        if (self.currentTextObjectView.isFirstInit) {
            self.currentTextInputMode = SCTextInputModeNew;
            self.inputTf.text         = @"";
        } else {
            self.currentTextInputMode = SCTextInputModeEdit;
            self.inputTf.text         = self.currentTextObjectView.textComposition.model.text;
        }*/
        [self.delegate startToEditText];
    }
}


- (void)didEndDragTextObject:(id)textObjectView
{
    [self hideContextMenu];
    [self hidePasteMenu];
    
    if([self.delegate respondsToSelector:@selector(didFinishEditingText:)])
    {
        self.slideCompostion.needToUpdate = YES;
        [self.delegate didFinishEditingText:self.slideCompostion];
    }
}

- (void)draggingTextObject:(id)textObjectView {
    [self hideContextMenu];
    [self hidePasteMenu];
}

#pragma mark - actions

// on Done button pressed from keyboard, if it is init or modeNew => add to array as the first time.
- (IBAction)onDoneBtn:(id)sender {
 
    /*
    if ([SCTextUtil isEmptyString:self.inputTf.text]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"The text cannot be empty." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
        
    }
     */

    [self updateTextObjectViewWithText:self.inputTf.text];
    [self hideInputText];
    
    [self updateChooseFontBtn];
    [self updateChoosenColor];
    [self updateChoosenAngelRotation];
}

- (void)onDoneWithDefaultReturnKey {
    
    if (self.slideCompostion.texts.count == 0) {
        [self clearAllTextOnScreen];
    }
    
    [self hideInputText];
    [self hideTextToolsWhenDeleteInstant];
}

// update text while typing, not add to array
- (void)onDoneInstant:(NSString*)textUpdated {
    
    if ([SCTextUtil isEmptyString:textUpdated]) {
        
        textUpdated = SC_MESSAGE_DOUBLE_ENTER_TEXT;
        self.currentTextObjectView.isFirstInit = YES;
        
        self.currentTextObjectView.textComposition.model.text = textUpdated;
        [self.currentTextObjectView update];
        
        return;
    }
    
    [self updateTextObjectViewWithText:textUpdated];
    
}

- (void)updateTextObjectViewWithText:(NSString*)text {
    
    self.currentTextObjectView.textComposition.model.text = text;
    [self.currentTextObjectView update];
    
    if (self.currentTextInputMode == SCTextInputModeNew) {
        
        self.currentTextObjectView.isFirstInit = NO;
        [self.slideCompostion.texts addObject:self.currentTextObjectView];
        
        self.currentTextInputMode = SCTextInputModeEdit;
        
    }
    
}

- (void)hideTextToolsWhenDeleteInstant {
    [self.inputTf resignFirstResponder];
    self.inpuTextHolderView.hidden = YES;
    
    if (self.isShowFontView) {
        [self hideFontView];
        return;
    }
    
    if([self.delegate respondsToSelector:@selector(didFinishEditingText:)])
    {
        self.slideCompostion.needToUpdate = YES;
        [self.delegate didFinishEditingText:self.slideCompostion];
    }
    
    //remove from super view
    [self moveDownWithCompletion:^
     {
         [self removeFromSuperview];
     }];
}

- (void)hideInputText {
    [self.inputTf resignFirstResponder];
    
    self.inpuTextHolderView.hidden = YES;
    
    [self updateChooseFontBtn];
    //remove from super view
    /*
    [self zoomOutWithCompletion:^
     {
         
         [self removeFromSuperview];
     }];
     */
}


#pragma mark - Font View

#pragma mark - Font View show/hide animation
- (void)loadFontView {
    self.fontView.frame = CGRectMake(0,
                                     self.frame.size.height,
                                     self.fontView.frame.size.width,
                                     self.fontView.frame.size.height);
    [self addSubview:self.fontView];
    
    // Get list of all fonts
    self.fontNamesArray = [[NSMutableArray alloc] init];
    NSArray *fontFamilyNames = [UIFont familyNames];
    for (NSString *familyName in fontFamilyNames)
    {
        NSArray *names = [UIFont fontNamesForFamilyName:familyName];
        [self.fontNamesArray addObjectsFromArray:names];
    }
    
    [self.fontNamesArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.fontTableView reloadData];
}

- (void)focusOnChoosenFont {
    
    int fontIndex = 0;
    for (int i=0; i < self.fontNamesArray.count; i++) {
        NSString *fontName = (NSString*)[self.fontNamesArray objectAtIndex:i];
        if ([self.currentTextObjectView.textComposition.model.fontName isEqualToString:fontName]) {
            fontIndex = i;
            break;
        }
    }
    
    [self.fontTableView setContentOffset:CGPointMake(0, fontIndex * 44) // 44: is row height of font cell
                                animated:YES];
}

- (void)showFontView {
    if (self.isShowFontView) {
        return;
    }
    
    self.fontView.frame = CGRectMake(0, self.frame.size.height, self.fontView.frame.size.width, self.fontView.frame.size.height);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.fontView.frame = CGRectMake(0,
                                                          self.frame.size.height - self.fontView.frame.size.height,
                                                          self.fontView.frame.size.width,
                                                          self.fontView.frame.size.height);
                         [self focusOnChoosenFont];
                     }
                     completion:^(BOOL finished){
                         self.isShowFontView = YES;
                     }];
}

- (void)hideFontView {
    if (!self.isShowFontView) {
        return;
    }

    [UIView animateWithDuration:0.3
                     animations:^{
                         self.fontView.frame = CGRectMake(0,
                                                          self.frame.size.height,
                                                          self.fontView.frame.size.width,
                                                          self.fontView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         self.isShowFontView = NO;
                     }];
}

#pragma mark - Font list table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fontNamesArray.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"MyIdentifier";
    MyIdentifier = @"kSCFontCellIdentifier";
    
    SCFontCell *cell = (SCFontCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SCFontCell" owner:self options:nil];
        cell = self.fontCell;
    }
    
    cell.fontNameLb.text = (NSString*)[self.fontNamesArray objectAtIndex:indexPath.row];
    if ([UIFont fontWithName:cell.fontNameLb.text size:16]) {
        cell.fontNameLb.font = [UIFont fontWithName:cell.fontNameLb.text size:16];
    } else {
        cell.fontNameLb.font = [UIFont systemFontOfSize:16];
    }
    
    
    if ([cell.fontNameLb.text isEqualToString:self.currentTextObjectView.textComposition.model.fontName]) {
        cell.checkMarkImg.hidden = NO;
    } else {
        cell.checkMarkImg.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // edit
    self.currentTextObjectView.textComposition.model.fontName = (NSString*)[self.fontNamesArray objectAtIndex:indexPath.row];
    [self.currentTextObjectView update];
    
    [self updateChooseFontBtn];
    [self.fontTableView reloadData];
}

#pragma mark - Choose Font Button
- (void)updateChoosenColor {
    int i = self.currentTextObjectView.textComposition.model.indexColorPickerText - 3;
    if (i < 0) {
        i = SC_TOTAL_COLOR_PICKER_TEXT + i;
    }
    [self.colorGridView jumpToIndex:i];
}

- (void)updateChoosenAngelRotation {
    self.numberOfDegreeLb.text = [NSString stringWithFormat:@"%d", self.currentTextObjectView.textComposition.model.angle];
}

- (void)updateChooseFontBtn {
    [self.chooseFontBtn setTitle:self.currentTextObjectView.textComposition.model.fontName
                        forState:UIControlStateNormal];
    self.chooseFontBtn.titleLabel.font = [UIFont fontWithName:self.currentTextObjectView.textComposition.model.fontName
                                                         size:16.0];
}

#pragma mark - Actions on Editor tools
- (void)startHoldTimer {
    if (!self.holdTimer.isValid) {
        self.holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                          target:self
                                                        selector:@selector(holdTimerTick:)
                                                        userInfo:nil
                                                         repeats:YES];
    }
}

- (void)stopHoldTimer {
    if(self.holdTimer.isValid)
    {
        [self.holdTimer invalidate];
        self.holdTimer = nil;
    }
}

- (void)holdTimerTick:(NSTimer*)dt {
    [self doEditWithTool:self.currentToolHoldOn];
}

- (IBAction)onHoldEditorToolBtns:(id)sender {
    self.currentToolHoldOn = ((UIButton*)sender).tag;
    [self startHoldTimer];
}

- (IBAction)onCancelEditorToolBtns:(id)sender {
    [self stopHoldTimer];
}

- (IBAction)onEditorToolBtns:(id)sender {
    
    [self stopHoldTimer];
    
    UIButton *button = (UIButton*)sender;
    [self doEditWithTool:button.tag];
    
}

- (BOOL)checkAllowEdit {
    // check valid
    /*
    if ((self.currentTextObjectView.frame.size.width >= (SC_IS_IPHONE5?SC_TEXT_EDIT_VIEW_SIZE_IPHONE5.width:SC_TEXT_EDIT_VIEW_SIZE_IPHONE4.width))
        || (self.currentTextObjectView.frame.size.height >= (SC_IS_IPHONE5?SC_TEXT_EDIT_VIEW_SIZE_IPHONE5.height-6:SC_TEXT_EDIT_VIEW_SIZE_IPHONE4.height-6)))
    {
        return NO;
    }
     */
//    if (self.currentTextObjectView.frame.size.height >= (SC_IS_IPHONE5?SC_TEXT_EDIT_VIEW_SIZE_IPHONE5.height-6:SC_TEXT_EDIT_VIEW_SIZE_IPHONE4.height-6))
//    {
//        return NO;
//    }
//    
//    return YES;
    
    
    CGSize sizeWithText = [SCTextUtil sizeWithAttributedText:self.currentTextObjectView.textComposition.model.text
                                                        size:self.currentTextObjectView.textComposition.model.fontSize
                                                        font:self.currentTextObjectView.textComposition.model.fontName
                                                 lineSpacing:self.currentTextObjectView.textComposition.model.lineSpacing
                                            characterSpacing:self.currentTextObjectView.textComposition.model.characterSpacing];
    float textObjectViewWidth = sizeWithText.width + SC_TEXT_HOLDER_VIEW_MARGIN*2 + SC_TEXT_LABEL_MARGIN*2;
    float textObjectViewHeight = sizeWithText.height + SC_TEXT_HOLDER_VIEW_MARGIN*2 + SC_TEXT_LABEL_MARGIN*2;
    
    if ((textObjectViewWidth >= (SC_IS_IPHONE5?SC_TEXT_EDIT_VIEW_SIZE_IPHONE5.width:SC_TEXT_EDIT_VIEW_SIZE_IPHONE4.width))
        || (textObjectViewHeight >= (SC_IS_IPHONE5?SC_TEXT_EDIT_VIEW_SIZE_IPHONE5.height:SC_TEXT_EDIT_VIEW_SIZE_IPHONE4.height)))
    {
        return NO;
    }
    
    return YES;
    
}

- (void)doEditWithTool:(SCTextTool)tool {
    
    switch (tool) {
        case SCTextToolDecreaseOpacity:
            [self doDecreaseOpacity];
            break;
        case SCTextToolIncreaseOpacity:
            [self doIncreaseOpacity];
            break;
        case SCTextToolDecreaseAngle:
            [self doDecreaseAngle];
            break;
        case SCTextToolIncreaseAngle:
            [self doIncreaseAngle];
            break;
        case SCTextToolDecreaseLineSpacing:
            [self doDecreaseLineSpacing];
            break;
        case SCTextToolIncreaseLineSpacing:
            [self doIncreaseLineSpacing];
            break;
        case SCTextToolDecreaseSize:
            [self doDecreaseSize];
            break;
        case SCTextToolIncreaseSize:
            [self doIncreaseSize];
            break;
        case SCTextToolAlignLeft:
            [self doAlignLeft];
            break;
        case SCTextToolAlignCenter:
            [self doAlignCenter];
            break;
        case SCTextToolAlignRight:
            [self doAlignRight];
            break;
        case SCTextToolDecreaseCharacterSpacing:
            [self doDecreaseCharacterSpacing];
            break;
        case SCTextToolIncreaseCharacterSpacing:
            [self doIncreaseCharacterSpacing];
            break;
        default:
            break;
    }
    
}


- (void)doDecreaseOpacity {
    if (self.currentTextObjectView.textComposition.model.opacity <= 0.1) {
        return;
    }
    
    self.currentTextObjectView.textComposition.model.opacity -= 0.1;
    [self.currentTextObjectView update];
}

- (void)doIncreaseOpacity {
    if (self.currentTextObjectView.textComposition.model.opacity >= 1.0) {
        return;
    }
    
    self.currentTextObjectView.textComposition.model.opacity += 0.1;
    [self.currentTextObjectView update];
}

- (void)doDecreaseAngle {
    if (self.currentTextObjectView.textComposition.model.angle <= -180) {
        return;
    }
    self.currentTextObjectView.textComposition.model.angle--;
    
    self.numberOfDegreeLb.text = [NSString stringWithFormat:@"%d", self.currentTextObjectView.textComposition.model.angle];
    
//    [self.currentTextObjectView updateRotation];
    [self.currentTextObjectView update];
}

- (void)doIncreaseAngle {
    
    if (self.currentTextObjectView.textComposition.model.angle >= 180) {
        return;
    }
    
    self.currentTextObjectView.textComposition.model.angle++;
    
    self.numberOfDegreeLb.text = [NSString stringWithFormat:@"%d", self.currentTextObjectView.textComposition.model.angle];
//    [self.currentTextObjectView updateRotation];
    [self.currentTextObjectView update];
}

- (void)doDecreaseLineSpacing {
    if (self.currentTextObjectView.textComposition.model.lineSpacing <= 0) {
        return;
    }
    
    self.currentTextObjectView.textComposition.model.lineSpacing--;
    [self.currentTextObjectView update];
}

- (void)doIncreaseLineSpacing {
    
    
    
    self.currentTextObjectView.textComposition.model.lineSpacing++;
    
    if (![self checkAllowEdit]) {
        self.currentTextObjectView.textComposition.model.lineSpacing--;
        return;
    }
    
    [self.currentTextObjectView update];
}

- (void)doDecreaseSize {
    // limit 10px minumum
    if (self.currentTextObjectView.textComposition.model.fontSize < 10)
        return;
    
    self.currentTextObjectView.textComposition.model.fontSize--;
    [self.currentTextObjectView update];
}

- (void)doIncreaseSize {
    
    
    
    // no limit
    self.currentTextObjectView.textComposition.model.fontSize++;
    
    if (![self checkAllowEdit]) {
        self.currentTextObjectView.textComposition.model.fontSize--;
        return;
    }
    
    [self.currentTextObjectView update];
}

- (void)doDecreaseCharacterSpacing {
    if (self.currentTextObjectView.textComposition.model.characterSpacing <= 0) {
        return;
    }
    
    self.currentTextObjectView.textComposition.model.characterSpacing--;
    [self.currentTextObjectView update];
}

- (void)doIncreaseCharacterSpacing {
    
    
    
    self.currentTextObjectView.textComposition.model.characterSpacing++;
    
    if (![self checkAllowEdit]) {
        self.currentTextObjectView.textComposition.model.characterSpacing--;
        return;
    }
    
    [self.currentTextObjectView update];
}

- (void)doAlignLeft {
    self.currentTextObjectView.textComposition.model.txtAlignment = SCEnumTextAlignmentLeft;
    [self.currentTextObjectView update];
}

- (void)doAlignCenter {
    self.currentTextObjectView.textComposition.model.txtAlignment = SCEnumTextAlignmentCenter;
    [self.currentTextObjectView update];
}

- (void)doAlignRight {
    self.currentTextObjectView.textComposition.model.txtAlignment = SCEnumTextAlignmentRight;
    [self.currentTextObjectView update];
}

#pragma mark - Functions for playing
// for playing
- (void)beginEditingWithSlideComposition:(SCSlideComposition*)slideCompostion keyBoardAppear:(BOOL)appear
{
    
    for (SCTextObjectView *textObject in slideCompostion.texts) {
        textObject.delegate = self;
    }
    
    self.canPasteTextObjectView = YES;
    
    self.slideCompostion = slideCompostion;
    [self clearAllTextOnScreen];
    if (slideCompostion.texts.count == 0) {
       SCTextObjectView *newTextObjectView = [self loadFirstTextObjectViewFromContextMenu];
        if(appear)
        {
            [self onBeginInputText:newTextObjectView];
        }
    } else {
        
        /*for (int i = 0; i < slideCompostion.texts.count; i++) {
            
            SCTextObjectView *textObjectView = (SCTextObjectView*)[slideCompostion.texts objectAtIndex:i];
            //textObjectView.canEdit = YES;
            textObjectView.delegate = self;
            //[textObjectView addEditStatus];
            [self.textAreaView addSubview:textObjectView];
            self.totalTextObjectViewOnScreen++;
            
            [textObjectView update];
            [textObjectView addEditStatus];
        }*/
        
        for (SCTextObjectView *textObjectView in slideCompostion.texts) {
            
            [textObjectView addEditStatus];
            [self.textAreaView addSubview:textObjectView];
            [textObjectView update];
        }
        
        if(appear)
        {
            SCTextObjectView *newTextObjectView = [self loadFirstTextObjectViewFromContextMenu];
            [self onBeginInputText:newTextObjectView];
        }
    }    
}

- (void)updateTextWhenPlaying:(SCSlideComposition*)slideCompostion {

    [self clearAllTextOnScreen];
    
    for (SCTextObjectView *textObjectView in slideCompostion.texts) {
        
        [textObjectView removeEditStatus];
        [self.textAreaView addSubview:textObjectView];
    }
}

- (void)clearAllTextOnScreen {
    NSArray *viewsToRemove = [self.textAreaView subviews];
    for (SCTextObjectView *v in viewsToRemove)
    {
        if ([v isKindOfClass:[SCTextObjectView class]]) {
            [v removeFromSuperview];
        }
    }
    
    [self hidePasteMenu];
}

- (void)showAllTextWithoutBorderWith:(SCSlideComposition *)slideCompostion
{
    [self clearAllTextOnScreen];
    self.slideCompostion = slideCompostion;
    
    for (SCTextObjectView *textObjectView in slideCompostion.texts) {
        
        [self.textAreaView addSubview:textObjectView];
        [textObjectView update];
        [textObjectView removeEditStatus];
    }
    [self hidePasteMenu];
}

- (IBAction)saveTextImage:(id)sender {
    UIImageWriteToSavedPhotosAlbum(
                                   [SCImageUtil imageTextWithSlideComposition:self.slideCompostion previewSize:(SC_IS_IPHONE5?SC_PREVIEW_4INCH_SIZE:SC_PREVIEW_3INCH5_SIZE)], nil, nil, nil);
}

#pragma mark - Context menu
- (IBAction)onCopyBtn:(id)sender {
    
    [self hideContextMenu];
    [self hidePasteMenu];
    
    [SCSlideShowSettingManager getInstance].clipboardTextObjectView = [[SCTextObjectView alloc] initWithClipboardTextObjectView:self.contextTextObjectView];
}

- (IBAction)onDuplicateBtn:(id)sender {
    
    [self hideContextMenu];
    [self hidePasteMenu];
    
    SCTextObjectView *duplicateTextObjectView = [[SCTextObjectView alloc] initWithDuplicateTextObjectView:self.contextTextObjectView];
    
    duplicateTextObjectView.delegate = self;
    
    if (self.contextTextObjectView.isFirstInit) {
        duplicateTextObjectView.isFirstInit = YES;
    } else {
        duplicateTextObjectView.isFirstInit = NO;
        [self.slideCompostion.texts addObject:duplicateTextObjectView];
        if([self.delegate respondsToSelector:@selector(didFinishEditingText:)])
        {
            self.slideCompostion.needToUpdate = YES;
            [self.delegate didFinishEditingText:self.slideCompostion];
        }
    }
    
    self.currentTextObjectView = duplicateTextObjectView;
    
    [self.textAreaView addSubview:duplicateTextObjectView];
    [self.textAreaView bringSubviewToFront:self.currentTextObjectView];
    
    self.totalTextObjectViewOnScreen++;
}

- (IBAction)onCloseContextMenuBtn:(id)sender {
    
    // disable paste
    return;
    
    [self hideContextMenu];
    [self hidePasteMenu];
}

- (IBAction)onPasteBtn:(id)sender {
    
    // disable paste
    return;
    
    if([self.delegate respondsToSelector:@selector(didPasteTextObjectFromClipboard)])
    {
         [self.delegate didPasteTextObjectFromClipboard];
    }
}

- (void)pasteTextIntoSlideComposition:(SCSlideComposition*)slideComposition
{
    
    // disable paste
    return;
    
    self.slideCompostion = slideComposition;
    [self hideContextMenu];
    [self hidePasteMenu];
    
    /*
    [SCSlideShowSettingManager getInstance].clipboardTextObjectView.frame = CGRectMake(self.pointToPaste.x,
                                                                                       self.pointToPaste.y,
                                                                                       [SCSlideShowSettingManager getInstance].clipboardTextObjectView.frame.size.width,
                                                                                       [SCSlideShowSettingManager getInstance].clipboardTextObjectView.frame.size.height);
    
    [SCSlideShowSettingManager getInstance].clipboardTextObjectView.textComposition.model.position
    = SCVectorMake([SCSlideShowSettingManager getInstance].clipboardTextObjectView.frame.origin.x,
                   [SCSlideShowSettingManager getInstance].clipboardTextObjectView.frame.origin.y);
    
    [SCSlideShowSettingManager getInstance].clipboardTextObjectView.textComposition.model.center
    = SCVectorMake([SCSlideShowSettingManager getInstance].clipboardTextObjectView.frame.origin.x
                   + [SCSlideShowSettingManager getInstance].clipboardTextObjectView.frame.size.width/2,
                   [SCSlideShowSettingManager getInstance].clipboardTextObjectView.frame.origin.y
                   + [SCSlideShowSettingManager getInstance].clipboardTextObjectView.frame.size.height/2);
    */
    SCTextObjectView *pasteTextObjectView = [[SCTextObjectView alloc] initWithClipboardTextObjectView:[SCSlideShowSettingManager getInstance].clipboardTextObjectView];
    
    pasteTextObjectView.delegate = self;
    
    [self.slideCompostion.texts addObject:pasteTextObjectView];
    
    self.currentTextObjectView = pasteTextObjectView;
    
    [self.textAreaView addSubview:pasteTextObjectView];
    
    [self.textAreaView bringSubviewToFront:self.currentTextObjectView];
    
    self.totalTextObjectViewOnScreen++;
    
    [self updateChooseFontBtn];
    [self updateChoosenColor];
    [self updateChoosenAngelRotation];
    
    if([self.delegate respondsToSelector:@selector(didFinishEditingText:)])
    {
        self.slideCompostion.needToUpdate = YES;
        [self.delegate didFinishEditingText:self.slideCompostion];
    }

}

- (void)showContextMenu {

    // disable paste
    return;
    
    [self hidePasteMenu];
    
    float x = (self.contextTextObjectView.frame.origin.x + self.contextTextObjectView.frame.size.width) - self.contextMenuView.frame.size.width;
    if (x < 0) {
        x = self.contextTextObjectView.frame.origin.x;
    }
    
    float y = self.contextTextObjectView.frame.origin.y - self.contextMenuView.frame.size.height - 4;
    if (y < 0) {
        y = self.contextTextObjectView.frame.origin.y;;
    }
    
    [self.textAreaView bringSubviewToFront:self.contextMenuView];
    
    self.contextMenuView.frame = CGRectMake(x, y, self.contextMenuView.frame.size.width, self.contextMenuView.frame.size.height);
    self.contextMenuView.alpha = 0;
    self.contextMenuView.hidden = NO;

    [UIView animateWithDuration:0.2
                     animations:^{
                         self.contextMenuView.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)hideContextMenu {

    // disable paste
    return;
    
    self.contextMenuView.alpha = 1;

    [UIView animateWithDuration:0.2
                     animations:^{
                         self.contextMenuView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         self.contextMenuView.hidden = YES;
                     }];
}

- (void)showPasteMenuAtPoint:(CGPoint)point {
    
    // disable paste
    return;
    
    [self hideContextMenu];
    
    if (![SCSlideShowSettingManager getInstance].clipboardTextObjectView) {
        return;
    }
    
    // check is playing
    if (!self.canPasteTextObjectView) {
        return;
    }
    
    
    [self.textAreaView bringSubviewToFront:self.pasteMenuView];
    
    float x = point.x;
    float y = point.y;

    if ((self.textAreaView.frame.size.width - x) < self.pasteMenuView.frame.size.width) {
        x = self.textAreaView.frame.size.width - self.pasteMenuView.frame.size.width;
    }
    
    if ((self.textAreaView.frame.size.height - y) < self.pasteMenuView.frame.size.height) {
        y = self.textAreaView.frame.size.height - self.pasteMenuView.frame.size.height;
    }
    
    self.pointToPaste = CGPointMake(x, y);
    
    self.pasteMenuView.frame = CGRectMake(self.pointToPaste.x, self.pointToPaste.y, self.pasteMenuView.frame.size.width, self.pasteMenuView.frame.size.height);
    self.pasteMenuView.alpha = 0;
    self.pasteMenuView.hidden = NO;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.pasteMenuView.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)hidePasteMenu {

    // disable paste
    return;
    
    self.pasteMenuView.alpha = 1;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.pasteMenuView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         self.pasteMenuView.hidden = YES;
                     }];
}

#pragma mark - Color Grid View

#define kNumberLabelTag 9999
- (UIView *)infiniteGridView:(IAInfiniteGridView *)gridView forIndex:(NSInteger)gridIndex {
    
    UIView *grid = [self.colorGridView dequeueReusableGrid];
	
	CGFloat gridWidth = [self infiniteGridView:gridView widthForIndex:gridIndex];
	CGRect frame = CGRectMake(0.0, 0.0, gridWidth, gridView.bounds.size.height);
	
//    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(150 + i*40, 0, 40, 40)];
//    colorView.backgroundColor = [SCHelper colorFromSCColor:[SCTextUtil colorPickerText:i]];
    
	UIView *colorView;
    if (grid == nil) {
		grid = [[UIView alloc] initWithFrame:frame];
        
        UIView *colorView = [[UIView alloc] initWithFrame:frame];
        /*
        numberLabel = [[UILabel alloc] initWithFrame:frame];
        [numberLabel setBackgroundColor:[UIColor clearColor]];
        [numberLabel setTextColor:[UIColor whiteColor]];
		[numberLabel setFont:[UIFont boldSystemFontOfSize:(gridView.bounds.size.height * .4)]];
        [numberLabel setTextAlignment:NSTextAlignmentCenter];
        [numberLabel setTag:kNumberLabelTag];
         */
        
        colorView.tag = kNumberLabelTag;
        [grid addSubview:colorView];
        
    } else {
		grid.frame = frame;
        colorView = (UIView*)[grid viewWithTag:kNumberLabelTag];
		//numberLabel = (UILabel *)[grid viewWithTag:kNumberLabelTag];
		//numberLabel.frame = frame;
        colorView.frame = frame;
	}
    
    // set properties
    NSInteger mods = gridIndex % [self numberOfGridsInInfiniteGridView:gridView];
    if (mods < 0) mods += [self numberOfGridsInInfiniteGridView:gridView];
    CGFloat red = mods * (1 / (CGFloat)[self numberOfGridsInInfiniteGridView:gridView]);
    //grid.backgroundColor = [UIColor colorWithRed:red green:0.0 blue:0.0 alpha:1.0];
    
    grid.backgroundColor = [SCHelper colorFromSCColor:[SCTextUtil colorPickerText:gridIndex]];
    
    // set text
    //[numberLabel setText:[NSString stringWithFormat:@"[%d]", gridIndex]];
    colorView.backgroundColor = [SCHelper colorFromSCColor:[SCTextUtil colorPickerText:gridIndex]];
    
    return grid;
}

- (NSUInteger)numberOfGridsInInfiniteGridView:(IAInfiniteGridView *)gridView {
	return SC_TOTAL_COLOR_PICKER_TEXT;
}

- (CGFloat)infiniteGridView:(IAInfiniteGridView *)gridView widthForIndex:(NSInteger)gridIndex {

    return 40.0;
}

- (void)infiniteGridView:(IAInfiniteGridView *)gridView didSelectGridAtIndex:(NSInteger)gridIndex {
	NSLog(@"grid index : %d", gridIndex);
    [self applyTextColor:gridIndex];
    int i = gridIndex - 3;
    if (i < 0) {
        i = SC_TOTAL_COLOR_PICKER_TEXT + i;
    }
    [self.colorGridView jumpToIndex:i];
}

- (void)infiniteGridView:(IAInfiniteGridView *)gridView didScrollToPage:(NSInteger)pageIndex {
    NSLog(@"scroll to page : %d", pageIndex);
    [self applyTextColor:pageIndex];
}

- (void)applyTextColor:(int)index {
    self.currentTextObjectView.textComposition.model.color = [SCTextUtil colorPickerText:index];
    self.currentTextObjectView.textComposition.model.indexColorPickerText = index;
    [self.currentTextObjectView update];
}

@end
