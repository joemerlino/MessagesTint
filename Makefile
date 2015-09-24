include theos/makefiles/common.mk

TWEAK_NAME = MessagesTint
MessagesTint_FILES = Tweak.xm
MessagesTint_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += messagestintprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
