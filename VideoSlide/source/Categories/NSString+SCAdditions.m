//
//  Created 9/6/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "NSString+SCAdditions.h"

@implementation NSString (SCAdditions)

- (NSString *)stringByMatchingRegex:(NSString *)regex capture:(NSUInteger)capture {
	NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:nil];
	NSTextCheckingResult *result = [expression firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
	if (capture < [result numberOfRanges]) {
		NSRange range = [result rangeAtIndex:capture];
		return [self substringWithRange:range];
	}
	return nil;
}

@end
