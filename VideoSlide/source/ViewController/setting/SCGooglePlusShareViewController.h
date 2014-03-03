//
//  SCGooglePlusShareViewController.h
//  SlideshowCreator
//
//  Created 10/31/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCViewController.h"

@protocol SCGooglePlusShareViewControllerDelegate <NSObject>

- (void)postToGooglePlus:(NSString*)text;
- (void)cancelGooglePlus;

@end

@interface SCGooglePlusShareViewController : UIViewController <UITextViewDelegate>

@property (nonatomic,weak) id <SCGooglePlusShareViewControllerDelegate> delegate;
@property (nonatomic,strong) IBOutlet UITextView *statusTextView;

- (IBAction)onCancelBtn:(id)sender;
- (IBAction)onPostBtn:(id)sender;

@end
