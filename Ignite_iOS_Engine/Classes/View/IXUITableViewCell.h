//
//  IXUITableViewCell.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/17/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IXLayout;
@class IXSandbox;

@interface IXUITableViewCell : UITableViewCell

@property (nonatomic,assign) BOOL forceSize;
@property (nonatomic,assign) CGSize forcedSize;
@property (nonatomic,strong) IXSandbox* cellSandbox;
@property (nonatomic,strong) IXLayout* layoutControl;

@property (nonatomic,assign) CGFloat swipeWidth;
@property (nonatomic,strong) IXLayout* backgroundLayoutControl;

-(void)enablePanGesture:(BOOL)enableGesture;

@end
