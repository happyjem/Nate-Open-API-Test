//
//  RSNateEngine.h
//  Nateon_OpenAPI_MACOS
//
//  Created by Hi Hwang on 12. 6. 22..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSOAuthEngine.h"
#import "CSXMLObject.h"

@protocol RSNateEngineDelegate;

typedef void (^RSNateEngineCompletionBlock)(NSError *error);

@interface RSNateEngine : RSOAuthEngine
{
    RSNateEngineCompletionBlock _oAuthCompletionBlock;
    NSString *_screenName;
}

@property (assign) id <RSNateEngineDelegate> delegate;
@property (readonly) NSString *screenName;

- (id)initWithDelegate:(id <RSNateEngineDelegate>)delegate;
- (void)authenticateWithCompletionBlock:(RSNateEngineCompletionBlock)completionBlock;
- (void)resumeAuthenticationFlowWithURL:(NSURL *)url;
- (void)cancelAuthentication;
- (void)forgetStoredToken;
- (void)processLogIn:(NSString *)param withCompletionBlock:(RSNateEngineCompletionBlock)completionBlock;
- (void)sendImage:(NSImage *)image  withCompletionBlock:(RSNateEngineCompletionBlock)completionBlock;
- (void)sendImagePost:(NSString *)imagePath withTitle:(NSString*)title withContents:(NSString*)contents withCompletionBlock:(RSNateEngineCompletionBlock)completionBlock;


@end

@protocol RSNateEngineDelegate <NSObject>

- (void)nateEngine:(RSNateEngine *)engine needsToOpenURL:(NSURL *)url;
- (void)nateEngine:(RSNateEngine *)engine setProfile:(CSXMLObject *)xmlObject;
- (void)nateEngine:(RSNateEngine *)engine afterUploadImageResponseImageURL:(CSXMLObject *)xmlObject;

@end
