//
//  IXLogAction.m
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/23/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXLogAction.h"

#import "IXAppManager.h"
#import "IXActionContainer.h"
#import "IXPropertyContainer.h"
#import "IXLogger.h"

static NSString* const kIXText = @"text";
static NSString* const kIXDelay = @"delay";

@implementation IXLogAction

-(void)execute
{
    [super execute];
    
    IXPropertyContainer* actionProperties = [self actionProperties];
    
    NSString* text = [actionProperties getStringPropertyValue:kIXText defaultValue:nil];
    
    DDLogDebug(@"Log action: %@", text);
}

@end