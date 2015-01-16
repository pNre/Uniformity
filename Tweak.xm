#import <substrate.h>
#import <UIKit/UIKit.h>

#import "Private.h"
#import "Uniformity.h"

enum {

    CCGrabberStyleDefault = 0,
    CCGrabberStyleNC,
    CCGrabberStyleTint,
    CCGrabberStyleHidden

};

static BOOL SettingsLoaded = NO;
static BOOL STTweakEnabled = YES;

static BOOL STCCUseNotificationCenterStyle = NO;
static NSUInteger STCCGrabberStyle = CCGrabberStyleNC;

static CGFloat STCCContentNormalAlpha = 0.4;
static CGFloat STCCContentHighlightedAlpha = 0.8;
static CGFloat STCCContentDisabledAlpha = 0.1;
static CGFloat STCCTintAlpha = 0.1;

static UIColor * STCCForegroundColor = nil;
static UIColor * STCCHighlightColor = nil;
static UIColor * STCCTintColor = nil;
static UIColor * STCCGrabberTintColor = nil;

static BOOL STCCThumbColor = YES;

#define kBackdropNCStyle 0x2B2A
#define kBackdropCCStyle 0x080C

extern "C" NSString * const kCAFilterPlusD;

extern "C" void                      _SBControlCenterControlSettingsDidChangeForKey(NSString * key);
extern "C" UIColor *                 _SBUIControlCenterControlColorForState(int state);
extern "C" NSInteger                 _SBUIControlCenterControlBlendModeForState(int state);
extern "C" CGFloat                   _SBUIControlCenterControlAlphaForState(int state);
extern "C" SBControlCenterSettings * _SBControlCenterSettings(void);

extern "C" void                      SBUIControlCenterControlConfigureForState(int state);

static UIColor * (*original__SBUIControlCenterControlColorForState)(int state);
static CGFloat   (*original__SBUIControlCenterControlAlphaForState)(int state);

%hook SBControlCenterSettings

- (BOOL)backgroundDarkensCC {

    if (!STTweakEnabled)
        return %orig;

    return NO;

}

%end

@interface SBUIControlCenterSlider (Uniformity)

- (void)fixThumbView;

@end

%hook SBUIControlCenterSlider

+ (UIImage *)_knobImage {

    id image = %orig;

    if (!STTweakEnabled || (!STCCForegroundColor && STCCThumbColor) || (!STCCHighlightColor && !STCCThumbColor))
        return image;

    return [image _flatImageWithColor:(STCCThumbColor ? STCCForegroundColor : STCCHighlightColor)];

}

%new
- (void)fixThumbView {
    UIView * _thumbView = MSHookIvar<UIView *>(self, "_thumbView");
    CGRect frame = _thumbView.frame;
    frame.origin.x += [%c(SBUIControlCenterSlider) _knobImage].size.width / 2.f;
    _thumbView.frame = frame;
}

- (void)layoutSubviews {
    %orig;

    if (STTweakEnabled)
        [self fixThumbView];
}

- (void)_initSubviews {
    %orig;

    if (STTweakEnabled)
        [self fixThumbView];
}

%end

void SBControlCenterContentContainerViewReplaceBackdrop(SBControlCenterContentContainerView * view) {

    _UIBackdropView * &_originalBackdrop = MSHookIvar<_UIBackdropView *>(view, "_backdropView");

    if (!_originalBackdrop)
        return;

    if ([[_originalBackdrop groupName] isEqualToString:@"ControlCenter"] && !STTweakEnabled)
        return;

    BOOL reloadBackdrop = NO;
    BOOL _useNCStyle = STCCUseNotificationCenterStyle;

    [[_originalBackdrop inputSettings] setColorTint:STCCTintColor];
    [[_originalBackdrop inputSettings] setColorTintAlpha:STCCTintAlpha];

    if ([[_originalBackdrop groupName] isEqualToString:@"PNCustomBackdrop"]) {

        if (STTweakEnabled) {

            reloadBackdrop = !STCCUseNotificationCenterStyle;

        } else {

            reloadBackdrop = YES;
            _useNCStyle = NO;

        }

    } else if ([[_originalBackdrop groupName] isEqualToString:@"ControlCenter"]) {

        reloadBackdrop = STCCUseNotificationCenterStyle && STTweakEnabled;

    }

    if (reloadBackdrop) {

        [_originalBackdrop removeFromSuperview];
        [_originalBackdrop release];

        if (_useNCStyle) {

            _originalBackdrop = [[_UIBackdropView alloc] initWithPrivateStyle:kBackdropNCStyle];
            [_originalBackdrop setGroupName:@"PNCustomBackdrop"];

            if (STCCTintColor) {
                [[_originalBackdrop inputSettings] setColorTint:STCCTintColor];
                [[_originalBackdrop inputSettings] setColorTintAlpha:STCCTintAlpha];
            }

        } else {

            _originalBackdrop = [[_UIBackdropView alloc] initWithPrivateStyle:kBackdropCCStyle];
            [_originalBackdrop setGroupName:@"ControlCenter"];

        }

        [_originalBackdrop setAppliesOutputSettingsAnimationDuration:1.0];

        [view insertSubview:_originalBackdrop atIndex:0];

    }

}

