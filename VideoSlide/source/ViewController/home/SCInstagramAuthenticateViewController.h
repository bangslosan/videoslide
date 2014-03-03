//
//  SCInstagramAuthenticateViewController.h
//  SlideshowCreator
//
//  Created 11/27/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCInstagramAuthenticateViewControllerDelegate <NSObject>
@optional
- (void)dismissAuthenticatedInstagram;
@end

@interface SCInstagramAuthenticateViewController : SCViewController

@property (nonatomic,weak)   id       <SCInstagramAuthenticateViewControllerDelegate> delegate;
@property (nonatomic,strong) IBOutlet UIWebView *webView;

@end
