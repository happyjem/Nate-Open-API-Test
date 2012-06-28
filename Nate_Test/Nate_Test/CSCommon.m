//
//  CSCommon.m
//  CairnStory
//  www.cairnstory.com
//
//  Created by saturna on 11. 3. 22..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CSCommon.h"
//#import <MobileCoreServices/MobileCoreServices.h>


@implementation CSCommon



+ (NSMutableDictionary*)parseQueryString:(NSString*)queryString
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    NSArray* pairs = [queryString componentsSeparatedByString:@"&"];

    for (NSString* pair in pairs)
	{
        NSArray* elements = [pair componentsSeparatedByString:@"="];
        NSString* key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString* val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        [dict setObject:val forKey:key];
    }
    return dict;
}


+ (NSString*)formatDate:(NSDate*)date style:(NSString*)formatStyle
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:formatStyle];
	return [df stringFromDate:date];
}

+ (NSString*)formatDateSince1970:(double)since1970 style:(NSString*)formatStyle
{
	NSDate *aDate = [NSDate dateWithTimeIntervalSince1970:since1970];
	return [self formatDate:aDate style:formatStyle];
}

@end





#pragma mark -


NSString* CurrentLanguage()
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSArray* languages = [userDefaults objectForKey:@"AppleLanguages"];
	return [languages objectAtIndex:0];
}

NSString* GetMimeType(NSString* fileName)
{
	CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
															(__bridge CFStringRef)[fileName pathExtension],
															NULL);
	CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
	CFRelease(UTI);
	if (MIMEType == nil)
	{
		//NSString* extension = [[fileName pathExtension] lowercaseString];
		// user defined mime type
		// caf, kml, kmz....
		return @"application/octet-stream";
	}

	return (__bridge NSString *)MIMEType;
}

BOOL EmptyString(NSString* value)
{
	return value == nil || [value isKindOfClass:[NSNull class]] || [value isEqualToString:@""];
}


NSString* Trim(NSString* value)
{
	return [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

