//
//  WebViewController.h
//  HTMLtoiOS
//
//  Created by Krishana on 1/4/16.
//  Copyright © 2016 Konstant Info Solutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "WebViewInterface.h"

@interface WebViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView* webView;
}

- (void) createError:(NSError**) error withCode:(int) code withMessage:(NSString*) msg;

@end
