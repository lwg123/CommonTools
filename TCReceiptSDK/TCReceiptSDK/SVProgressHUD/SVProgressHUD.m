//
//  SVProgressHUD.m
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVProgressHUD
//

#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

@interface SVProgressHUD ()

@property (nonatomic,assign) CGPoint fixedPosition;

@property (nonatomic, readwrite) SVProgressHUDMaskType maskType;
@property (nonatomic, strong, readonly) NSTimer *fadeOutTimer;

@property (nonatomic, strong, readonly) UIWindow *overlayWindow;
@property (nonatomic, strong, readonly) UIView *hudView;
@property (nonatomic, strong, readonly) UILabel *stringLabel;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *spinnerView;
@property (nonatomic, strong, readonly) UIGestureRecognizer *tapParent;
@property (nonatomic,strong)UIImageView* gifImageView;
@property (nonatomic, readonly) CGFloat visibleKeyboardHeight;

- (void)showWithStatus:(NSString*)string maskType:(SVProgressHUDMaskType)hudMaskType networkIndicator:(BOOL)show;
- (void)showImage:(UIImage*)image status:(NSString*)status duration:(NSTimeInterval)duration;
- (void)dismiss;

- (void)setStatus:(NSString*)string;
- (void)registerNotifications;
- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle;
- (void)positionHUD:(NSNotification*)notification;

@end


@implementation SVProgressHUD

@synthesize overlayWindow,hudView, maskType, fadeOutTimer, stringLabel,imageView, spinnerView, visibleKeyboardHeight;

