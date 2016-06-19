#import "LocationNameView.h"


static const CGFloat CircleViewRadius = 5;
static const CGFloat kDefaultFontSize = 14;
@interface LocationNameView () <UITextFieldDelegate>
{
    
}

@property (nonatomic, strong) UITextField *locationTextField;

@property (nonatomic, strong) UIView      *circleView;
@property (nonatomic, assign) BOOL        constraintsInstalled;
@property (nonatomic, assign) BOOL        isFocused;


/** Initialize class's private variables. */
- (void)_init;
/** Visualize all view's components. */
- (void)_visualize;

@end


@implementation LocationNameView


#pragma mark - Class's constructors
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}


#pragma mark - Cleanup memory
- (void)dealloc {
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}


#pragma mark - Class's properties


#pragma mark - Class's public methods
- (void)layoutSubviews {
    [super layoutSubviews];
    [self _visualize];
}
//- (void)drawRect:(CGRect)rect {
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(context);
//    
//    CGContextRestoreGState(context);
//}


#pragma mark - Class's private methods
- (void)_init
{
    self.locationTextField = [[UITextField alloc] init];
    self.locationTextField.translatesAutoresizingMaskIntoConstraints = NO;
//    self.locationTextField.userInteractionEnabled = NO;
    self.locationTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.locationTextField.font = [UIFont systemFontOfSize:kDefaultFontSize];
    self.locationTextField.textAlignment = NSTextAlignmentLeft;
    [self.locationTextField setReturnKeyType:UIReturnKeySearch];
    self.locationTextField.placeholder = @"";
    self.locationTextField.delegate = self;
    [self addSubview:self.locationTextField];
    
    self.circleView = [[UIView alloc] init];
    self.circleView.translatesAutoresizingMaskIntoConstraints = NO;
    self.circleView.backgroundColor = [UIColor blackColor];
    self.circleView.layer.cornerRadius = CircleViewRadius;
    [self addSubview:self.circleView];
    
    self.color = [UIColor blackColor];
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowColor = [UIColor grayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(1, 1);
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.5;
    
}
- (void)_visualize
{
    
}

- (void)setPlaceholderText:(NSString *)placeholderText
{
    _placeholderText = placeholderText;
    [self updateLocationView];
}

- (void)setLocationText:(NSString *)locationText
{
    _locationText = locationText;
    [self updateLocationView];
}

- (void)updateLocationView
{
    if (self.locationText.length > 0)
    {
        self.locationTextField.text = self.locationText;
    }
    else
    {
        self.locationTextField.placeholder = self.placeholderText;
    }
}

- (void)updateConstraints
{
    if (!_constraintsInstalled)
    {
        _constraintsInstalled = YES;
        
        NSDictionary *metrics = @{
                                  @"dia" : @(CircleViewRadius * 2),
                                  @"vpad" : @10,
                                  @"hpad" : @19,
                                  };
        NSDictionary *views = NSDictionaryOfVariableBindings(_locationTextField, _circleView);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hpad-[_circleView(==dia)]-hpad-[_locationTextField]-hpad-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
        
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vpad-[_locationTextField]-vpad-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.circleView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.circleView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.circleView
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1
                                                          constant:0]];
        
    }
    
    [super updateConstraints];
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    self.circleView.backgroundColor = color;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.textFieldDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)])
    {
        return [self.textFieldDelegate textFieldShouldBeginEditing:textField];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.isFocused = YES;
    if ([self.textFieldDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
    {
        [self.textFieldDelegate textFieldDidBeginEditing:textField];
    }

}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([self.textFieldDelegate respondsToSelector:@selector(textFieldShouldEndEditing:)])
    {
        return [self.textFieldDelegate textFieldShouldEndEditing:textField];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.textFieldDelegate respondsToSelector:@selector(textFieldDidEndEditing:)])
    {
        [self.textFieldDelegate textFieldDidEndEditing:textField];
    }
    
    self.isFocused = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.textFieldDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
    {
        return [self.textFieldDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([self.textFieldDelegate respondsToSelector:@selector(textFieldShouldClear:)])
    {
        return [self.textFieldDelegate textFieldShouldClear:textField];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.textFieldDelegate respondsToSelector:@selector(textFieldShouldReturn:)])
    {
        return [self.textFieldDelegate textFieldShouldReturn:textField];
    }
    
    return YES;
}


@end
