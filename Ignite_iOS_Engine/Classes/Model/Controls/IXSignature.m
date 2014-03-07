//
//  IXSignature.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 3/7/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXSignature.h"

#import "PPSSignatureView.h"

#import "NSString+IXAdditions.h"

// IXSignature Read-Only Properties
static NSString* const kIXHasSignature = @"has_signature";
static NSString* const kIXLastSaveError = @"last_save_error";

// IXSignature Events
static NSString* const kIXSuccess = @"success"; // Fires when the "save_signature" function finishes successfully.
static NSString* const kIXFail = @"fail"; // Fires when the "save_signature" function fails to save the signature.

// IXSignature Functions
static NSString* const kIXSaveSignature = @"save_signature";
static NSString* const kIXTo = @"to"; // Parameter of the "save_signature" function.

@interface IXSignature ()

@property (nonatomic,strong) PPSSignatureView* signatureView;
@property (nonatomic,strong) NSString* lastErrorMessage;

@end

@implementation IXSignature

-(void)buildView
{
    [super buildView];
    
    _signatureView = [[PPSSignatureView alloc] initWithFrame:CGRectZero context:nil];
    [[self contentView] addSubview:_signatureView];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [[self signatureView] setFrame:rect];
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXHasSignature] )
    {
        returnValue = [NSString stringFromBOOL:[[self signatureView] hasSignature]];
    }
    else if( [propertyName isEqualToString:kIXLastSaveError] )
    {
        returnValue = [self lastErrorMessage];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXSaveSignature] )
    {
        BOOL didSaveSignature = NO;
        if( [[self signatureView] hasSignature] )
        {
            NSString* saveToLocation = [parameterContainer getPathPropertyValue:kIXTo basePath:nil defaultValue:nil];
            if( saveToLocation.length > 0 )
            {
                UIImage* signatureImage = [[self signatureView] signatureImage];
                if( signatureImage )
                {
                    // Update the cache with the newly created image.
                    [IXPropertyContainer storeImageInCache:signatureImage
                                              withImageURL:[NSURL fileURLWithPath:saveToLocation]
                                                    toDisk:NO];
                    
                    NSData* imageData = UIImagePNGRepresentation(signatureImage);
                    if( imageData )
                    {
                        NSFileManager* fileManager = [NSFileManager defaultManager];
                        NSError* __autoreleasing error = nil;
                        [fileManager createDirectoryAtPath:[saveToLocation stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
                        if( !error )
                        {
                            didSaveSignature = [fileManager createFileAtPath:saveToLocation contents:imageData attributes:nil];
                        }
                        else
                        {
                            [self setLastErrorMessage:[error description]];
                        }
                    }
                    else
                    {
                        [self setLastErrorMessage:@"Problem converting image data for signature image."];
                    }
                }
            }
            else
            {
                [self setLastErrorMessage:@"Save signature function needs a valid \"to\" parameter."];
            }
        }
        else
        {
            [self setLastErrorMessage:@"Signature control doesn't have signature image."];
        }
        
        if( didSaveSignature )
        {
            [[self actionContainer] executeActionsForEventNamed:kIXSuccess];
        }
        else
        {
            [[self actionContainer] executeActionsForEventNamed:kIXFail];
        }
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

@end