- (void)dealloc {
	self.fadeOutTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


+ (SVProgressHUD*)sharedView {
    static dispatch_once_t once;
    static SVProgressHUD *sharedView;
    dispatch_once(&once, ^ { sharedView = [[SVProgressHUD alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}

+ (void)setFixedCenter:(CGPoint)center {
    [SVProgressHUD sharedView].fixedPosition = center;
}

+ (void)setStatus:(NSString *)string {
	[[SVProgressHUD sharedView] setStatus:string];
}

#pragma mark - Show Methods

+ (void)show {
    [[SVProgressHUD sharedView] showWithStatus:nil maskType:SVProgressHUDMaskTypeClear networkIndicator:NO];
}


+ (void)showWithStatus:(NSString *)status {
//    [[SVProgressHUD sharedView] showWithStatus:status maskType:SVProgressHUDMaskTypeClear networkIndicator:NO];
    
    //更改等待器的默认图片
    [[SVProgressHUD sharedView]showImages:status WithMaskType:SVProgressHUDMaskTypeClear];
   
}

+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType {
    [[SVProgressHUD sharedView] showWithStatus:nil maskType:maskType networkIndicator:NO];
}

+ (void)showWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType {
   // [[SVProgressHUD sharedView] showWithStatus:status maskType:maskType networkIndicator:NO];
    
    //更改等待器的默认图片
     [[SVProgressHUD sharedView]showImages:status WithMaskType:maskType];
}

#pragma mark - Show then dismiss methods

+ (void)showSuccessWithStatus:(NSString *)string {
    [SVProgressHUD showImage:[UIImage imageNamed:@"SVProgressHUD.bundle/success.png"] status:string];
}

+ (void)showSuccessWithStatus:(NSString *)string duration:(NSTimeInterval)duration {
    [SVProgressHUD show];
    [SVProgressHUD showImage:[UIImage imageNamed:@"SVProgressHUD.bundle/success.png"] status:string duration:duration];
}

+ (void)showErrorWithStatus:(NSString *)string {
    [SVProgressHUD showImage:[UIImage imageNamed:@"SVProgressHUD.bundle/error.png"] status:string];
}

+ (void)showErrorWithStatus:(NSString *)string duration:(NSTimeInterval)duration {
    [SVProgressHUD show];
    [SVProgressHUD showImage:[UIImage imageNamed:@"SVProgressHUD.bundle/error.png"] status:string duration:duration];
}


+ (void)showImage:(UIImage *)image status:(NSString *)string {
    [[SVProgressHUD sharedView] showImage:image status:string duration:2];
}

+ (void)showImage:(UIImage *)image status:(NSString *)string duration:(NSTimeInterval)duration{
    [[SVProgressHUD sharedView] showImage:image status:string duration:duration];
}


#pragma mark - Dismiss Methods

+ (void)dismiss {
	[[SVProgressHUD sharedView] dismiss];
}

+ (void)dismissWithSuccess:(NSString*)string {
	[SVProgressHUD showSuccessWithStatus:string];
}

+ (void)dismissWithSuccess:(NSString *)string afterDelay:(NSTimeInterval)seconds {
    [[SVProgressHUD sharedView] showImage:[UIImage imageNamed:@"SVProgressHUD.bundle/success.png"] status:string duration:seconds];
}

+ (void)dismissWithError:(NSString*)string {
	[SVProgressHUD showErrorWithStatus:string];
}

+ (void)dismissWithError:(NSString *)string afterDelay:(NSTimeInterval)seconds {
    [[SVProgressHUD sharedView] showImage:[UIImage imageNamed:@"SVProgressHUD.bundle/error.png"] status:string duration:seconds];
}


#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
		self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
	
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    switch (self.maskType) {
            
        case SVProgressHUDMaskTypeBlack: {
            [[UIColor colorWithWhite:0 alpha:0.5] set];
            CGContextFillRect(context, self.bounds);
            break;
        }
            
        case SVProgressHUDMaskTypeGradient: {
            
            size_t locationsCount = 2;
            CGFloat locations[2] = {0.0f, 1.0f};
            CGFloat colors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f}; 
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
            CGColorSpaceRelease(colorSpace);
            
            CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
            float radius = MIN(self.bounds.size.width , self.bounds.size.height) ;
            CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient);
            
            break;
        }
    }
}

- (void)setStatus:(NSString *)string {
	
    CGFloat hudWidth = 100; //100
    CGFloat hudHeight = 100;
    CGFloat stringWidth = 0;
    CGFloat stringHeight = 0;
    CGRect labelRect = CGRectZero;
    
    
    if(string) {
        CGSize stringSize = [string sizeWithFont:self.stringLabel.font constrainedToSize:CGSizeMake(200, 300)];
        stringWidth = stringSize.width;
        stringHeight = stringSize.height;
       // hudHeight = 80+stringHeight;
        
        if(self.maskType != SVProgressHUDMaskTypeText){
            hudHeight = 80+stringHeight;
        }else{
            hudHeight = 30+stringHeight;
        }
        
        if(stringWidth > hudWidth)
            hudWidth = ceil(stringWidth/2)*2;
        
        if(hudHeight > 100) {
            labelRect = CGRectMake(12, 66, hudWidth, stringHeight);
            hudWidth+=24;
        } else {
            hudWidth+=24;  
            labelRect = CGRectMake(0, 66, hudWidth, stringHeight);   
        }
    }
	
	self.hudView.bounds = CGRectMake(0, 0, hudWidth, hudHeight);
	
    if(string) {
        self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, 36);
        self.gifImageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, 36);
    }
    else {
       	self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, CGRectGetHeight(self.hudView.bounds)/2);
        self.gifImageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, CGRectGetHeight(self.hudView.bounds)/2);
    }
	
	self.stringLabel.hidden = NO;
	self.stringLabel.text = string;
    
    if(self.maskType != SVProgressHUDMaskTypeText){
        self.stringLabel.frame = labelRect;
    }else{
        self.stringLabel.frame = CGRectMake(0, 0, hudWidth, hudHeight);
    }
	
	if(string)
		self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.hudView.bounds)/2)+0.5, 40.5);
	else
		self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.hudView.bounds)/2)+0.5, ceil(self.hudView.bounds.size.height/2)+0.5);
    
    
}

