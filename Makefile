THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222

SCHEMA = DEBUG

TARGET = iphone:clang::7.0

include theos/makefiles/common.mk

export ARCHS = armv7 arm64

TWEAK_NAME = Uniformity
Uniformity_FILES = Tweak.xm
Uniformity_FRAMEWORKS = UIKit CoreGraphics QuartzCore
Uniformity_PRIVATE_FRAMEWORKS = SpringBoardUI
Uniformity_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall SpringBoard"
SUBPROJECTS += uniformityprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
