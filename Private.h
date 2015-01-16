UIKIT_EXTERN NSBundle * SpringBoardUIBundle(void);

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

@property (assign) double controlAlpha;
@property (assign) double controlAlpha1x;
@property (assign) double minControlAlpha;
@property (assign) double maxControlAlpha;
@property (assign) double disabledAlpha;
@property (assign) double disabledAlpha1x;
@property (assign) double highlightAlpha;
@property (assign) BOOL highlightUsesPlusL;
@property (assign) BOOL forceVibrantControls;
@property (assign) double glowAlpha;
@property (retain) UIColor * highlightColor;
@property (assign) BOOL useNewBounce;
@property (assign) double oldBounceFriction;
@property (assign) double bounceDensityFactor;
@property (assign) double bounceResistance;
@property (assign) double minVelocity;
@property (assign) double maxVelocity;
@property (assign) double attachmentThreshold;
@property (assign) double attachmentFrequencyAbove;
@property (assign) double attachmentFrequencyBelow;
@property (assign) double attachmentVelocityDamping;
@property (assign) double attachmentMinDamping;
@property (assign) double attachmentMaxDamping;
@property (assign) double backgroundAlphaFactor;

+ (id)settingsControllerModule;

- (void)settings:(id)settings changedValueForKeyPath:(id)keyPath;

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
- (id)settingsSection;

- (id)grabberView;

@end

@interface SBControlCenterContainerView : UIView
- (SBControlCenterContentContainerView *)contentContainerView;
@end

@interface SBControlCenterViewController : UIViewController {
    SBControlCenterContainerView * _containerView;
    SBControlCenterContentView * _contentView;
}
@end

@interface SBControlCenterController : UIViewController {
    SBControlCenterViewController * _viewController;
}

- (void)addObserver:(id)observer;
- (void)removeObserver:(id)observer;

+ (id)sharedInstanceIfExists;
+ (id)sharedInstance;

- (void)_enumerateObservers:(/*^block*/id)enumerator;

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

@interface SBUIControlCenterButton : UIButton

- (NSInteger)_currentState;
- (UIImage *)_glyphImageForState:(NSInteger)state;

- (CGRect)_rectForGlyph:(id)glyph centeredInRect:(CGRect)rect;

- (BOOL)isCircleButton;
- (BOOL)useSmallButton;
- (BOOL)isRectButton;

- (BOOL)_drawingAsSelected;

@end

@interface SBUIControlCenterSlider : UISlider

+ (UIImage *)_knobImage;

- (void)controlAppearanceDidChangeForState:(NSInteger)state;

@end


@interface UIImage (Flat_and_Bundle)

+ (id)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;

- (UIImage *)_flatImageWithColor:(UIColor *)color;

@end
