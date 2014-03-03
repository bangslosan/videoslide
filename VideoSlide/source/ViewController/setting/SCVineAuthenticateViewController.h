//
//  SCVineAuthenticateViewController.h
//  SlideshowCreator
//
//  Created 12/11/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCVineAuthenticateViewControllerDelegate <NSObject>
@optional
- (void)didVineLoginSuccess;
///- (void)didVineLoginFailed;
@end

@interface SCVineAuthenticateViewController : SCViewController
@property (nonatomic,weak) id <SCVineAuthenticateViewControllerDelegate> delegate;

@end
