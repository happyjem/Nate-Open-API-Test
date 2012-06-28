//
//  HappyJemProfileViewController.h
//  Nate_Test
//
//  Created by Hi Hwang on 12. 6. 27..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "M3NavigationViewControllerProtocol.h"
#import "HappyJemUploadPhotoViewController.h"

@interface HappyJemProfileViewController : NSViewController <M3NavigationViewControllerProtocol> 
{
    IBOutlet NSImageView *profileImage;
    IBOutlet NSTextField *nameField;
    IBOutlet NSTextField *birthday;
    IBOutlet NSTextField *nickName;
    IBOutlet NSTextField *mailAddress;
}

@property (nonatomic) NSImageView *profileImage;
@property (nonatomic) NSTextField *nameField;
@property (nonatomic) NSTextField *birthday;
@property (nonatomic) NSTextField *nickName;
@property (nonatomic) NSTextField *mailAddress;

- (IBAction)doGoUploadPhotoPage:(id)sender;

@end
