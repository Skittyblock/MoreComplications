export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:16.0

INSTALL_TARGET_PROCESSES = SpringBoard PosterBoard
SUBPROJECTS = tweak prefs

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
