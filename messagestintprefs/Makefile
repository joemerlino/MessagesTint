ARCHS = armv7 arm64
TARGET = iphone:clang:latest:6.0

include theos/makefiles/common.mk

BUNDLE_NAME = MessagesTintPrefs
MessagesTintPrefs_FILES = MessagesTintPrefs.mm
MessagesTintPrefs_INSTALL_PATH = /Library/PreferenceBundles
MessagesTintPrefs_FRAMEWORKS = UIKit
MessagesTintPrefs_PRIVATE_FRAMEWORKS = Preferences
MessagesTintPrefs_LIBRARIES = colorpicker
include $(THEOS_MAKE_PATH)/bundle.mk

THEOS_PACKAGE_BASE_VERSION = 0.0.2
_THEOS_INTERNAL_PACKAGE_VERSION = 0.0.2

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/MessagesTintPrefs.plist$(ECHO_END)
