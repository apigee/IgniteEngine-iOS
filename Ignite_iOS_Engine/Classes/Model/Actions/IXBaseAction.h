//
//  IXBaseAction.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//

#import "IXBaseConditionalObject.h"

@class IXProperty;
@class IXActionContainer;
@class IXPropertyContainer;

@interface IXBaseAction : IXBaseConditionalObject

@property (nonatomic,weak) IXActionContainer* actionContainer;

@property (nonatomic,copy) NSString* eventName;
@property (nonatomic,strong) IXPropertyContainer* actionProperties;
@property (nonatomic,strong) IXPropertyContainer* parameterProperties;
@property (nonatomic,strong) IXActionContainer* subActionContainer;

// NOT DONE YET
#warning METHODS NOT DONE YET
-(void)execute;

@end
