#import <substrate.h>
#import <UIKit/UIKit.h>

#import "UIImage+Colorize.h"
#import "Private.h"

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

#define kBackdropNCStyle 0x2B2A
#define kBackdropCCStyle 0x080C

extern "C" void                      _SBControlCenterControlSettingsDidChangeForKey(NSString * key);
extern "C" UIColor *                 _SBUIControlCenterControlColorForState(int state);
extern "C" NSInteger                 _SBUIControlCenterControlBlendModeForState(int state);
extern "C" CGFloat                   _SBUIControlCenterControlAlphaForState(int state);
extern "C" SBControlCenterSettings * _SBControlCenterSettings(void);

static UIColor * (*original__SBUIControlCenterControlColorForState)(int state);
static CGFloat   (*original__SBUIControlCenterControlAlphaForState)(int state);

%hook SBControlCenterSettings

- (BOOL)backgroundDarkensCC {

    if (!STTweakEnabled)
        return %orig;

    return NO;

}

%end

%hook SBUIControlCenterSlider

+ (id)_knobImage {

    id image = %orig;

    if (!STTweakEnabled || !STCCForegroundColor)
        return image;

    return [image imageMaskedWithColor:STCCForegroundColor];

}

%end

void SBControlCenterContentContainerViewReplaceBackdrop(SBControlCenterContentContainerView * view) {

    _UIBackdropView * &_originalBackdrop = MSHookIvar<_UIBackdropView *>(view, "_backdropView");

    if (!_originalBackdrop)
        return;

    BOOL reloadBackdrop = NO;
    BOOL _useNCStyle = STCCUseNotificationCenterStyle;

    [[_originalBackdrop inputSettings] setColorTint:STCCTintColor];
    [[_originalBackdrop inputSettings] setColorTintAlpha:STCCTintAlpha];

    if ([_originalBackdrop groupName] && [[_originalBackdrop groupName] isEqualToString:@"PNCustomBackdrop"]) {
        
        if (STTweakEnabled) {

            reloadBackdrop = !STCCUseNotificationCenterStyle;

        } else {

            reloadBackdrop = YES;
            _useNCStyle = NO;

        }

    } else if ([_originalBackdrop groupName] && [[_originalBackdrop groupName] isEqualToString:@"ControlCenter"]) {

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

    if (STCCGrabberStyle == CCGrabberStyleTint && !STCCGrabberTintColor)
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

CGFloat PN_SBUIControlCenterControlAlphaForState(int state) {

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

    if (state == UIControlStateHighlighted) {
        return STCCHighlightColor ?: original__SBUIControlCenterControlColorForState(state);
    } else 
        return STCCForegroundColor ?: original__SBUIControlCenterControlColorForState(state);

}

NSInteger PN_SBUIControlCenterControlBlendModeForState(int state) {

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

        SBControlCenterViewController * _viewController = MSHookIvar<SBControlCenterViewController *>(ccController, "_viewController");

        if (_viewController) {

            SBControlCenterContainerView * _containerView = MSHookIvar<SBControlCenterContainerView *>(_viewController, "_containerView");
            SBControlCenterContentContainerView * contentContainerView = [_containerView contentContainerView];

            SBControlCenterContentContainerViewReplaceBackdrop(contentContainerView);

            SBControlCenterContentView * _contentView = MSHookIvar<SBControlCenterContentView *>(_viewController, "_contentView");

            if (_contentView && [_contentView grabberView])
                SBControlCenterGrabberViewStyle([[_contentView grabberView] chevronView]);

        }

    }

    _SBControlCenterControlSettingsDidChangeForKey(@"highlight");
    _SBControlCenterControlSettingsDidChangeForKey(@"highlightColor");
    _SBControlCenterControlSettingsDidChangeForKey(@"controlAlpha");

}

static void reloadSettings() {

    NSDictionary * _settingsPlist = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.pNre.uniformity.plist"];

    if ([_settingsPlist objectForKey:@"TweakEnabled"])
        STTweakEnabled = [[_settingsPlist objectForKey:@"TweakEnabled"] boolValue];

    if ([_settingsPlist objectForKey:@"CCUseNotificationCenterStyle"])
        STCCUseNotificationCenterStyle = [[_settingsPlist objectForKey:@"CCUseNotificationCenterStyle"] boolValue];
    
    if ([_settingsPlist objectForKey:@"CCGrabberStyle"])
        STCCGrabberStyle = [[_settingsPlist objectForKey:@"CCGrabberStyle"] integerValue];

    if ([_settingsPlist objectForKey:@"CCContentNormalAlpha"])
        STCCContentNormalAlpha = [[_settingsPlist objectForKey:@"CCContentNormalAlpha"] floatValue];

    if ([_settingsPlist objectForKey:@"CCContentHighlightedAlpha"])
        STCCContentHighlightedAlpha = [[_settingsPlist objectForKey:@"CCContentHighlightedAlpha"] floatValue];
    
    if ([_settingsPlist objectForKey:@"CCContentDisabledAlpha"])
        STCCContentDisabledAlpha = [[_settingsPlist objectForKey:@"CCContentDisabledAlpha"] floatValue];

    if ([_settingsPlist objectForKey:@"CCTintAlpha"])
        STCCTintAlpha = [[_settingsPlist objectForKey:@"CCTintAlpha"] floatValue];

    if ([_settingsPlist objectForKey:@"CCForegroundColor"]) {

        if (STCCForegroundColor)
            [STCCForegroundColor release];

        STCCForegroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:[_settingsPlist objectForKey:@"CCForegroundColor"]];
        
        if ([STCCForegroundColor isKindOfClass:[NSNull class]])
            STCCForegroundColor = STTweakEnabled && STCCUseNotificationCenterStyle ? [[UIColor colorWithWhite:0.90 alpha:1.] retain] : nil;
        else
            [STCCForegroundColor retain];

    }

    if ([_settingsPlist objectForKey:@"CCHighlightColor"]) {

        if (STCCHighlightColor)
            [STCCHighlightColor release];

        STCCHighlightColor = [NSKeyedUnarchiver unarchiveObjectWithData:[_settingsPlist objectForKey:@"CCHighlightColor"]];

        if ([STCCHighlightColor isKindOfClass:[NSNull class]])
            STCCHighlightColor = nil;
        else
            [STCCHighlightColor retain];

    }

    if ([_settingsPlist objectForKey:@"CCTintColor"]) {
        if (STCCTintColor)
            [STCCTintColor release];

        STCCTintColor = [NSKeyedUnarchiver unarchiveObjectWithData:[_settingsPlist objectForKey:@"CCTintColor"]];
        
        if ([STCCTintColor isKindOfClass:[NSNull class]])
            STCCTintColor = nil;
        else
            [STCCTintColor retain];

    }

    if ([_settingsPlist objectForKey:@"CCGrabberTintColor"]) {
        if (STCCGrabberTintColor)
            [STCCGrabberTintColor release];

        STCCGrabberTintColor = [NSKeyedUnarchiver unarchiveObjectWithData:[_settingsPlist objectForKey:@"CCGrabberTintColor"]];
        
        if ([STCCGrabberTintColor isKindOfClass:[NSNull class]])
            STCCGrabberTintColor = nil;
        else
            [STCCGrabberTintColor retain];

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

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadSettingsNotification, CFSTR("com.pNre.uniformity/settingsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);

    reloadSettings();

    %init;

    [pool release];

}