%hook SBControlCenterContentContainerView

- (id)initWithFrame:(CGRect)frame {

    self = %orig;

    if (self && STTweakEnabled) {

        SBControlCenterContentContainerViewReplaceBackdrop(self);

    }

    return self;

}

%end

%hook SBControlCenterGrabberView

static void SBControlCenterGrabberViewStyle(SBChevronView * chevronView) {

    if (!chevronView)
        return;

    if ((STCCGrabberStyle == CCGrabberStyleTint && !STCCGrabberTintColor) || !STTweakEnabled)
        STCCGrabberStyle = CCGrabberStyleDefault;

    [chevronView setHidden:NO];

    switch (STCCGrabberStyle) {
        case CCGrabberStyleNC:
            [chevronView setColor:[UIColor colorWithWhite:0.52 alpha:1.]];
            [chevronView _setDrawsAsBackdropOverlayWithBlendMode:kCGBlendModeOverlay];
        break;
        case CCGrabberStyleTint:
            [chevronView setColor:STCCGrabberTintColor];
            [chevronView _setDrawsAsBackdropOverlayWithBlendMode:kCGBlendModeNormal];
        break;
        case CCGrabberStyleHidden:
            [chevronView setHidden:YES];
        break;
        default:
            [chevronView setColor:_SBUIControlCenterControlColorForState(UIControlStateNormal)];
            [chevronView _setDrawsAsBackdropOverlayWithBlendMode:kCGBlendModeNormal];
    }

}

- (SBControlCenterGrabberView *)initWithFrame:(CGRect)frame {

    self = %orig;

    if (self && STTweakEnabled && [self chevronView]) {

        SBControlCenterGrabberViewStyle([self chevronView]);

    }

    return self;

}

%end

%hook SBUIControlCenterButton

- (void)_updateGlyphForStateChange {

    if (!STTweakEnabled)
        return %orig;

    NSInteger currentState = [self _currentState];
    UIImage * glyphImage = [[self _glyphImageForState:currentState] _flatImageWithColor:_SBUIControlCenterControlColorForState(currentState)];

    CGRect glyphRect = [self _rectForGlyph:glyphImage centeredInRect:[self bounds]];

    UIImageView * _glyphImageView = MSHookIvar<UIImageView *>(self, "_glyphImageView");
    [[_glyphImageView layer] setCompositingFilter:nil];

    _glyphImageView.frame = glyphRect;
    _glyphImageView.image = glyphImage;

    if (![self isEnabled])
        _glyphImageView.alpha = STCCContentDisabledAlpha;
    else
        _glyphImageView.alpha = [self _drawingAsSelected] ? STCCContentHighlightedAlpha : STCCContentNormalAlpha;

}

%end

CGFloat PN_SBUIControlCenterControlAlphaForState(int state) {

    _L(@"Control center control alpha for state %d", state);

    if (!STTweakEnabled || !SettingsLoaded)
        return original__SBUIControlCenterControlAlphaForState(state);

    if (state == UIControlStateHighlighted)
        return STCCContentHighlightedAlpha;
    else if (state == UIControlStateDisabled)
        return STCCContentDisabledAlpha;
    else
        return STCCContentNormalAlpha;

}

UIColor * PN_SBUIControlCenterControlColorForState(int state) {

    if (!STTweakEnabled || !SettingsLoaded)
        return original__SBUIControlCenterControlColorForState(state);

    _L(@"Control center color for state %d", state);

    if (state == UIControlStateHighlighted) {
        return STCCHighlightColor ?: original__SBUIControlCenterControlColorForState(state);
    } else
        return STCCForegroundColor ?: original__SBUIControlCenterControlColorForState(state);

}

NSInteger PN_SBUIControlCenterControlBlendModeForState(int state) {

    _L(@"Blend mode for state %d", state);

    if (STTweakEnabled && SettingsLoaded)
        return kCGBlendModeNormal;

    if (state == UIControlStateNormal || state == UIControlStateDisabled) {

        CGFloat scale = [[UIScreen mainScreen] scale];

        if (scale >= 2.) {
            return kCGBlendModeMultiply;
        }

    } else if (state == UIControlStateHighlighted) {

        SBControlCenterSettings * settings = _SBControlCenterSettings();

        if ([settings highlightUsesPlusL])
            return kCGBlendModeScreen;

    }

    return kCGBlendModeNormal;

}

