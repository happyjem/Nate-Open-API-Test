//
//  HappyJemUploadPhotoViewController.m
//  Nate_Test
//
//  Created by Hi Hwang on 12. 6. 28..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "HappyJemUploadPhotoViewController.h"
#import "HappyJemAppDelegate.h"

@interface HappyJemUploadPhotoViewController ()

@end

@implementation HappyJemUploadPhotoViewController 

@synthesize title, contents, uploadImageURL = _uploadImageURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)doSelectPicture:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    NSArray *fileTypesArray;
    fileTypesArray = [NSArray arrayWithObjects:@"jpg", @"gif", @"png", nil];
    [openDlg setCanChooseFiles:YES];   
    [openDlg setAllowedFileTypes:fileTypesArray];
    [openDlg setAllowsMultipleSelection:NO];
    if ( [openDlg runModal] == NSOKButton ) 
    {
        NSArray *files = [openDlg URLs];
        NSLog(@"URL is %@", [files description]);
        
        NSImage *uploadImage = [[NSImage alloc] initWithContentsOfURL:[files objectAtIndex:0]];
        
        [previewImage setImageScaling:NSScaleToFit];
        [previewImage setImage:uploadImage];
        
        //Upload Image, After get url
        [((HappyJemAppDelegate*)[[NSApplication sharedApplication] delegate]).nateEngine sendImage:uploadImage withCompletionBlock:^(NSError *error) {
            if (error) {
            } 
            else {
            }
        }];

    }
}

- (IBAction)doUploadPost:(id)sender
{
    NSLog(@"upload image url is %@", self.uploadImageURL);
    
    if (self.uploadImageURL != nil) {
        [((HappyJemAppDelegate*)[[NSApplication sharedApplication] delegate]).nateEngine sendImagePost:self.uploadImageURL withTitle:title.stringValue withContents:contents.stringValue withCompletionBlock:^(NSError *error) {
            if (error) {
            } 
            else {
            }
        }];

    }
  
}

@end
