//
//  HappyJemAppDelegate.h
//  Nate_Test
//
//  Created by Hi Hwang on 12. 6. 22..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "RSNateEngine.h"
#import "HappyJemAuthenticationWindowController.h"
#import "M3NavigationView.h"
#import "HappyJemProfileViewController.h"
#import "HappyJemUploadPhotoViewController.h"

@class RSNateEngineDelegate;
@class RSNateEngine;


@interface HappyJemAppDelegate : NSObject <NSApplicationDelegate, RSNateEngineDelegate>
{
    IBOutlet NSTextField	*textField;
    IBOutlet NSImageView    *mainTitleView;
    IBOutlet NSImageView    *subTitleView;
    IBOutlet M3NavigationView *navView;
    
    HappyJemAuthenticationWindowController *authenticationWindowController;
}

@property (assign) IBOutlet NSWindow *window;
@property (strong, nonatomic) IBOutlet M3NavigationView *navView;
@property (strong, nonatomic) RSNateEngine *nateEngine;

- (IBAction)doTestLogin:(id)sender;
- (IBAction)doUploadImage:(id)sender;
- (IBAction)doUploadImagePost:(id)sender;

@end
