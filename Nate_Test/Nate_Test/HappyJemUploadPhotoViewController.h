//
//  HappyJemUploadPhotoViewController.h
//  Nate_Test
//
//  Created by Hi Hwang on 12. 6. 28..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "M3NavigationViewControllerProtocol.h"

@interface HappyJemUploadPhotoViewController : NSViewController <M3NavigationViewControllerProtocol> 
{
    IBOutlet NSTextField *title;
    IBOutlet NSTextField *contents;
    IBOutlet NSImageView *previewImage;
}

@property (nonatomic) IBOutlet NSTextField *title;
@property (nonatomic) IBOutlet NSTextField *contents;
@property (nonatomic) NSString *uploadImageURL;

- (IBAction)doSelectPicture:(id)sender;
- (IBAction)doUploadPost:(id)sender;

@end
