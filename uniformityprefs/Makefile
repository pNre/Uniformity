TARGET = iphone:clang::7.0

include theos/makefiles/common.mk

export ARCHS = armv7 armv7s arm64

BUNDLE_NAME = UniformityPrefs
UniformityPrefs_FILES = UniformityPrefs.mm UIColor+Crayola.m UIColor+Compare.m \
	UniformityColorSelectorCCForeground.mm UniformityColorSelectorCCHighlight.mm UniformityColorSelectorCCTint.mm UniformityColorSelector.mm
UniformityPrefs_INSTALL_PATH = /Library/PreferenceBundles
UniformityPrefs_FRAMEWORKS = UIKit CoreGraphics
UniformityPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/UniformityPrefs.plist$(ECHO_END)
