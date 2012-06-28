//
//  CSCommon.h
//  CairnStory
//  www.cairnstory.com
//
//  Created by saturna on 11. 3. 22..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kHTTPRequestTimeout 10
#define kMultipartBoundarySuffix @"0xCaIrNsToRyMuTiPaRtBoUnDaRy"

@interface CSCommon : NSObject
{

}


+ (NSMutableDictionary*)parseQueryString:(NSString*)queryString;
+ (NSString*)formatDate:(NSDate*)date style:(NSString*)formatStyle;
+ (NSString*)formatDateSince1970:(double)since1970 style:(NSString*)formatStyle;

@end

NSString* CurrentLanguage();
NSString* GetMimeType(NSString* fileName);
BOOL EmptyString(NSString* value);
NSString* Trim(NSString* value);