/** 更新弹框界面 */
- (void)setStatus_change:(NSString *)string {
    CGFloat margin = 20;
    CGFloat hudWidth = 150;
    CGFloat hudHeight = 120;
    CGFloat stringWidth = 0;
    CGFloat stringHeight = 0;
    CGRect labelRect = CGRectZero;
    
    if (string) {
        CGSize stringSize = [string sizeWithFont:self.stringLabel.font constrainedToSize:CGSizeMake(200, 300)];
        stringWidth = stringSize.width;
        stringHeight = stringSize.height;
        
        if(stringWidth > (150 - 2 * margin) && stringWidth <= (220 - 2 * margin)){
            hudWidth = stringWidth + 2 * margin;
        }
        
        if (stringWidth > (220 - 2 * margin)) {
            hudWidth = 220;
            hudHeight = 120 - 21.48 + stringHeight;
        }
        if (hudHeight>170) {
            hudHeight = 170;
            stringHeight = 68;
        }
        
        labelRect = CGRectMake(margin, 73, hudWidth - 2 * margin, stringHeight);
        
    }
    self.hudView.bounds = CGRectMake(0, 0, hudWidth, hudHeight);
    self.hudView.frame = CGRectMake(self.frame.size.width/2 - hudWidth/2, 180, hudWidth, hudHeight);
    CGPoint fixPoint = [SVProgressHUD sharedView].fixedPosition;
    
    if (!CGPointEqualToPoint(CGPointZero, fixPoint)) {
        self.hudView.center = fixPoint;
    }
    
    if(string) {
        self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, 43);
        self.gifImageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, 43);
        
    }
    else {
       	self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, CGRectGetHeight(self.hudView.bounds)/2);
        self.gifImageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, CGRectGetHeight(self.hudView.bounds)/2);
    }
    self.stringLabel.hidden = NO;
    self.stringLabel.text = string;
    
    if(self.maskType != SVProgressHUDMaskTypeText){
        
        self.stringLabel.frame = labelRect;
    }else{
        self.stringLabel.frame = CGRectMake(0, 0, hudWidth, hudHeight);
    }
    
}

- (void)setFadeOutTimer:(NSTimer *)newTimer {
    
    if(fadeOutTimer)
        [fadeOutTimer invalidate], fadeOutTimer = nil;
    
    if(newTimer)
        fadeOutTimer = newTimer;
}


- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(positionHUD:) 
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification 
                                               object:nil];  
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(positionHUD:) 
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(positionHUD:) 
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(positionHUD:) 
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(positionHUD:) 
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}


- (void)positionHUD:(NSNotification*)notification {
    
    CGFloat keyboardHeight;
    double animationDuration = 0.0;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(notification) {
        NSDictionary* keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [[keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        animationDuration = [[keyboardInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if(notification.name == UIKeyboardWillShowNotification || notification.name == UIKeyboardDidShowNotification) {
            if(UIInterfaceOrientationIsPortrait(orientation))
                keyboardHeight = keyboardFrame.size.height;
            else
                keyboardHeight = keyboardFrame.size.width;
        } else
            keyboardHeight = 0;
    } else {
        keyboardHeight = self.visibleKeyboardHeight;
    }
    
    CGRect orientationFrame = [UIScreen mainScreen].bounds;
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        float temp = orientationFrame.size.width;
        orientationFrame.size.width = orientationFrame.size.height;
        orientationFrame.size.height = temp;
        
        temp = statusBarFrame.size.width;
        statusBarFrame.size.width = statusBarFrame.size.height;
        statusBarFrame.size.height = temp;
    }
    
    CGFloat activeHeight = orientationFrame.size.height;
    
    if(keyboardHeight > 0)
        activeHeight += statusBarFrame.size.height*2;
    
    activeHeight -= keyboardHeight;
    CGFloat posY = floor(activeHeight*0.45);
    CGFloat posX = orientationFrame.size.width/2;
    
    CGPoint newCenter;
    CGFloat rotateAngle;
    
    switch (orientation) { 
        case UIInterfaceOrientationPortraitUpsideDown:
            rotateAngle = M_PI; 
            newCenter = CGPointMake(posX, orientationFrame.size.height-posY);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotateAngle = -M_PI/2.0f;
            newCenter = CGPointMake(posY, posX);
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotateAngle = M_PI/2.0f;
            newCenter = CGPointMake(orientationFrame.size.height-posY, posX);
            break;
        default: // as UIInterfaceOrientationPortrait
            rotateAngle = 0.0;
            newCenter = CGPointMake(posX, posY);
            break;
    } 
    
    if(notification) {
        [UIView animateWithDuration:animationDuration
                              delay:0 
                            options:UIViewAnimationOptionAllowUserInteraction 
                         animations:^{
                             [self moveToPoint:newCenter rotateAngle:rotateAngle];
                         } completion:NULL];
    } 
    
    else {
        [self moveToPoint:newCenter rotateAngle:rotateAngle];
    }
    
}

- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle {
    self.hudView.transform = CGAffineTransformMakeRotation(angle); 
    self.hudView.center = newCenter;
}

#pragma mark - Master show/dismiss methods

- (void)showWithStatus:(NSString*)string maskType:(SVProgressHUDMaskType)hudMaskType networkIndicator:(BOOL)show {
    if(!self.superview)
        [self.overlayWindow addSubview:self];
    
    [self stopGifImages]; //隐藏动态图片组
    self.fadeOutTimer = nil;
    self.imageView.hidden = YES;
    self.maskType = hudMaskType;
    
    //[self setStatus:string];
    [self setStatus_change:string];
    
    if(self.maskType != SVProgressHUDMaskTypeText){
        self.overlayWindow.backgroundColor = [UIColor clearColor];
        [self.spinnerView startAnimating];
        if(_tapParent)
            [self.overlayWindow removeGestureRecognizer:_tapParent];
    }else{
//        if(!_tapParent){
//            _tapParent = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
//        }
//        [self.overlayWindow addGestureRecognizer:_tapParent];
//        self.overlayWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self.spinnerView stopAnimating];
        self.fadeOutTimer = [NSTimer timerWithTimeInterval:1.5 target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.fadeOutTimer forMode:NSRunLoopCommonModes];
    }
    
    if(self.maskType != SVProgressHUDMaskTypeNone) {
        self.overlayWindow.userInteractionEnabled = YES;
    } else {
        self.overlayWindow.userInteractionEnabled = NO;
    }
    
    [self.overlayWindow setHidden:NO];
    [self positionHUD:nil];
    
    if(self.alpha != 1) {
        [self registerNotifications];
        self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1.3, 1.3);
        
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.3, 1/1.3);
                             self.alpha = 1;
                         }
                         completion:NULL];
    }
    
    [self setNeedsDisplay];
}


