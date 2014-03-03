//
//  SCSheetMenu.h
//  SlideshowCreator
//
//  Created 10/11/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCSheetMenuDelegate <NSObject>
@optional
- (void)onTapSheetMenuAtIndex:(int)index;
- (void)onTapSheetCancel;
@end

@interface SCSheetMenu : SCView

@property (nonatomic,weak)   id       <SCSheetMenuDelegate> delegate;
@property (nonatomic,assign) BOOL                           isShow;
@property (nonatomic,strong) IBOutlet UIView                *containerView;

- (void)show;
- (void)hide;

- (id)initWithFrame:(CGRect)frame buttons:(NSArray*)buttons cancelButton:(NSString*)cancelButton;
- (id)initWithFrame:(CGRect)frame images:(NSArray*)images buttons:(NSArray*)buttons cancelButton:(NSString*)cancelButton;

- (IBAction)onCancelBtn;

@end
