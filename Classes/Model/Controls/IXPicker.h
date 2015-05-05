//
//  IXPicker.h
//  Ignite Engine
//
//  Created by Jeremy on 4/2/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXBaseControl.h"
#import "ActionSheetPicker.h"

@interface IXPicker : IXBaseControl

@property (nonatomic,strong) ActionSheetDatePicker* datePicker;
@property (nonatomic,strong) ActionSheetStringPicker* stringPicker;

@end
