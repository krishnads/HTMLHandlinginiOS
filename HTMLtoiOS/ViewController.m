//
//  ViewController.m
//  HTMLtoiOS
//
//  Created by Krishana on 1/4/16.
//  Copyright © 2016 Konstant Info Solutions Pvt. Ltd. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    
//    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"www"]];
//    NSURLRequest *req = [NSURLRequest requestWithURL:url];
//    [htmlWebView loadRequest:req];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    
//   // NSURL *url = [request URL];
//   // NSString *urlStr = url.absoluteString;
//    
//    //return [self processURL:urlStr];
//    
//}

- (NSString *) getInitialPageName
{
    return @"index.html";
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
    else
    {
        NSString *resultStr = [NSString stringWithFormat:@"Function '%@' not found", name];
        [self createError:error withCode:-1 withMessage:resultStr];
        return nil;
    }
}

@end
