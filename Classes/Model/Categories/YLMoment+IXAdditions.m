//
//  YLMoment+IXAdditions.m
//  Ignite Engine
//
//  Created by Brandon on 4/1/14.
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

#import "YLMoment+IXAdditions.h"

@implementation YLMoment (IXAdditions)

+(CGFloat)momentToUnix:(YLMoment*)moment
{
    return [moment.date timeIntervalSince1970];
}

+(CGFloat)momentToJS:(YLMoment*)moment
{
    return [moment.date timeIntervalSince1970] * 1000;
}

+(YLMoment*)momentFromUnix:(NSString*)date
{
    return [YLMoment momentWithDate:[NSDate dateWithTimeIntervalSince1970:[date longLongValue]]];
}

+(YLMoment*)momentFromJS:(NSString*)date
{
    return [YLMoment momentWithDate:[NSDate dateWithTimeIntervalSince1970:[date longLongValue] / 1000]];
}

@end