static void applyChanges() {

    //  Control center
    SBControlCenterController * ccController = [%c(SBControlCenterController) sharedInstanceIfExists];

    if (ccController)  {
        UIView * _rootView = MSHookIvar<UIView *>(ccController, "_rootView");
        SBControlCenterViewController * _viewController = MSHookIvar<SBControlCenterViewController *>(ccController, "_viewController");

        [ccController removeObserver:_viewController];
        ccController.view = nil;

        _viewController.view = nil;

        [_rootView removeFromSuperview];
    }

}

//  The return value of this function needs deallocation
static inline id CFPreferencesValue(NSString * key) {
    return (id)CFPreferencesCopyAppValue((CFStringRef)key, kAppId);
}

static inline BOOL CFPreferencesBool(NSString * key, BOOL def) {
    Boolean found = false;
    Boolean value = CFPreferencesGetAppBooleanValue((CFStringRef)key, kAppId, &found);
    return found ? value : def;
}

static inline NSInteger CFPreferencesInteger(NSString * key, NSInteger def) {
    Boolean found = false;
    NSInteger value = (NSInteger)CFPreferencesGetAppIntegerValue((CFStringRef)key, kAppId, &found);
    return found ? value : def;
}

static inline CGFloat CFPreferencesFloat(NSString * key, CGFloat def) {
    NSNumber * value = CFPreferencesValue(key);

    if (!value)
        return def;

    CGFloat floatValue = [value floatValue];
    CFRelease(value);

    return floatValue;
}

static void reloadSettings() {

    _L(@"Reloading settings");

    STTweakEnabled = CFPreferencesBool(@"TweakEnabled", YES);
    STCCUseNotificationCenterStyle = CFPreferencesBool(@"CCUseNotificationCenterStyle", NO);
    STCCGrabberStyle = CFPreferencesInteger(@"CCGrabberStyle", CCGrabberStyleNC);
    STCCContentNormalAlpha = CFPreferencesFloat(@"CCContentNormalAlpha", 0.4);
    STCCContentHighlightedAlpha = CFPreferencesFloat(@"CCContentHighlightedAlpha", 0.8);
    STCCContentDisabledAlpha = CFPreferencesFloat(@"CCContentDisabledAlpha", 0.1);
    STCCTintAlpha = CFPreferencesFloat(@"CCTintAlpha", 0.1);
    STCCThumbColor = CFPreferencesBool(@"CCThumbColor", YES);

    NSData * archivedData = nil;

    if ((archivedData = (NSData *)CFPreferencesValue(@"CCForegroundColor"))) {

        if (STCCForegroundColor)
            [STCCForegroundColor release];

        STCCForegroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];

        if ([STCCForegroundColor isKindOfClass:[NSNull class]])
            STCCForegroundColor = STTweakEnabled && STCCUseNotificationCenterStyle ? [[UIColor colorWithWhite:0.90 alpha:1.] retain] : nil;
        else
            [STCCForegroundColor retain];

        CFRelease(archivedData);

    }

    if ((archivedData = (NSData *)CFPreferencesValue(@"CCHighlightColor"))) {

        if (STCCHighlightColor)
            [STCCHighlightColor release];

        STCCHighlightColor = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];

        if ([STCCHighlightColor isKindOfClass:[NSNull class]])
            STCCHighlightColor = nil;
        else
            [STCCHighlightColor retain];

        CFRelease(archivedData);

    }

    if ((archivedData = (NSData *)CFPreferencesValue(@"CCTintColor"))) {

        if (STCCTintColor)
            [STCCTintColor release];

        STCCTintColor = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];

        if ([STCCTintColor isKindOfClass:[NSNull class]])
            STCCTintColor = nil;
        else
            [STCCTintColor retain];

        CFRelease(archivedData);

    }

    if ((archivedData = (NSData *)CFPreferencesValue(@"CCGrabberTintColor"))) {

        if (STCCGrabberTintColor)
            [STCCGrabberTintColor release];

        STCCGrabberTintColor = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];

        if ([STCCGrabberTintColor isKindOfClass:[NSNull class]])
            STCCGrabberTintColor = nil;
        else
            [STCCGrabberTintColor retain];

        CFRelease(archivedData);

    }

    SettingsLoaded = YES;

    applyChanges();

}

static void reloadSettingsNotification(CFNotificationCenterRef notificationCenterRef, void * arg1, CFStringRef arg2, const void * arg3, CFDictionaryRef dictionary)
{
    reloadSettings();
}

%ctor {

    MSHookFunction((void *)_SBUIControlCenterControlBlendModeForState, (void *)PN_SBUIControlCenterControlBlendModeForState, (void **)NULL);
    MSHookFunction(_SBUIControlCenterControlColorForState, PN_SBUIControlCenterControlColorForState, &original__SBUIControlCenterControlColorForState);
    MSHookFunction(_SBUIControlCenterControlAlphaForState, PN_SBUIControlCenterControlAlphaForState, &original__SBUIControlCenterControlAlphaForState);

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadSettingsNotification, CFSTR("co.pNre.uniformity/settingsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);

    reloadSettings();

    %init;

    [pool release];

}
