//
//  IXBaseControl.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//


/*
 
 IXBaseControl
 
 IXControlsBase
 
 IXScannerControl
 
 
 
 */

#import "IXBaseObject.h"
#import "IXControlContentView.h"

@class IXSandbox;
@class IXControlLayoutInfo;

@interface IXBaseControl : IXBaseObject  <IXControlContentViewTouchDelegate>

@property (nonatomic,strong,readonly) IXControlContentView* contentView;
@property (nonatomic,strong,readonly) IXControlLayoutInfo* layoutInfo;

-(void)buildView;

-(void)layoutControl;
-(void)layoutControlContentsInRect:(CGRect)rect;
-(CGSize)preferredSizeForSuggestedSize:(CGSize)size;

@end
