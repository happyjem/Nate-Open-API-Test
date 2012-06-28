//
//  HappyJemProfileViewController.m
//  Nate_Test
//
//  Created by Hi Hwang on 12. 6. 27..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "HappyJemProfileViewController.h"
#import "HappyJemAppDelegate.h"


@interface HappyJemProfileViewController ()

@end

@implementation HappyJemProfileViewController

@synthesize nameField, birthday, mailAddress, nickName, profileImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}

- (IBAction)doGoUploadPhotoPage:(id)sender
{
    HappyJemUploadPhotoViewController *uploadView =  [[HappyJemUploadPhotoViewController alloc] initWithNibName:@"HappyJemUploadPhotoViewController" bundle:[NSBundle mainBundle]];
    [((HappyJemAppDelegate*)[[NSApplication sharedApplication] delegate]).navView pushViewController:uploadView];
}

@end
