//
//  ixeBaseControl.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//


/*
 
 ixeBaseControl
 
 ixeControlsBase
 
 ixeScannerControl
 
 
 
 */

#import "ixeBaseObject.h"
#import "ixeControlContentView.h"

@class ixeSandbox;
@class ixeControlLayoutInfo;

@interface ixeBaseControl : ixeBaseObject  <ixeControlContentViewTouchDelegate>

@property (nonatomic,strong,readonly) ixeControlContentView* contentView;
@property (nonatomic,strong,readonly) ixeControlLayoutInfo* layoutInfo;

-(void)buildView;

-(void)layoutControl;
-(void)layoutControlContentsInRect:(CGRect)rect;
-(CGSize)preferredSizeForSuggestedSize:(CGSize)size;

@end
