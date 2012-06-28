//
//  RSNateEngine.m
//  Nateon_OpenAPI_MACOS
//
//  Created by Hi Hwang on 12. 6. 22..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "RSNateEngine.h"

// Nate OpenAPI consumer key, consuer secret 발급신청
// --> http://devsquare.nate.com/openApi/registerConsumerKey
#define SK_CONSUMER_KEY @"----------------------"
#define SK_CONSUMER_SECRET @"-----------------------"

// callback url은 임의의 url을 사용한다.
// (존재하지 않는 가상 url도 가능)
#define SK_CALLBACK_URL @"http://www.callback.com/nate/callback"

// Default nate hostname and paths
#define SK_HOSTNAME @"oauth.nate.com"
#define SK_REQUEST_TOKEN @"OAuth/GetRequestToken/V1a"
#define SK_ACCESS_TOKEN @"OAuth/GetAccessToken/V1a"

// URL to redirect the user for authentication
#define SK_AUTHORIZE(__TOKEN__) [NSString stringWithFormat:@"https://oauth.nate.com/OAuth/Authorize/V1a?oauth_token=%@", __TOKEN__]

#define SK_NATE_PROFILE @"https://openapi.nate.com/OApi/RestApiSSL/ON/250020/nateon_GetProfile/v1"
#define SK_NATE_UPLOAD_PHOTO_POST @"https://openapi.nate.com/OApi/RestApiSSL/CY/200110/xml_RegisterPhotoItem/v1"
#define SK_NATE_UPLOAD_PHOTO @"http://openapi.nate.com/OApi/CyPhotoRestApi/V1"

@interface RSNateEngine ()

- (void)removeOAuthTokenFromKeychain;
- (void)storeOAuthTokenInKeychain;
- (void)retrieveOAuthTokenFromKeychain;

@end


@implementation RSNateEngine

@synthesize delegate = _delegate, screenName;

#pragma mark - Initialization

- (id)initWithDelegate:(id <RSNateEngineDelegate>)delegate
{
    self = [super initWithHostName:SK_HOSTNAME
                customHeaderFields:nil
                   signatureMethod:RSOAuthHMAC_SHA1
                       consumerKey:SK_CONSUMER_KEY
                    consumerSecret:SK_CONSUMER_SECRET 
                       callbackURL:SK_CALLBACK_URL];
    
    if (self) {
        _oAuthCompletionBlock = nil;
        _screenName = nil;
        self.delegate = delegate;
        
        // Retrieve OAuth access token (if previously stored)
        //[self retrieveOAuthTokenFromKeychain];
    }
    
    return self;
}


#pragma mark - OAuth Authentication Flow

- (void)authenticateWithCompletionBlock:(RSNateEngineCompletionBlock)completionBlock
{
    // Store the Completion Block to call after Authenticated
    _oAuthCompletionBlock = [completionBlock copy];
    
    // First we reset the OAuth token, so we won't send previous tokens in the request
    [self resetOAuthToken];
    
    // OAuth Step 1 - Obtain a request token
    MKNetworkOperation *op = [self operationWithPath:SK_REQUEST_TOKEN
                                              params:nil
                                          httpMethod:@"POST"
                                                 ssl:YES];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation)
     {
         // Fill the request token with the returned data
         [self fillTokenWithResponseBody:[completedOperation responseString] type:RSOAuthRequestToken];
         
         // OAuth Step 2 - Redirect user to authorization page
         //[self.delegate twitterEngine:self statusUpdate:@"Waiting for user authorization..."];
         NSLog(@"Waiting for user authorization...");
         NSURL *url = [NSURL URLWithString:SK_AUTHORIZE(self.token)];
         [self.delegate nateEngine:self needsToOpenURL:url];
     } 
             onError:^(NSError *error)
     {
         completionBlock(error);
         _oAuthCompletionBlock = nil;
     }];
    
    //[self.delegate twitterEngine:self statusUpdate:@"Requesting Tokens..."];
    NSLog(@"Requesting Tokens...");
    [self enqueueSignedOperation:op];
}

- (void)resumeAuthenticationFlowWithURL:(NSURL *)url
{
    // Fill the request token with data returned in the callback URL
    [self fillTokenWithResponseBody:url.query type:RSOAuthRequestToken];
    
    // OAuth Step 3 - Exchange the request token with an access token
    MKNetworkOperation *op = [self operationWithPath:SK_ACCESS_TOKEN
                                              params:nil
                                          httpMethod:@"POST"
                                                 ssl:YES];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation)
     {
         // Fill the access token with the returned data
         [self fillTokenWithResponseBody:[completedOperation responseString] type:RSOAuthAccessToken];
         
         
         // Finished, return to previous method
         if (_oAuthCompletionBlock) _oAuthCompletionBlock(nil);
         _oAuthCompletionBlock = nil;
     } 
             onError:^(NSError *error)
     {
         if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
         _oAuthCompletionBlock = nil;
     }];
    
    [self enqueueSignedOperation:op];
}

- (void)cancelAuthentication
{
    NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Authentication cancelled.", NSLocalizedDescriptionKey, nil];
    NSError *error = [NSError errorWithDomain:@"com.happyjem.RSSKEngine.ErrorDomain" code:401 userInfo:ui];
    
    if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
    _oAuthCompletionBlock = nil;
}


