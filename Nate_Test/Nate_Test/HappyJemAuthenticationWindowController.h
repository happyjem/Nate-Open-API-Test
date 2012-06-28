//
//  HappyJemAuthenticationWindowController.h
//  Nate_Test
//
//  Created by Hi Hwang on 12. 6. 27..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface HappyJemAuthenticationWindowController : NSWindowController
{
    IBOutlet WebView  *webView;
    
}

@property (nonatomic, strong) WebView  *webView;

@end
