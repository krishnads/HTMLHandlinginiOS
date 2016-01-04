//
//  WebViewInterface.h
//  HTMLtoiOS
//
//  Created by Krishana on 1/4/16.
//  Copyright © 2016 Konstant Info Solutions Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WebViewInterface <NSObject>

- (NSString *) getInitialPageName;
- (id) processFunctionFromJS:(NSString *) name withArgs:(NSArray*) args error:(NSError **) error;
 
@end
