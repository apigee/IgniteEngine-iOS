//
//  ixeBaseAction.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeBaseConditionalObject.h"

@class ixeProperty;
@class ixeActionContainer;
@class ixePropertyContainer;

@interface ixeBaseAction : ixeBaseConditionalObject

@property (nonatomic,weak) ixeActionContainer* actionContainer;

@property (nonatomic,copy) NSString* eventName;
@property (nonatomic,strong) ixePropertyContainer* actionProperties;
@property (nonatomic,strong) ixePropertyContainer* parameterProperties;
@property (nonatomic,strong) ixeActionContainer* subActionContainer;

// NOT DONE YET
#warning METHODS NOT DONE YET
-(void)execute;

@end
