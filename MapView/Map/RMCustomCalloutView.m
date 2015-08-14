//
//  test.m
//  MapView
//
//  Created by Daniel Christoph on 03.08.15.
//
//

#import "RMCustomCalloutView.h"
#define TOP_ANCHOR_MARGIN 13 // all the above measurements assume a bottom anchor! if we're pointing "up" we'll need to add this top margin to everything.

//
// UIView frame helpers - we do a lot of UIView frame fiddling in this class; these functions help keep things readable.
//
@interface UIView (SMFrameAdditions)
@property (nonatomic, assign) CGPoint frameOrigin;
@property (nonatomic, assign) CGSize frameSize;
@property (nonatomic, assign) CGFloat frameX, frameY, frameWidth, frameHeight; // normal rect properties
@property (nonatomic, assign) CGFloat frameLeft, frameTop, frameRight, frameBottom; // these will stretch/shrink the rect
@end

@interface SMCalloutBackgroundView (EmbeddedImages)
+ (UIImage *)embeddedImageNamed:(NSString *)name;
@end

@interface RMCustomCalloutView ()
@property (nonatomic, strong) UIView *containerView, *containerBorderView, *arrowView;
@property (nonatomic, strong) UIImageView *arrowImageView, *arrowHighlightedImageView, *arrowBorderView;
@end

static UIImage *borderArrowImage = nil, *defaultArrowImage = nil, *highlightedArrowImage = nil, *arrowImage = nil;

@implementation RMCustomCalloutView
{
    @private UIColor *_backgroundColor;
    @private UIColor *_highlightedBackgroundColor;
}

- (id)initWithFrame:(CGRect)frame andBackgroundColor:(UIColor*)backgroundColor withHighlightedBackgroundColor:(UIColor*)highlightedBackgroundColor{
    if (self = [super initWithFrame:frame]) {
        _backgroundColor = backgroundColor;
        _highlightedBackgroundColor = highlightedBackgroundColor;
        self.containerView = [UIView new];
        self.containerView.backgroundColor = _backgroundColor;
        self.containerView.layer.cornerRadius = 8;
        self.containerView.layer.shadowRadius = 30;
        self.containerView.layer.shadowOpacity = 0.1;
        
        self.containerBorderView = [UIView new];
        self.containerBorderView.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
        self.containerBorderView.layer.borderWidth = 0.1;
        self.containerBorderView.layer.cornerRadius = 8.5;
        
        if (!arrowImage) {
            arrowImage = [SMCalloutBackgroundView embeddedImageNamed:@"CalloutArrow"];
            borderArrowImage = [self image:arrowImage withColor:_backgroundColor];
            defaultArrowImage = [self image:arrowImage withColor:_backgroundColor];
            highlightedArrowImage = [self image:arrowImage withColor:_highlightedBackgroundColor];
        }
        
        self.anchorHeight = 13;
        self.anchorMargin = 27;
        
        self.arrowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, borderArrowImage.size.width, borderArrowImage.size.height)];
        self.arrowImageView = [[UIImageView alloc] initWithImage:defaultArrowImage];
        self.arrowHighlightedImageView = [[UIImageView alloc] initWithImage:highlightedArrowImage];
        self.arrowHighlightedImageView.hidden = YES;
        self.arrowBorderView = [[UIImageView alloc] initWithImage:borderArrowImage];
        self.arrowBorderView.alpha = 0.1;
        self.arrowBorderView.frameY = 0.1;
        
        [self addSubview:self.containerView];
        [self.containerView addSubview:self.containerBorderView];
        [self addSubview:self.arrowView];
        [self.arrowView addSubview:self.arrowBorderView];
        [self.arrowView addSubview:self.arrowImageView];
        [self.arrowView addSubview:self.arrowHighlightedImageView];
    }
    return self;
}

// Make sure we relayout our images when our arrow point changes!
- (void)setArrowPoint:(CGPoint)arrowPoint {
    [super setArrowPoint:arrowPoint];
    [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];

    self.containerView.backgroundColor = highlighted ? _highlightedBackgroundColor : _backgroundColor;
    self.arrowImageView.hidden = highlighted;
    self.arrowHighlightedImageView.hidden = !highlighted;
}

- (UIImage *)image:(UIImage *)image withColor:(UIColor *)color {
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    CGRect imageRect = (CGRect){.size=image.size};
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(c, 0, image.size.height);
    CGContextScaleCTM(c, 1, -1);
    CGContextClipToMask(c, imageRect, image.CGImage);
    [color setFill];
    CGContextFillRect(c, imageRect);
    UIImage *whiteImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return whiteImage;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    BOOL pointingUp = self.arrowPoint.y < self.frameHeight/2;
    
    // if we're pointing up, we'll need to push almost everything down a bit
    CGFloat dy = pointingUp ? TOP_ANCHOR_MARGIN : -0.6;
    
    self.containerView.frame = CGRectMake(0, dy, self.frameWidth, self.frameHeight - self.arrowView.frameHeight + 0.5);
    self.containerBorderView.frame = CGRectInset(self.containerView.bounds, -0.5, -0.5);
    
    self.arrowView.frameX = roundf(self.arrowPoint.x - self.arrowView.frameWidth / 2);
    
    if (pointingUp) {
        self.arrowView.frameY = 1;
        self.arrowView.transform = CGAffineTransformMakeRotation(M_PI);
    }
    else {
        self.arrowView.frameY = self.containerView.frameHeight - 0.5;
        self.arrowView.transform = CGAffineTransformIdentity;
    }
}

- (CALayer *)contentMask {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *maskImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CALayer *layer = [CALayer layer];
    layer.frame = self.bounds;
    layer.contents = (id)maskImage.CGImage;
    return layer;
}

@end
