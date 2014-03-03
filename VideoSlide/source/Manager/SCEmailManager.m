//
//  SCEmailManager.m
//  SlideshowCreator
//
//  Created 10/30/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCEmailManager.h"

@implementation SCEmailManager

- (void)sendEmail {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:@"VideoRize iPhone app"];
        
        NSArray *toRecipients = [[NSArray alloc] init];
        [mailer setToRecipients:toRecipients];
        
        NSString *emailBody = @"I am using VideoRize iPhone app. It is so cool.";
        [mailer setMessageBody:emailBody isHTML:NO];
        
        [[SCScreenManager getInstance].rootViewController presentViewController:mailer animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"You need to setup an email account on your device Settings before you can send mail!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)sendEmailWithDataURL:(NSURL*)url title:(NSString*)title {
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:title];
        
        NSArray *toRecipients = [[NSArray alloc] init];
        [mailer setToRecipients:toRecipients];
        
        NSString *emailBody = @"";
        [mailer setMessageBody:emailBody isHTML:NO];
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSString *filename = [[url absoluteString] lastPathComponent];
        NSString *mimeType = [SCHelper MIMETypeForFilename:filename defaultMIMEType:@"video/quicktime"];
        
        [mailer addAttachmentData:data mimeType:mimeType fileName:filename];
        
        [[SCScreenManager getInstance].rootViewController presentViewController:mailer animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"You need to setup an email account on your device Settings before you can send mail!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            //NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            [SCSocialManager getInstance].numShareEmail++;
            [[SCSocialManager getInstance] saveNumberOfSharing];
            [self sendNotification:SCNotificationEmailDidSent];
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            [self sendNotification:SCNotificationEmailSentFailed];
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [[SCScreenManager getInstance].rootViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
