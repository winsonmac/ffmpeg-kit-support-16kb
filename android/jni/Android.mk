MY_LOCAL_PATH := $(call my-dir)

# Include prebuilt c++_shared library
include $(MY_LOCAL_PATH)/cpp_shared/Android.mk

$(call import-add-path, $(MY_LOCAL_PATH))

include $(MY_LOCAL_PATH)/build.mk

MY_ARMV7 := false
MY_ARMV7_NEON := false
ifeq ($(TARGET_ARCH_ABI), armeabi-v7a)
    MY_ARMV7 := ${ARMV7}
    MY_ARMV7_NEON := ${ARMV7_NEON}
endif

# DEFINE ARCH FLAGS
MY_ARM_MODE := arm
MY_ARM_NEON := false
ifeq ($(TARGET_ARCH_ABI), armeabi-v7a)
    MY_ARCH_FLAGS := ARM_V7A
    MY_ARM_NEON := true
    ifeq ($(MY_ARMV7_NEON), true)
        MY_BUILD_DIR := $(ARMV7_NEON_BUILD_PATH)
    else
        MY_BUILD_DIR := $(ARMV7_BUILD_PATH)
    endif
endif
ifeq ($(TARGET_ARCH_ABI), arm64-v8a)
    MY_ARCH_FLAGS := ARM64_V8A
    MY_ARM_NEON := true
    MY_BUILD_DIR := $(ARM64_BUILD_PATH)
endif
ifeq ($(TARGET_ARCH_ABI), x86)
    MY_ARCH_FLAGS := X86
    MY_ARM_NEON := true
    MY_BUILD_DIR := $(X86_BUILD_PATH)
endif
ifeq ($(TARGET_ARCH_ABI), x86_64)
    MY_ARCH_FLAGS := X86_64
    MY_ARM_NEON := true
    MY_BUILD_DIR := $(X86_64_BUILD_PATH)
endif
FFMPEG_INCLUDES := $(MY_LOCAL_PATH)/../../prebuilt/$(MY_BUILD_DIR)/ffmpeg/include
LOCAL_PATH := $(MY_LOCAL_PATH)/../ffmpeg-kit-android-lib/src/main/cpp

# 16 kb page size support for arm64-v8a and x86_64
ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
    MY_LDFLAGS := -Wl,-z,max-page-size=16384
else ifeq ($(TARGET_ARCH_ABI),x86_64)
    MY_LDFLAGS := -Wl,-z,max-page-size=16384
endif

include $(CLEAR_VARS)
LOCAL_ARM_MODE := $(MY_ARM_MODE)
LOCAL_MODULE := ffmpegkit_abidetect
LOCAL_SRC_FILES := ffmpegkit_abidetect.c
LOCAL_CFLAGS := -Wall -Wextra -Werror -Wno-unused-parameter -DFFMPEG_KIT_${MY_ARCH_FLAGS}
LOCAL_C_INCLUDES := $(FFMPEG_INCLUDES)
LOCAL_LDFLAGS := $(MY_LDFLAGS)
LOCAL_LDLIBS := -llog -lz -landroid
LOCAL_STATIC_LIBRARIES := cpu-features
LOCAL_ARM_NEON := ${MY_ARM_NEON}
include $(BUILD_SHARED_LIBRARY)

$(call import-module, cpu-features)

MY_SRC_FILES := ffmpegkit.c ffprobekit.c ffmpegkit_exception.c fftools_cmdutils.c fftools_ffmpeg.c fftools_ffprobe.c fftools_ffmpeg_mux.c fftools_ffmpeg_mux_init.c fftools_ffmpeg_demux.c fftools_ffmpeg_enc.c fftools_ffmpeg_dec.c fftools_ffmpeg_opt.c fftools_opt_common.c fftools_ffmpeg_hw.c fftools_ffmpeg_filter.c fftools_objpool.c fftools_sync_queue.c fftools_thread_queue.c android_support.c ffmpeg_context.c

MY_CFLAGS := -Wall -Werror -Wno-unused-parameter -Wno-switch -Wno-sign-compare
MY_LDLIBS := -llog -lz -landroid

MY_BUILD_GENERIC_FFMPEG_KIT := true

ifeq ($(MY_ARMV7_NEON), true)
    include $(CLEAR_VARS)
    LOCAL_PATH := $(MY_LOCAL_PATH)/../ffmpeg-kit-android-lib/src/main/cpp
    LOCAL_ARM_MODE := $(MY_ARM_MODE)
    LOCAL_MODULE := ffmpegkit_armv7a_neon
    LOCAL_SRC_FILES := $(MY_SRC_FILES)
    LOCAL_CFLAGS := $(MY_CFLAGS)
    LOCAL_LDFLAGS := $(MY_LDFLAGS)
    LOCAL_LDLIBS := $(MY_LDLIBS)
    LOCAL_SHARED_LIBRARIES := libavcodec_neon libavfilter_neon libswscale_neon libavformat_neon libavutil_neon libswresample_neon libavdevice_neon
    ifeq ($(APP_STL), c++_shared)
        LOCAL_SHARED_LIBRARIES += c++_shared # otherwise NDK will not add the library for packaging
    endif
    LOCAL_ARM_NEON := true
    include $(BUILD_SHARED_LIBRARY)

    $(call import-module, ffmpeg/neon)

    ifneq ($(MY_ARMV7), true)
        MY_BUILD_GENERIC_FFMPEG_KIT := false
    endif
endif

ifeq ($(MY_BUILD_GENERIC_FFMPEG_KIT), true)
    include $(CLEAR_VARS)
    LOCAL_PATH := $(MY_LOCAL_PATH)/../ffmpeg-kit-android-lib/src/main/cpp
    LOCAL_ARM_MODE := $(MY_ARM_MODE)
    LOCAL_MODULE := ffmpegkit
    LOCAL_SRC_FILES := $(MY_SRC_FILES)
    LOCAL_CFLAGS := $(MY_CFLAGS)
    LOCAL_LDFLAGS := $(MY_LDFLAGS)
    LOCAL_LDLIBS := $(MY_LDLIBS)
    LOCAL_SHARED_LIBRARIES := libavfilter libavformat libavcodec libavutil libswresample libavdevice libswscale
    ifeq ($(APP_STL), c++_shared)
        LOCAL_SHARED_LIBRARIES += c++_shared # otherwise NDK will not add the library for packaging
    endif
    LOCAL_ARM_NEON := ${MY_ARM_NEON}
    include $(BUILD_SHARED_LIBRARY)

    $(call import-module, ffmpeg)
endif
