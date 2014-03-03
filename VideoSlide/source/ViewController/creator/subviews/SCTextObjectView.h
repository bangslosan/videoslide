//
//  SCTextObjectView.h
//  SlideshowCreator
//
//  Created 10/16/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCTextComposition;

@protocol SCTextObjectViewDelegate <NSObject>
@optional
- (void)onBeginInputText:(id)textObjectView;
- (void)onDuplicateTextObjectView:(id)textObjectView;
- (void)onDeleteTextObjectView:(id)textObjectView;
- (void)onEditTextObjectView:(id)textObjectView;
- (void)draggingTextObject:(id)textObjectView;
- (void)didEndDragTextObject:(id)textObjectView;

@end

@interface SCTextObjectView : SCView {
    CAShapeLayer *shapeLayer_;
}

@property (nonatomic, weak) id <SCTextObjectViewDelegate>   delegate;
// buttons
@property (nonatomic, strong) IBOutlet UIButton             *duplicateBtn;
@property (nonatomic, strong) IBOutlet UIButton             *editBtn;
@property (nonatomic, strong) IBOutlet UIButton             *deleteBtn;

// UI
@property (nonatomic, strong) IBOutlet UILabel              *textLb;
@property (nonatomic, strong) IBOutlet UIView               *textHolderView;
// logic
@property (nonatomic, strong) SCTextComposition             *textComposition;
@property (nonatomic, assign) BOOL                          isFirstInit;
@property (nonatomic, assign) BOOL                          canEdit;

- (id)initFirstTimeWithFrame:(CGRect)frame;
- (id)initWithDuplicateTextObjectView:(SCTextObjectView*)textObjectView;
- (id)initWithClipboardTextObjectView:(SCTextObjectView*)textObjectView;
- (id)initWithTextComposition:(SCTextComposition*)textComposition;
- (id)initWithTextObjectView:(SCTextObjectView*)textObjectView andScale:(float)scale;

- (void)update;
- (void)updateRotation;
- (void)updateWithScale:(float)scale;

- (void)addEditStatus;
- (void)removeEditStatus;

- (IBAction)onDuplicateBtn;
- (IBAction)onDeleteBtn;
- (IBAction)onEditBtn;

// new
- (id)initTextObjectViewWithFrame:(CGRect)frame;

@end
