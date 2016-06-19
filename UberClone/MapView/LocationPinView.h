//  Project name: UberClone
//  File name   : LocationPinView.h
//
//  Author      : Dung Le
//  Created date: 6/18/16
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2016 Dung Le. All rights reserved.
//  --------------------------------------------------------------

#import <UIKit/UIKit.h>


IB_DESIGNABLE
@interface LocationPinView : UIView {
    
@private
}

@property (nonatomic, strong) UIColor *innerColor;
@property (nonatomic, strong) UIColor *color;

+ (instancetype)pin;
- (UIImage *)image;

@end


@interface LocationPinView (LocationPinViewCreation)

// Class's static constructors

// Class's constructors

@end