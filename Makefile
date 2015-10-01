THEOS_DEVICE_IP = 192.168.2.7
ARCHS = armv7 arm64

TARGET = iphone:clang:latest:6.0

include theos/makefiles/common.mk

TWEAK_NAME = MessagesTint
MessagesTint_FILES = Tweak.xm
MessagesTint_FRAMEWORKS = UIKit
MessagesTint_LIBRARIES = colorpicker

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += messagestintprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