- (void)processLogIn:(NSString *)param withCompletionBlock:(RSNateEngineCompletionBlock)completionBlock
{
   if (!self.isAuthenticated) {
        [self authenticateWithCompletionBlock:^(NSError *error) {
            if (error) {
                // Authentication failed, return the error
                completionBlock(error);
            } else {
                // Authentication succeeded, call this method again
                [self processLogIn:param withCompletionBlock:completionBlock];
            }
        }];
        
        // This method will be called again once the authentication completes
        return;
   }
    
    // Fill the post body with the tweet
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"64902515",@"targetId",
                                       nil];
    
    // If the user marks the option "HTTPS Only" in his/her profile,
    // Twitter will fail all non-auth requests that use only HTTP
    // with a misleading "OAuth error". I guess it's a bug.
    
    
    
    MKNetworkOperation *op = [self operationWithURLString:SK_NATE_PROFILE 
                                                   params:postParams
                                               httpMethod:@"POST"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        
        NSLog(@"Response is %@",op.description);
        
        //Create XML Object
        NSError* xmlError = nil;
        CSXMLObject *xmlObject = [[CSXMLObject alloc] initWithXMLData:op.responseData andError:&xmlError];
        NSDictionary* profileDic = [xmlObject subDictionaryWithElementPath:@"/response/body/profile"];
        
        NSArray* allKey = [profileDic allKeys];
		for (NSString* key in allKey)
		{
            id value = [profileDic objectForKey:key];
			NSLog(@"Key is %@", key);
            NSLog(@"value is %@", [value description]);
		}
        
        [self.delegate nateEngine:self setProfile:xmlObject];
        
        completionBlock(nil);
    } onError:^(NSError *error) {
        completionBlock(error);
    }];
    
    [self enqueueSignedOperation:op];    
    
}

- (void)sendImage:(NSImage *)image withCompletionBlock:(RSNateEngineCompletionBlock)completionBlock
{
    
    if (!self.isAuthenticated) {
        [self authenticateWithCompletionBlock:^(NSError *error) {
            if (error) {
                // Authentication failed, return the error
                completionBlock(error);
            } else {
                // Authentication succeeded, call this method again
                [self sendImage:image withCompletionBlock:completionBlock];
            }
        }];
        
        // This method will be called again once the authentication completes
        return;
    }

    
    // Grab possible representations of this image
    NSArray *representations = [image representations];        
    // Create the PNG data
    NSData *imageData = [NSBitmapImageRep representationOfImageRepsInArray:representations usingType:NSJPEGFileType properties:nil]; 
    
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        @"64902515",@"targetId",@"2",@"folderNo",@"Test is Mac",@"title",@"테스트",@"content",@"allOpen",@"itemOpen",@"/390026/2012/6/24/5/test_upload.jpg",@"photoUrls",@"true",@"isScrapOpen",@"true",@"isSearchOpen",
                                       nil];
    
    
    MKNetworkOperation *op = [self operationWithURLString:SK_NATE_UPLOAD_PHOTO 
                                                   params:postParams
                                               httpMethod:@"POST"];
    
    [op addData:imageData forKey:@"file" mimeType:@"image/jpeg" fileName:@"test_upload.jpg"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        
        NSLog(@"Response is %@",op.description);
        
        //Create XML Object
        NSError* xmlError = nil;
        CSXMLObject *xmlObject = [[CSXMLObject alloc] initWithXMLData:op.responseData andError:&xmlError];
        NSDictionary* uploadInfoDic = [xmlObject subDictionaryWithElementPath:@"/Data/Attach/AttachNm"];
        
        NSArray* allKey = [uploadInfoDic allKeys];
		for (NSString* key in allKey)
		{
            id value = [uploadInfoDic objectForKey:key];
			NSLog(@"Key is %@", key);
            NSLog(@"value is %@", [value description]);
		}
        
        [self.delegate nateEngine:self afterUploadImageResponseImageURL:xmlObject];
        
        completionBlock(nil);
    } onError:^(NSError *error) {
        completionBlock(error);
    }];
    
    [self enqueueSignedOperation:op];    

}

- (void)sendImagePost:(NSString *)imagePath withTitle:(NSString*)title withContents:(NSString*)contents withCompletionBlock:(RSNateEngineCompletionBlock)completionBlock
{
    NSMutableDictionary* postParams = [[NSMutableDictionary alloc] init];
        [postParams setObject:@"1" forKey:@"folderNo"];
        [postParams setObject:title forKey:@"title"];
    	[postParams setObject:contents forKey:@"content"];
    	[postParams setObject:imagePath forKey:@"photoUrls"];
    
    MKNetworkOperation *op = [self operationWithURLString:SK_NATE_UPLOAD_PHOTO_POST 
                                                   params:postParams
                                               httpMethod:@"POST"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        
        NSLog(@"Response is %@",op.description);
        completionBlock(nil);
    } onError:^(NSError *error) {
        completionBlock(error);
    }];
    
    [self enqueueSignedOperation:op];    

}



@end
