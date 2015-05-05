//
//  IXJSONUtils.m
//  IgniteEngine
//
//  Created by Brandon on 4/16/15.
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

#import "IXJSONUtils.h"
#import "IXAppManager.h"
#import "IXViewController.h"
#import "NSString+IXAdditions.h"

@implementation IXJSONUtils

+(NSObject*)setValue:(NSObject*)value forKeyPath:(NSString *)path inContainer:(NSObject*)container
{
    if (container == nil || path == nil) {
        return nil;
    }
    NSObject* mutableContainer = [container mutableCopy];
    if ([container valueForKeyPath:path]) {
        [mutableContainer setValue:value forKeyPath:path];
    } else {
        IX_LOG_ERROR(@"Key path for container (%@) is not KVO compliant. Only dot-notated dictionary paths are currently supported.", path);
    }
    return mutableContainer;
}

+(NSObject*)objectForPath:(NSString *)jsonXPath container:(NSObject*)currentNode sandox:(IXSandbox*)sandbox baseObject:(IXBaseObject*)baseObject
{
    if (currentNode == nil) {
        return nil;
    }
    
    if(![currentNode isKindOfClass:[NSDictionary class]] && ![currentNode isKindOfClass:[NSArray class]]) {
        return currentNode;
    }
    if ([jsonXPath hasPrefix:kIX_PERIOD_SEPERATOR]) {
        jsonXPath = [jsonXPath substringFromIndex:1];
    }
    
    NSString *currentKey = [[jsonXPath componentsSeparatedByString:kIX_PERIOD_SEPERATOR] firstObject];
    NSObject *nextNode;
    // if dict -> get value
    if ([currentNode isKindOfClass:[NSDictionary class]]) {
        NSDictionary *currentDict = (NSDictionary *) currentNode;
        nextNode = currentDict[jsonXPath];
        if( nextNode != nil )
        {
            return nextNode;
        }
        else
        {
            nextNode = currentDict[currentKey];
        }
    }
    
    if ([currentNode isKindOfClass:[NSArray class]]) {
        NSArray * currentArray = (NSArray *) currentNode;
        @try {
            if( [currentKey containsString:@"="] ) // current key is actually looking to filter array if theres an '=' character
            {
                NSArray* currentKeyseparated = [currentKey componentsSeparatedByString:@"="];
                if( [currentKeyseparated count] > 1 ) {
                    NSString* currentKeyValue = [currentKeyseparated lastObject];
                    if( [currentKeyValue rangeOfString:@"?"].location != NSNotFound )
                    {
                        currentKeyValue = [self getQueryValueOutOfValue:currentKeyValue sandbox:sandbox baseObject:baseObject];
                    }
                    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(%K == %@)",[currentKeyseparated firstObject],currentKeyValue];
                    NSArray* filteredArray = [currentArray filteredArrayUsingPredicate:predicate];
                    if( [filteredArray count] >= 1 ) {
                        if( [filteredArray count] == 1 ) {
                            nextNode = [filteredArray firstObject];
                        } else {
                            nextNode = filteredArray;
                        }
                    }
                }
            }
            else // current key must be an number
            {
                if( [currentKey isEqualToString:@"$count"] || [currentKey isEqualToString:@".$count"] )
                {
                    return [NSString stringWithFormat:@"%lu",(unsigned long)[currentArray count]];
                }
                else if ([currentArray count] > 0)
                {
                    nextNode = [currentArray objectAtIndex:[currentKey integerValue]];
                }
                else
                {
                    @throw [NSException exceptionWithName:@"NSRangeException"
                                                   reason:@"Specified array index is out of bounds"
                                                 userInfo:nil];
                }
            }
        }
        @catch (NSException *exception) {
            IX_LOG_ERROR(@"ERROR : %@ Exception in %@ : %@; attempted to retrieve index %@ from %@",THIS_FILE,THIS_METHOD,exception,currentKey, jsonXPath);
        }
    }
    
    NSString * nextXPath = [jsonXPath stringByReplacingCharactersInRange:NSMakeRange(0, [currentKey length]) withString:kIX_EMPTY_STRING];
    if( nextXPath.length <= 0 )
    {
        return nextNode;
    }
    // call recursively with the new xpath and the new Node
    return [self objectForPath:nextXPath container:nextNode sandox:sandbox baseObject:(IXBaseObject*)baseObject];
}

+(NSString*)getQueryValueOutOfValue:(NSString*)value sandbox:(IXSandbox*)sandbox baseObject:(IXBaseObject*)baseObject
{
    NSString* returnValue = value;
    NSArray* separatedValue = [value componentsSeparatedByString:@"?"];
    if( [separatedValue count] > 0 )
    {
        NSString* objectID = [separatedValue firstObject];
        NSString* propertyName = [separatedValue lastObject];
        if( [objectID isEqualToString:kIXSessionRef] )
        {
            returnValue = [[[IXAppManager sharedAppManager] sessionProperties] getStringValueForAttribute:propertyName defaultValue:value];
        }
        else if( [objectID isEqualToString:kIXAppRef] )
        {
            returnValue = [[[IXAppManager sharedAppManager] appProperties] getStringValueForAttribute:propertyName defaultValue:value];
        }
        else if( [objectID isEqualToString:kIXViewControlRef] )
        {
            returnValue = [[sandbox viewController] getViewPropertyNamed:propertyName];
            if( returnValue == nil )
            {
                returnValue = value;
            }
        }
        else
        {
            NSArray* objectWithIDArray = [sandbox getAllControlsAndDataProvidersWithID:objectID withSelfObject:baseObject];
            IXBaseObject* baseObject = [objectWithIDArray firstObject];
            
            if( baseObject )
            {
                returnValue = [baseObject getReadOnlyPropertyValue:propertyName];
                if( returnValue == nil )
                {
                    returnValue = [[baseObject attributeContainer] getStringValueForAttribute:propertyName defaultValue:value];
                }
            }
        }
    }
    return returnValue;
}

+(NSObject*)appendNewResponseObject:(NSObject *)newObject toPreviousResponseObject:(NSObject *)previousObject forDataPath:(NSString *)dataPath sandox:(IXSandbox*)sandbox baseObject:(IXBaseObject*)baseObject
{
    @try {
        NSMutableArray* newData = [(NSMutableArray*)[self objectForPath:dataPath container:newObject sandox:sandbox baseObject:baseObject] mutableCopy];
        NSMutableArray* previousData = [(NSMutableArray*)[self objectForPath:dataPath container:previousObject sandox:sandbox baseObject:baseObject] mutableCopy];
        NSArray* appendedArray = [previousData arrayByAddingObjectsFromArray:newData];
        NSObject* returnObject = [[IXJSONUtils setValue:appendedArray forKeyPath:dataPath inContainer:newObject] mutableCopy];
        
        if ([returnObject valueForKey:@"count"]) {
            [returnObject setValue:[NSString stringWithFormat:@"%lu", appendedArray.count] forKey:@"count"];
        } else if ([returnObject valueForKey:@"length"]) {
            [returnObject setValue:[NSString stringWithFormat:@"%lu", appendedArray.count] forKey:@"length"];
        }
//TODO: Need an exposed way of defining where the count property in the dataset is, and how to update it.
        
        return returnObject;
    }
    @catch (NSException *exception) {
        IX_LOG_ERROR(@"ERROR: %@ Exception when appending array %@ to %@", exception, previousObject, newObject);
        return nil;
    }
}

@end
