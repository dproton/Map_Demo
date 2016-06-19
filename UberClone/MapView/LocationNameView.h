//  Project name: UberClone
//  File name   : LocationLabel.h
//
//  Author      : Dung Le
//  Created date: 6/18/16
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2016 Dung Le. All rights reserved.
//  --------------------------------------------------------------

#import <UIKit/UIKit.h>


IB_DESIGNABLE
@interface LocationNameView : UIView {
    
@private
}

@property (nonatomic, strong) UIColor     *color;
@property (nonatomic, strong) NSString    *placeholderText;
@property (nonatomic, strong) NSString    *locationText;

@property (nonatomic, assign, readonly) BOOL        isFocused;
@property (weak, nonatomic) id<UITextFieldDelegate> textFieldDelegate;


@end


@interface LocationNameView (LocationLabelCreation)

// Class's static constructors

// Class's constructors

@end