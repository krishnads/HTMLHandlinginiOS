//
//  MyViewController.m
//  HTMLtoiOS
//
//  Created by Krishana on 1/4/16.
//  Copyright © 2016 Konstant Info Solutions Pvt. Ltd. All rights reserved.
//

#import "MyViewController.h"

@interface MyViewController ()

@end

@implementation MyViewController

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
