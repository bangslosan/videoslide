//
//  SCMessageManager.h
//  SlideshowCreator
//
//  Created 10/30/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCBaseManager.h"

@interface SCMessageManager : SCBaseManager <MFMessageComposeViewControllerDelegate>

- (void)sendiMessage;
- (void)sendiMessageWithDataURL:(NSURL*)url;

@end
