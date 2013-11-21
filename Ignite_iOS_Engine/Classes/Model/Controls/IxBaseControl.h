//
//  IxBaseControl.h
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//


/*
 
 IxBaseControl
 
 IxControlsBase
 
 IxScannerControl
 
 
 
 */

#import "IxBaseObject.h"
#import "IxControlContentView.h"

@class IxSandbox;
@class IxControlLayoutInfo;

@interface IxBaseControl : IxBaseObject  <IxControlContentViewTouchDelegate>

@property (nonatomic,strong,readonly) IxControlContentView* contentView;
@property (nonatomic,strong,readonly) IxControlLayoutInfo* layoutInfo;

-(void)buildView;

-(void)layoutControl;
-(void)layoutControlContentsInRect:(CGRect)rect;
-(CGSize)preferredSizeForSuggestedSize:(CGSize)size;

@end
