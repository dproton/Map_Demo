#import "LocationPinView.h"


@interface LocationPinView () {
}

@property (strong, nonatomic) UIView *circle;
@property (strong, nonatomic) UIView *pin;

/** Initialize class's private variables. */
- (void)_init;
/** Visualize all view's components. */
- (void)_visualize;

@end


@implementation LocationPinView


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

+ (instancetype)pin
{
    return [[[self class] alloc] initWithFrame:CGRectMake(0, 0, 25, 50)];
}

- (UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)setInnerColor:(UIColor *)innerColor
{
    _innerColor = innerColor;
    _circle.backgroundColor = _innerColor;
}


#pragma mark - Class's private methods
- (void)_init
{
    _circle = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_circle];
    
    _pin = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_pin];
    
    self.color = [UIColor blackColor];
    self.innerColor = [UIColor blueColor];


}
- (void)_visualize
{
    CGRect frame = self.frame;
    CGFloat smallSide = frame.size.width;
    _circle.layer.cornerRadius = smallSide / 2.0;
    _circle.frame = CGRectMake(0, 0, smallSide, smallSide);
    _pin.frame = CGRectMake(CGRectGetWidth(frame) / 2.0 - 1, CGRectGetHeight(frame) / 2.0, 2, CGRectGetMaxY(frame)-CGRectGetMidY(frame));
    
    _pin.backgroundColor = self.color;
    _circle.backgroundColor = self.innerColor;
    _circle.layer.borderColor = self.color.CGColor;
    _circle.layer.borderWidth = 3;

}

@end
