//
//  KKFunctions.m
//  Kollections
//
//  Created by Kerry Knight on 12/11/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "KKFunctions.h"
#import "dispatch/dispatch.h"

#pragma mark - KKUtility

// convenient for alert messages, with variadic format
void alertMessage ( NSString *format, ... ) {
    va_list args;
    va_start(args, format);
    
    NSString *outstr = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    //be sure we only ever call this from the main thread //kak 09Feb2012
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:kAlertTitle
                                  message:outstr delegate:nil
                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
    });
}
