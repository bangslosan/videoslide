//
//  SCEmailManager.h
//  SlideshowCreator
//
//  Created 10/30/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCBaseManager.h"

@interface SCEmailManager : SCBaseManager <MFMailComposeViewControllerDelegate>

- (void)sendEmail;

- (void)sendEmailWithDataURL:(NSURL*)url title:(NSString*)title;

@end
