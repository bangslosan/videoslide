//
//  SCFacebookShareViewController.h
//  SlideshowCreator
//
//  Created 10/31/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCViewController.h"

@protocol SCFacebookShareViewControllerDelegate <NSObject>

- (void)postToFacebook:(NSString*)text;
- (void)cancelFacebook;

@end

@interface SCFacebookShareViewController : UIViewController <UITextViewDelegate>

@property (nonatomic,weak) id <SCFacebookShareViewControllerDelegate> delegate;
@property (nonatomic,strong) IBOutlet UITextView *statusTextView;

- (IBAction)onCancelBtn:(id)sender;
- (IBAction)onPostBtn:(id)sender;

@end