- (void)showImage:(UIImage *)image status:(NSString *)string duration:(NSTimeInterval)duration {
    if(![SVProgressHUD isVisible])
        [SVProgressHUD show];
    
    [self stopGifImages]; //隐藏动态图片组
    self.imageView.image = image;
    self.imageView.hidden = NO;
    //[self setStatus:string];
    [self setStatus_change:string];
    [self.spinnerView stopAnimating];
    
    self.fadeOutTimer = [NSTimer timerWithTimeInterval:duration target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.fadeOutTimer forMode:NSRunLoopCommonModes];
}


- (void)dismiss {
    [SVProgressHUD sharedView].fixedPosition = CGPointZero;
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 0.8, 0.8);
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         if(self.alpha == 0) {
                             [[NSNotificationCenter defaultCenter] removeObserver:self];
                             [hudView removeFromSuperview];
                             hudView = nil;
                             
                             [overlayWindow removeFromSuperview];
                             overlayWindow = nil;
  
                             [self stopGifImages];
   
                             // uncomment to make sure UIWindow is gone from app.windows
                             //DLog(@"%@", [UIApplication sharedApplication].windows);
                             //DLog(@"keyWindow = %@", [UIApplication sharedApplication].keyWindow);
                         }
                     }];
}

#pragma mark - Utilities

+ (BOOL)isVisible {
    return ([SVProgressHUD sharedView].alpha == 1);
}


#pragma mark - Getters

- (UIWindow *)overlayWindow {
    if(!overlayWindow) {
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.userInteractionEnabled = NO;
        
    }
    return overlayWindow;
}

- (UIView *)hudView {
    
    if(!hudView) {
        hudView = [[UIView alloc] initWithFrame:CGRectZero];
        hudView.layer.cornerRadius = 10;
		hudView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        hudView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                                    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
        
        [self addSubview:hudView];
    }
    return hudView;
}

- (UIImageView*)gifImageView {
    if (!_gifImageView) {
        _gifImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        _gifImageView.backgroundColor = [UIColor clearColor];
        
        NSMutableArray* ImgArr = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i=0; i<=65; i++) {
            @autoreleasepool {
                NSString* str = [NSString stringWithFormat:@"000%02d.png",i];
                UIImage* img = [UIImage imageNamed:str];
                if (img) {
                    [ImgArr addObject:img];
                }
            }
        }
        _gifImageView.animationImages = ImgArr;
        _gifImageView.animationDuration = 2;
        [self.hudView addSubview:_gifImageView];
    }
    
    return _gifImageView;
}

