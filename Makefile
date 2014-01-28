THEOS_DEVICE_IP = 192.168.1.247

TARGET = iphone:clang::7.0

include theos/makefiles/common.mk

export ARCHS = armv7 armv7s arm64

TWEAK_NAME = Uniformity
Uniformity_FILES = Tweak.xm UIImage+Colorize.m
Uniformity_FRAMEWORKS = UIKit CoreGraphics QuartzCore
Uniformity_PRIVATE_FRAMEWORKS = SpringBoardUI

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "sbreload"
SUBPROJECTS += uniformityprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
