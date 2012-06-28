//
//  HappyJemAppDelegate.m
//  Nate_Test
//
//  Created by Hi Hwang on 12. 6. 22..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "HappyJemAppDelegate.h"
#import "HappyJemUploadPhotoViewController.h"

@implementation HappyJemAppDelegate

@synthesize window = _window, nateEngine, navView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
     self.nateEngine = [[RSNateEngine alloc] initWithDelegate:self];
    
    //[self.window setBackgroundColor:[NSColor whiteColor]];
    [mainTitleView setImage:[NSImage imageNamed:@"logo01.png"]];
    [mainTitleView setImageScaling:NSScaleToFit];
    [subTitleView setImage:[NSImage imageNamed:@"logo02.jpg"]];
}


- (IBAction)doTestLogin:(id)sender
{
    [self.nateEngine processLogIn:nil withCompletionBlock:^(NSError *error) {
        if (error) {
        } 
        else {
        }
    }];
}


- (void)nateEngine:(RSNateEngine *)engine needsToOpenURL:(NSURL *)url
{
    if(self.nateEngine.isAuthenticated != true)
    {
        authenticationWindowController = [[HappyJemAuthenticationWindowController alloc] initWithWindowNibName:@"HappyJemAuthenticationWindowController"]; 
        [authenticationWindowController showWindow:self.window];
        [authenticationWindowController.webView setMainFrameURL:[url absoluteString]];
        authenticationWindowController.webView.frameLoadDelegate = self;
    }
}

- (void)nateEngine:(RSNateEngine *)engine setProfile:(CSXMLObject *)xmlObject
{
    HappyJemProfileViewController *profileView = [[HappyJemProfileViewController alloc] initWithNibName:@"HappyJemProfileViewController" bundle:[NSBundle mainBundle]];
    
    //set profile
    NSDictionary* profileDic = [xmlObject subDictionaryWithElementPath:@"/response/body/profile"];
       
    [navView pushViewController:profileView];
    
    [profileView.nameField setStringValue:[[profileDic objectForKey:@"name"] valueForKey:@"#text"]];
    [profileView.nickName setStringValue:[[profileDic objectForKey:@"nickname"] valueForKey:@"#text"]];
    [profileView.mailAddress setStringValue:[[profileDic objectForKey:@"id"] valueForKey:@"#text"]];
    [profileView.birthday setStringValue:[[profileDic objectForKey:@"birthday"] valueForKey:@"#text"]];
   
    //XML에서 받는 URL은 호출시 서버를 한 번 더 거쳐 URL을 HTML로 보낸다. 따라서 파라메터를 파싱에서 새로운 URL을 만든다.
    //지금은 테스트임으로 이 부분은 고정 URL로 처리한다.
    NSString* imageURL = @"http://img.nateon.nate.com/profile/10018286567.jpg";
    NSImage *image = [[NSImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
    [profileView.profileImage setImage:image];         
    
}

- (void)nateEngine:(RSNateEngine *)engine afterUploadImageResponseImageURL:(CSXMLObject *)xmlObject
{
    NSDictionary* uploadInfoDic = [xmlObject subDictionaryWithElementPath:@"/Data/Attach/AttachNm"];
    NSLog(@"%@", navView.currentViewController.description);
    ((HappyJemUploadPhotoViewController*)navView.currentViewController).uploadImageURL = [uploadInfoDic valueForKey:@"#text"];
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    // Only report feedback for the main frame.
    if (frame == [sender mainFrame]){
        NSURL *url = [[[frame provisionalDataSource] request] URL];
        
        NSString* urlPath = [NSString stringWithFormat:@"%@://%@%@",
                             [url scheme], [url host], [url path]];
        
        if([urlPath isEqualToString:self.nateEngine.callbackURL])
        {
            NSLog(@"Success");
            [authenticationWindowController.window close];
            authenticationWindowController = nil;
            [self.nateEngine resumeAuthenticationFlowWithURL:url];
            
        }

    }
}


@end
