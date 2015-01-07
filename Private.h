@interface UIView (Blend)

- (void)_setDrawsAsBackdropOverlayWithBlendMode:(CGBlendMode)blendMode;

@end

@interface _UIBackdropViewSettings : NSObject

- (void)setColorTintAlpha:(CGFloat)alpha;
- (void)setColorTint:(UIColor *)tint;

@end

@interface _UIBackdropView : UIView

- (_UIBackdropViewSettings *)outputSettings;
- (_UIBackdropViewSettings *)inputSettings;

- (instancetype)initWithPrivateStyle:(NSInteger)style;

- (void)setAppliesOutputSettingsAnimationDuration:(CGFloat)duration;

- (void)setComputesColorSettings:(BOOL)val;
- (void)setSimulatesMasks:(BOOL)val;

- (NSString *)groupName;
- (void)setGroupName:(NSString *)groupName;

@end

@interface SBControlCenterSettings : NSObject

@property BOOL highlightUsesPlusL;

@property CGFloat controlAlpha;

@end

@interface SBControlCenterContentContainerView : UIView {
    _UIBackdropView * _backdropView;
}
@end

@interface SBChevronView : UIView
@property (nonatomic,retain) UIColor * color;
@end

@interface SBControlCenterGrabberView : UIView
- (SBChevronView *)chevronView;
@end

@interface SBControlCenterContentView : UIView {
    SBControlCenterGrabberView * _grabberView;
}

- (void)updateEnabledSections;
- (id)_allSections;

- (id)grabberView;

@end

@interface SBControlCenterContainerView : UIView
- (SBControlCenterContentContainerView *)contentContainerView;
@end

@interface SBControlCenterViewController : NSObject {
    SBControlCenterContainerView * _containerView;
    SBControlCenterContentView * _contentView;
}
@end

@interface SBControlCenterController : NSObject {
    SBControlCenterViewController * _viewController;
}

+ (id)sharedInstanceIfExists;
+ (id)sharedInstance;

@end

@interface SBNotificationCenterViewController : NSObject {
    _UIBackdropView * _backgroundView;
}

- (id)_newBackgroundView;

@end

@interface SBNotificationCenterController : NSObject {
    SBNotificationCenterViewController * _viewController;
}

+ (id)sharedInstanceIfExists;
+ (id)sharedInstance;

@end

@interface SBUIControlCenterButton : UIView

- (NSInteger)_currentState;
- (UIImage *)_glyphImageForState:(NSInteger)state;

- (CGRect)_rectForGlyph:(id)glyph centeredInRect:(CGRect)rect;

- (BOOL)isCircleButton;
- (BOOL)useSmallButton;
- (BOOL)isRectButton;

- (BOOL)_drawingAsSelected;

@end

@interface UIImage (Flat)

- (UIImage *)_flatImageWithColor:(UIColor *)color;

@end
