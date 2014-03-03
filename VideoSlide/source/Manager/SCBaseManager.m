//
//  SCBaseManager.m
//  SlideshowCreator
//
//  Created 8/29/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCBaseManager.h"

@interface SCBaseManager ()

@property(nonatomic) BOOL isNoInternet;

@end

@implementation SCBaseManager
@synthesize baseServiceURL;
- (id)init
{
    self = [super init];
    if(self)
    {
        for ( NSString *notification in [self listNotificationInterests] )
        {
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center addObserver:self selector:@selector(handleNotification:) name:notification object:nil];
        }
    }
    return self;
}



#pragma mark -  class methods
- (void)sendNotification:(NSString *)notificationName
{
	[self sendNotification:notificationName body:nil type:nil];
}


- (void)sendNotification:(NSString *)notificationName body:(id)body
{
	[self sendNotification:notificationName body:body type:nil];
}

- (void)sendNotification:(NSString *)notificationName body:(id)body type:(id)type
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	NSMutableDictionary *dic = nil;
	if (body || type) {
		dic = [[NSMutableDictionary alloc] init];
		if (body) [dic setObject:body forKey:@"body"];
		if (type) [dic setObject:type forKey:@"type"];
	}
	NSNotification *n = [NSNotification notificationWithName:notificationName object:self userInfo:dic];
	[center postNotification:n];
}

#pragma mark - override methods
- (NSArray *)listNotificationInterests
{
    return [NSArray arrayWithObjects:nil];
}

- (void)handleNotification:(NSNotification *)notification
{
    
}


@end
