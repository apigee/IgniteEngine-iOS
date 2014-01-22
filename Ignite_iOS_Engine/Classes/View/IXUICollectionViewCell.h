//
//  IXUICollectionViewCell.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 1/21/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IXLayout;
@class IXSandbox;

@interface IXUICollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) IXSandbox* cellSandbox;
@property (nonatomic,strong) IXLayout* layoutControl;

@end
