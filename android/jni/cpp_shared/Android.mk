LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := c++_shared
LOCAL_SRC_FILES := ../../prebuilt-libs/$(TARGET_ARCH_ABI)/libc++_shared.so
LOCAL_PREBUILT_SHARED_LIBRARY := true
include $(PREBUILT_SHARED_LIBRARY)