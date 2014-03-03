//
//  SCBaseManager.h
//  SlideshowCreator
//
//  Created 8/29/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>

 /*Abstract base manager is an abstract class for all single ton class in this app
 *It contain some method to send & receive notification which are used popular in app
 *
 */
@interface SCBaseManager : NSObject
@property (nonatomic,strong) NSString *baseServiceURL;
/**
 *Send notification method to send a notification info to a other view doing st...
 *@Param: notificationName : name of notification
 */
- (void)sendNotification:(NSString *)notificationName;

/**
 *Send notification method to send a notification info to a other view doing st...
 *@Param notificationName : name of notification
 *@Param body             : data to send in notification
 */
- (void)sendNotification:(NSString *)notificationName body:(id)body;

/**
 *Send notification method to send a notification info to a other view doing st...
 *@Param notificationName : name of notification
 *@Param body             : data to send in notification
 *@Param type             : type of notification
 */
- (void)sendNotification:(NSString *)notificationName body:(id)body type:(id)type;

/**
 *list all notification this view can receive
 *return: array of notification
 */
- (NSArray *)listNotificationInterests;

/**
 *lMethod to handle all notification this view receive
 *@Param notification: notification this view recieve
 */
- (void)handleNotification:(NSNotification *)notification;


@end