//
//  IxBaseAction.h
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxBaseConditionalObject.h"

@class IxProperty;
@class IxActionContainer;
@class IxPropertyContainer;

@interface IxBaseAction : IxBaseConditionalObject

@property (nonatomic,weak) IxActionContainer* actionContainer;

@property (nonatomic,copy) NSString* eventName;
@property (nonatomic,strong) IxPropertyContainer* actionProperties;
@property (nonatomic,strong) IxPropertyContainer* parameterProperties;
@property (nonatomic,strong) IxActionContainer* subActionContainer;

// NOT DONE YET
#warning METHODS NOT DONE YET
-(void)execute;

@end
