//
//  SCMessageManager.m
//  SlideshowCreator
//
//  Created 10/30/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCMessageManager.h"

@implementation SCMessageManager

- (void)sendiMessage {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = @"I am using VideoRize iPhone app. It is so cool.";
        controller.messageComposeDelegate = self;
        [[SCScreenManager getInstance].rootViewController presentViewController:controller animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You cannot send message at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)sendiMessageWithDataURL:(NSURL*)url {
    
    if ([SCHelper isIOS7]) {
        
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
            NSData *data = [NSData dataWithContentsOfURL:url];
            NSString *filename = [[url absoluteString] lastPathComponent];
            
            controller.body = filename;
            [controller addAttachmentData:data typeIdentifier:(NSString*)kUTTypeQuickTimeMovie filename:filename];
            controller.messageComposeDelegate = self;
            [[SCScreenManager getInstance].rootViewController presentViewController:controller animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You cannot send message at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    } else {
        
        //        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        //        pasteboard.persistent = YES;
        //        NSData *data = [NSData dataWithContentsOfURL:url];
        //        pasteboard.image = [UIImage imageWithData:data];
        
        //        NSString *phoneToCall = @"sms:";
        //        NSString *phoneToCallEncoded = [phoneToCall stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        //        NSURL *url = [[NSURL alloc] initWithString:phoneToCallEncoded];
        //        [[UIApplication sharedApplication] openURL:url];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Share file via Message doesn't support on iOS 6." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled:
            
            break;
        case MessageComposeResultFailed:
            [self sendNotification:SCNotificationMessageSentFailed];
            break;
        case MessageComposeResultSent:
            [SCSocialManager getInstance].numShareMessage++;
            [[SCSocialManager getInstance] saveNumberOfSharing];
            [self sendNotification:SCNotificationMessageDidSent];
            break;
        default:
            break;
    }
    
    [[SCScreenManager getInstance].rootViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
