//
//  IXImageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/14.
//  Copyright (c) 2013 All rights reserved.
//

/*
 
 CONTROL
 
 - TYPE : "Spinner"
 
 - PROPERTIES
 
 * name="style"                     default="white"               type="String"
  
 */

#import "IXActivityIndicator.h"

@interface IXActivityIndicator ()

@property (nonatomic,strong) NSString* imagePath;
@property (nonatomic,strong) NSString* touchedImagePath;

@end

@implementation IXActivityIndicator

-(void)buildView
{
    [super buildView];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return CGSizeMake(_Spinner.frame.size.width, _Spinner.frame.size.height);
}

-(void)applySettings
{
     [_Spinner removeFromSuperview];
    [super applySettings];
    NSString* spinnerStyle = [[self propertyContainer] getStringPropertyValue:@"style" defaultValue:@"white"];
    
    if([spinnerStyle compare:@"white"] == NSOrderedSame)
    {
        _Spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    else if([spinnerStyle compare:@"gray"] == NSOrderedSame)
    {
        _Spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    if([spinnerStyle compare:@"large"] == NSOrderedSame)
    {
        _Spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    else
    {
    }
    
    _Spinner.center = CGPointMake(_Spinner.frame.size.height/2, _Spinner.frame.size.width/2);
    _Spinner.hidesWhenStopped = NO;
    [_Spinner startAnimating];
    [[self contentView] addSubview:_Spinner];
    

}



@end
