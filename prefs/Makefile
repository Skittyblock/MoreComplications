TARGET = iphone:clang:latest:12.0 # need to set lower deployment target for skittyprefs

BUNDLE_NAME = MoreComplications
MoreComplications_FILES = $(wildcard *.m) $(wildcard SkittyPrefs/*.m)
MoreComplications_FRAMEWORKS = UIKit
MoreComplications_PRIVATE_FRAMEWORKS = Preferences
MoreComplications_INSTALL_PATH = /Library/PreferenceBundles
MoreComplications_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/MoreComplications.plist$(ECHO_END)
