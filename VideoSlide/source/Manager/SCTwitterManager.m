//
//  SCTwitterManager.m
//  SlideshowCreator
//
//  Created 10/30/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCTwitterManager.h"

@implementation SCTwitterManager

- (void)sendTwitter {
    SLComposeViewController *twController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            [twController dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {

                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    [SCSocialManager getInstance].numShareTwitter++;
                    [[SCSocialManager getInstance] saveNumberOfSharing];
                    [self sendNotification:SCNotificationTwitterDidSent];
                }
                    break;
            }};
        
        [twController setInitialText:@"I am using VideoRize iPhone app. It is so cool."];
        [twController setCompletionHandler:completionHandler];
        
        [[SCScreenManager getInstance].rootViewController presentViewController:twController animated:YES completion:nil];
    }

}

@end
