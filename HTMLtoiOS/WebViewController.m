//
//  WebViewController.m
//  HTMLtoiOS
//
//  Created by Krishana on 1/4/16.
//  Copyright © 2016 Konstant Info Solutions Pvt. Ltd. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController


- (NSString *) getInitialPageName
{
    return @"index.html";
    //@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Subclass must implement getInitialPageName function" userInfo:nil];
}

- (id) processFunctionFromJS:(NSString *) name withArgs:(NSArray*) args error:(NSError **) error
{
    if ([name compare:@"sayHello" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        if (args.count > 0)
        {
            return [NSString stringWithFormat:@"Hello %@ !", [args objectAtIndex:0]];
        }
        else
        {
            NSString *resultStr = [NSString stringWithFormat:@"Missing argument in function %@", name];
            [self createError:error withCode:-1 withMessage:resultStr];
            return nil;
        }
    }
    else if ([name compare:@"btnClickAction" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        if (args.count > 0)
        {
            return [NSString stringWithFormat:@"Hello %@ !", [args objectAtIndex:0]];
        }
        else
        {
            NSString *resultStr = [NSString stringWithFormat:@"Missing argument in function %@", name];
            [self createError:error withCode:-1 withMessage:resultStr];
            return nil;
        }
    }
    else
    {
        NSString *resultStr = [NSString stringWithFormat:@"Function '%@' not found", name];
        [self createError:error withCode:-1 withMessage:resultStr];
        return nil;
    }

    //@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Subclass must implement processFunctionFromJS function" userInfo:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [webView setDelegate:self];
    NSString* initialPage = [self getInitialPageName];
    if (initialPage != nil)
    {
        NSURL *url = nil;
        if ([initialPage rangeOfString:@"http://"].length > 0 || [initialPage rangeOfString:@"https://"].length > 0)
        {
            url = [NSURL URLWithString:initialPage];
        }
        else
        {
            NSRange range = [initialPage rangeOfString:@"."];
            if (range.length > 0)
            {
                NSString *fileExt = [initialPage substringFromIndex:range.location+1];
                NSString *fileName = [initialPage substringToIndex:range.location];
                
                url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:fileExt inDirectory:@"www"]];
            }
        }
        
        if (url != nil)
        {
            NSURLRequest *req = [NSURLRequest requestWithURL:url];
            [webView loadRequest:req];
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    NSString *urlStr = url.absoluteString;
    return [self processURL:urlStr];
}

- (BOOL) processURL:(NSString *) url
{
    NSString *urlStr = [NSString stringWithString:url];
    NSString *protocolPrefix = @"js2ios://";
    
    if ([[urlStr lowercaseString] hasPrefix:protocolPrefix])
    {
        urlStr = [urlStr substringFromIndex:protocolPrefix.length];
        urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError;
        NSDictionary *callInfo = [NSJSONSerialization
                                  JSONObjectWithData:[urlStr dataUsingEncoding:NSUTF8StringEncoding]
                                  options:kNilOptions
                                  error:&jsonError];
        
        if (jsonError != nil)
        {
            //call error callback function here
            NSLog(@"Error parsing JSON for the url %@",url);
            return NO;
        }
        
        NSString *functionName = [callInfo objectForKey:@"functionname"];
        if (functionName == nil)
        {
            NSLog(@"Missing function name");
            return NO;
        }
        
        NSLog(@"call info->%@",callInfo);
        NSString *successCallback = [callInfo objectForKey:@"success"];
        NSString *errorCallback = [callInfo objectForKey:@"error"];
        NSArray *argsArray = [callInfo objectForKey:@"args"];
        
        [self callFunction:functionName withArgs:argsArray onSuccess:successCallback onError:errorCallback];
        return NO;
    }
    return YES;
}

- (void) callFunction:(NSString *) name withArgs:(NSArray *) args onSuccess:(NSString *) successCallback onError:(NSString *) errorCallback
{
    NSError *error;
    id retVal = [self processFunctionFromJS:name withArgs:args error:&error];
    if (error != nil)
    {
        NSString *resultStr = [NSString stringWithString:error.localizedDescription];
        [self callErrorCallback:errorCallback withMessage:resultStr];
        return;
    }
    
    NSLog(@"method name before success->%@",successCallback);
    [self callSuccessCallback:successCallback withRetValue:retVal forFunction:name];
}

-(void) callErrorCallback:(NSString *) name withMessage:(NSString *) msg
{
    if (name != nil)
    {
        //call error handler
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@);",name,msg]];
    }
    else
    {
        NSLog(@"%@",msg);
    }
}

-(void) callSuccessCallback:(NSString *)name withRetValue:(id) retValue forFunction:(NSString *) funcName
{
    NSLog(@"method name in success->%@",name);

    if (name != nil)
    {
        //call succes handler
        
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        [resultDict setObject:retValue forKey:@"result"];
        [self callJSFunction:name withArgs:resultDict];
    }
    else
    {
        NSLog(@"Result of function %@ = %@", funcName,retValue);
    }
    
}

-(void) callJSFunction:(NSString *) name withArgs:(NSMutableDictionary *) args
{
    NSError *jsonError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:args options:0 error:&jsonError];
    
    if (jsonError != nil)
    {
        //call error callback function here
        NSLog(@"Error creating JSON from the response  : %@",[jsonError localizedDescription]);
        return;
    }
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"jsonStr = %@", jsonStr);
    
    if (jsonStr == nil)
    {
        NSLog(@"jsonStr is null. count = %lu", (unsigned long)[args count]);
    }
    
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@);",name,jsonStr]];
}

- (void) createError:(NSError**) error withMessage:(NSString *) msg
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:msg forKey:NSLocalizedDescriptionKey];
    
    *error = [NSError errorWithDomain:@"JSiOSBridgeError" code:-1 userInfo:dict];
}

-(void) createError:(NSError**) error withCode:(int) code withMessage:(NSString*) msg
{
    NSMutableDictionary *msgDict = [NSMutableDictionary dictionary];
    [msgDict setValue:[NSNumber numberWithInt:code] forKey:@"code"];
    [msgDict setValue:msg forKey:@"message"];
    
    NSError *jsonError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:msgDict options:0 error:&jsonError];
    
    if (jsonError != nil)
    {
        //call error callback function here
        NSLog(@"Error creating JSON from error message  : %@",[jsonError localizedDescription]);
        return;
    }
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self createError:error withMessage:jsonStr];
}

@end