- (UILabel *)stringLabel {
    if (stringLabel == nil) {
        stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		stringLabel.textColor = [UIColor whiteColor];
		stringLabel.backgroundColor = [UIColor clearColor];
		stringLabel.adjustsFontSizeToFitWidth = YES;
		stringLabel.textAlignment = NSTextAlignmentCenter;
		stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		//stringLabel.font = [UIFont boldSystemFontOfSize:18];
        stringLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:18];
		stringLabel.shadowColor = [UIColor blackColor];
		stringLabel.shadowOffset = CGSizeMake(0, -1);
        stringLabel.numberOfLines = 0;
    }
    
    if(!stringLabel.superview)
        [self.hudView addSubview:stringLabel];
    
    return stringLabel;
}


- (UIImageView *)imageView {
    if (imageView == nil){
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        imageView.backgroundColor = [UIColor clearColor];
    }
    if(!imageView.superview)
        [self.hudView addSubview:imageView];
    
    return imageView;
}

- (UIActivityIndicatorView *)spinnerView {
    if (spinnerView == nil) {
        spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		spinnerView.hidesWhenStopped = YES;
		spinnerView.bounds = CGRectMake(0, 0, 37, 37);
    }
    
    if(!spinnerView.superview)
        [self.hudView addSubview:spinnerView];
    
    return spinnerView;
}

- (CGFloat)visibleKeyboardHeight {
        
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if(![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }

    // Locate UIKeyboard.  
    UIView *foundKeyboard = nil;
    for (__strong UIView *possibleKeyboard in [keyboardWindow subviews]) {
        
        // iOS 4 sticks the UIKeyboard inside a UIPeripheralHostView.
        if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"]) {
            possibleKeyboard = [[possibleKeyboard subviews] objectAtIndex:0];
        }                                                                                
        
        if ([[possibleKeyboard description] hasPrefix:@"<UIKeyboard"]) {
            foundKeyboard = possibleKeyboard;
            break;
        }
    }
        
    if(foundKeyboard && foundKeyboard.bounds.size.height > 100)
        return foundKeyboard.bounds.size.height;
    
    return 0;
}

- (void)stopGifImages {
    if (self.gifImageView) {
        [self.gifImageView stopAnimating];
        self.gifImageView.hidden = YES;
        self.gifImageView = nil;
    }
    //设回hudView颜色
    self.hudView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
}

- (void)showImages:(NSString*)str WithMaskType:(SVProgressHUDMaskType)maskType {
    [self stopGifImages];
    [self.fadeOutTimer invalidate];
    self.fadeOutTimer = nil;
    self.imageView.hidden = YES;
    [self dismiss];
   
    if (!self.superview) {
        [self.overlayWindow addSubview:self];
    }
    self.maskType = maskType;
    self.gifImageView.hidden = NO;
    self.hudView.bounds = CGRectMake(0, 0, self.gifImageView.bounds.size.width, self.gifImageView.bounds.size.height);
    self.backgroundColor = [UIColor clearColor];
    self.alpha = 0.8;
    if (str.length > 0) {
        self.hudView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        [self setStatus:str];
    }
    else {
        self.hudView.backgroundColor = [UIColor clearColor];
    }
    self.hudView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    [self.gifImageView startAnimating];
    [self positionHUD:nil];
    [self registerNotifications];
    [self.overlayWindow setHidden:NO];
    [self setNeedsDisplay];
    
    if (self.maskType != SVProgressHUDMaskTypeNone) {
        //截获用户点击事件
        self.overlayWindow.userInteractionEnabled = YES;
    }
    else {
        self.overlayWindow.userInteractionEnabled = NO;
    }
}

//+ (void)showImagesWithStatus:(NSString*)string {
//    [[SVProgressHUD sharedView] showImages:string WithMaskType:SVProgressHUDMaskTypeClear];
//}
//
//+ (void)showImagesWithStatus:(NSString*)string Type:(SVProgressHUDMaskType)maskType {
//    [[SVProgressHUD sharedView] showImages:string WithMaskType:maskType];
//}




@end
