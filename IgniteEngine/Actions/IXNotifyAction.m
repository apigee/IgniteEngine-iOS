//
//  IXNotifyAction.m
//  Ignite Engine
//
//  Created by Robert Walsh on 11/14/15.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
//

#import "IXNotifyAction.h"

#import "IXActionContainer.h"
#import "IXAttributeContainer.h"
#import "YLMoment.h"
#import "YLMoment+IXAdditions.h"

// IXNotifyAction Attributes
IX_STATIC_CONST_STRING kIXTitle = @"title";
IX_STATIC_CONST_STRING kIXMessage = @"message";
IX_STATIC_CONST_STRING kIXDate = @"date";
IX_STATIC_CONST_STRING kIXDateFormat = @"dateFormat";

// Non attribute constants
IX_STATIC_CONST_STRING kIXDefaultDateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";

@implementation IXNotifyAction

-(void)execute
{
    [super execute];

    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notification setAlertTitle:[[self actionProperties] getStringValueForAttribute:kIXTitle defaultValue:nil]];
    [notification setAlertBody:[[self actionProperties] getStringValueForAttribute:kIXMessage defaultValue:nil]];

    NSDate* fireDate = [NSDate date];
    NSString* dateString = [[self actionProperties] getStringValueForAttribute:kIXDate defaultValue:nil];
    NSString* dateFormat = [[self actionProperties] getStringValueForAttribute:kIXDateFormat defaultValue:kIXDefaultDateFormat];

    if( dateString.length > 0 ) {
        YLMoment* moment = [YLMoment momentWithDateAsString:dateString format:dateFormat];
        if( [moment isValid] ) {
            fireDate = [moment date];
        }
    }

    [notification setFireDate:fireDate];

    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end


