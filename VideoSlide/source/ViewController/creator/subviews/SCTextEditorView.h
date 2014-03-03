//
//  SCTextEditorView.h
//  SlideshowCreator
//
//  Created 10/14/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCView.h"

@class SCTextObjectView;

@protocol SCTextEditorViewProtocol <NSObject>

- (void)didFinishEditingText:(SCSlideComposition*)slideComposition;
- (void)startToEditText;
- (void)didPasteTextObjectFromClipboard;
- (void)didEndEditting;

@end

@interface SCTextEditorView : SCView

@property (nonatomic, strong) IBOutlet UIView               *textAreaView;
@property (nonatomic, strong) SCSlideComposition            *slideCompostion;
@property (nonatomic, weak)   id<SCTextEditorViewProtocol>  delegate;

@property (nonatomic, strong) NSMutableArray                *textObjectArray;

// text Area
@property (nonatomic, strong) IBOutlet UIView               *inpuTextHolderView;
@property (nonatomic, strong) IBOutlet UITextField          *inputTf;

@property (nonatomic, strong) IBOutlet UIView               *contextMenuView;
@property (nonatomic, strong) SCTextObjectView              *contextTextObjectView;
@property (nonatomic, strong) IBOutlet UIView               *pasteMenuView;
@property (nonatomic, assign) BOOL                          canPasteTextObjectView;
@property (nonatomic, assign) CGPoint                       pointToPaste;

- (void)showTextsFromSlideComposition:(SCSlideComposition*)slideComposition;
- (void)hide;

// for playing
- (void)beginEditingWithSlideComposition:(SCSlideComposition*)slideCompostion keyBoardAppear:(BOOL)appear;

- (void)updateTextWhenPlaying:(SCSlideComposition*)slideCompostion; //

- (void)clearAllTextOnScreen; //

- (void)pasteTextIntoSlideComposition:(SCSlideComposition*)slideComposition;

- (void)hidePasteMenu;

- (void)showAllTextWithoutBorderWith:(SCSlideComposition*)slideCompostion; 

@end
