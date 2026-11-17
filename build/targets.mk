TARGETS = PC WIN64 \
	PPC2000 PPC2003 PPC2003X WM5 WM5X \
	UNIX UNIX32 UNIX64 OPT \
	WAYLAND \
	PI PI2 CUBIE KOBO NEON \
	ANDROID ANDROID7 ANDROID7NEON ANDROID86 \
	ANDROIDAARCH64 ANDROIDX64 \
	ANDROIDFAT \
	WINE CYGWIN \
	OSX32 OSX64 IOS32 IOS64

ifeq ($(TARGET),)
  ifeq ($(HOST_IS_UNIX),y)
    ifeq ($(HOST_IS_DARWIN),y)
      ifeq ($(HOST_IS_X86_32),y)
        TARGET = OSX32
      else
        TARGET = OSX64
      endif
    else
      TARGET = UNIX
    endif
  else
    TARGET = PC
  endif
else
  ifeq ($(filter $(TARGET),$(TARGETS)),)
    $(error Unknown target: $(TARGET))
  endif
endif

ifeq ($(MAKECMDGOALS),python)
  TARGET_FLAVOR := $(TARGET)_PYTHON
else
  TARGET_FLAVOR := $(TARGET)
endif

HAVE_CE := n
HAVE_FPU := y
X64 := n
TARGET_IS_ARM = n
TARGET_IS_ARMHF = n
XSCALE := n
ARMV5 = n
ARMV6 = n
ARMV7 := n
NEON := n
AARCH64 := n
X86 := n
MIPS := n
MIPS64 := n
FAT_BINARY := n

TARGET_IS_DARWIN := n
TARGET_IS_LINUX := n
TARGET_IS_ANDROID := n
TARGET_IS_PI := n
TARGET_IS_KOBO := n
HAVE_POSIX := n
HAVE_WIN32 := y
HAVE_MSVCRT := y

USE_CROSSTOOL_NG := n

TARGET_ARCH :=

# virtual targets ("flavors")

ifeq ($(TARGET),WIN64)
  X64 := y
  override TARGET = PC
endif

ifeq ($(TARGET),PPC2003X)
  TARGET_IS_ARM = y
  XSCALE := y
  override TARGET = PPC2003
endif

ifeq ($(TARGET),WM5X)
  TARGET_IS_ARM = y
  XSCALE := y
  override TARGET = WM5
endif

ifeq ($(TARGET),ANDROID)
  # default Android target is arm64-v8a
  AARCH64 := y
endif

ifeq ($(TARGET),ANDROID7NEON)
  NEON := y
  override TARGET = ANDROID7
endif

ifeq ($(TARGET),ANDROID7)
  TARGET_IS_ARM = y
  TARGET_IS_ARMHF = y
  ARMV7 := y
  override TARGET = ANDROID
endif

ifeq ($(TARGET),ANDROID86)
  X86 := y
  override TARGET = ANDROID
endif

ifeq ($(TARGET),ANDROIDAARCH64)
  AARCH64 := y
  override TARGET = ANDROID
endif

ifeq ($(TARGET),ANDROIDX64)
  X64 := y
  override TARGET = ANDROID
endif

ifeq ($(TARGET),ANDROIDFAT)
  FAT_BINARY := y
  override TARGET = ANDROID
endif

# real targets

ifeq ($(TARGET),PPC2000)
  TARGET_IS_ARM = y
  CE_MAJOR := 3
  CE_MINOR := 00
  PCPU := ARM

  HAVE_CE := y
endif

ifeq ($(TARGET),PPC2003)
  TARGET_IS_ARM = y
  CE_MAJOR := 4
  CE_MINOR := 00
  PCPU := ARMV4

  HAVE_CE := y
endif

ifeq ($(TARGET),PC)
  ifeq ($(X64),y)
    TCPREFIX := x86_64-w64-mingw32-
    TARGET_ARCH += -m64
  else
    TCPREFIX := i686-w64-mingw32-
    TARGET_ARCH += -march=i586
  endif

  ifneq ($(MINGWPATH),)
    TCPREFIX := $(MINGWPATH)
  endif

  ifeq ($(HOST_IS_WIN32),y)
    TCPREFIX :=
  endif

  WINVER = 0x0500
endif

ifeq ($(TARGET),CYGWIN)
  TCPREFIX :=

  TARGET_ARCH += -march=i586

  WINVER = 0x0500

  HAVE_POSIX := y
  HAVE_WIN32 := y
  HAVE_MSVCRT := n
  HAVE_VASPRINTF := y
endif

ifeq ($(TARGET),ALTAIR)
  CE_MAJOR := 5
  CE_MINOR := 00

  TARGET_IS_ARM = y
  HAVE_CE := y
  XSCALE := y
endif

ifeq ($(TARGET),WM5)
  TARGET_IS_ARM = y
  PCPU := ARMV4
  CE_MAJOR := 5
  CE_MINOR := 00

  HAVE_CE := y
endif

ifeq ($(TARGET),WINE)
  TCPREFIX := wine
  TARGET_ARCH += -march=i586
  WINVER = 0x0500

  HAVE_POSIX := y
  HAVE_MSVCRT := n
endif

ifeq ($(TARGET),OPT)
  override TARGET = UNIX
  DEBUG = n
endif

ifeq ($(TARGET),WAYLAND)
  # experimental target for the Wayland display server
  override TARGET = UNIX
  USE_WAYLAND = y
endif

ifeq ($(TARGET),UNIX)
  # LOCAL_TCPREFIX is set in local-config.mk if configure was run.
  TCPREFIX := $(LOCAL_TCPREFIX)
  TCSUFFIX := $(LOCAL_TCSUFFIX)
  TARGET_IS_ARM = $(HOST_IS_ARM)
  TARGET_IS_PI = $(HOST_IS_PI)
  ARMV6 = $(HOST_IS_ARMV6)
  ARMV7 = $(HOST_IS_ARMV7)
  NEON = $(HOST_HAS_NEON)
  TARGET_IS_ARMHF := $(call bool_or,$(ARMV7),$(TARGET_IS_PI))
  TARGET_HAS_MALI = $(HOST_HAS_MALI)
endif

ifeq ($(TARGET),UNIX32)
  override TARGET = UNIX
  TARGET_ARCH += -m32
endif

ifeq ($(TARGET),UNIX64)
  override TARGET = UNIX
  TARGET_ARCH += -m64
endif

ifeq ($(TARGET),PI)
  override TARGET = UNIX
  TCPREFIX := arm-linux-gnueabihf-
  PI ?= /opt/pi/root
  TARGET_IS_PI = y
  TARGET_IS_ARM = y
  TARGET_IS_ARMHF = y
  ARMV6 = y
endif

ifeq ($(TARGET),PI2)
  override TARGET = NEON
  PI ?= /opt/pi/root
  TARGET_IS_PI = y
endif

ifeq ($(TARGET),CUBIE)
  # cross-crompiling for Cubieboard
  override TARGET = NEON
  CUBIE ?= /opt/cubie/root
  TARGET_HAS_MALI = y
endif

ifeq ($(TARGET),KOBO)
  # Experimental target for Kobo Mini
  override TARGET = NEON
  KOBO = $(TARGET_OUTPUT_DIR)/lib/$(HOST_ARCH)/root
  TARGET_IS_KOBO = y
endif

ifeq ($(TARGET),NEON)
  # Experimental target for generic ARMv7 with NEON
  override TARGET = UNIX
  ifeq ($(USE_CROSSTOOL_NG),y)
    HOST_ARCH = arm-unknown-linux-gnueabihf
  else
    HOST_ARCH = arm-linux-gnueabihf
  endif
  TCPREFIX = $(HOST_ARCH)-
  ifeq ($(CLANG),n)
    TARGET_ARCH += -mcpu=cortex-a8
  endif
  TARGET_IS_ARM = y
  TARGET_IS_ARMHF = y
  ARMV7 := y
  NEON := y
endif

ifeq ($(TARGET),OSX32)
  override TARGET = UNIX
  TARGET_IS_DARWIN = y
  TARGET_IS_OSX = y
  DARWIN_SDK_VERSION = 10.10
  OSX_MIN_SUPPORTED_VERSION = 10.7
  ifeq ($(HOST_IS_DARWIN),y)
    DARWIN_SDK ?= /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX${DARWIN_SDK_VERSION}.sdk
    LLVM_TARGET = i386-apple-darwin
  else
    DARWIN_TOOLCHAIN ?= $(HOME)/opt/darwin-toolchain
    DARWIN_SDK ?= $(DARWIN_TOOLCHAIN)/lib/SDKs/MacOSX$(DARWIN_SDK_VERSION).sdk
    DARWIN_LIBS ?= $(DARWIN_TOOLCHAIN)/lib/i386-MacOSX-$(OSX_MIN_SUPPORTED_VERSION)-SDK$(DARWIN_SDK_VERSION).sdk
    TCPREFIX = $(DARWIN_TOOLCHAIN)/bin/i386-apple-darwin-
    LLVM_PREFIX = $(TCPREFIX)
  endif
  LIBCXX = y
  CLANG = y
  TARGET_ARCH += -march=i686 -msse2 -mmacosx-version-min=$(OSX_MIN_SUPPORTED_VERSION)
endif

ifeq ($(TARGET),OSX64)
  override TARGET = UNIX
  TARGET_IS_DARWIN = y
  TARGET_IS_OSX = y
  DARWIN_SDK_VERSION = 10.10
  OSX_MIN_SUPPORTED_VERSION = 10.7
  ifeq ($(HOST_IS_DARWIN),y)
    DARWIN_SDK ?= /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX${DARWIN_SDK_VERSION}.sdk
    LLVM_TARGET = x86_64-apple-darwin
  else
    DARWIN_TOOLCHAIN ?= $(HOME)/opt/darwin-toolchain
    DARWIN_SDK ?= $(DARWIN_TOOLCHAIN)/lib/SDKs/MacOSX$(DARWIN_SDK_VERSION).sdk
    DARWIN_LIBS ?= $(DARWIN_TOOLCHAIN)/lib/x86_64-MacOSX-$(OSX_MIN_SUPPORTED_VERSION)-SDK$(DARWIN_SDK_VERSION).sdk
    TCPREFIX = $(DARWIN_TOOLCHAIN)/bin/x86_64-apple-darwin-
    LLVM_PREFIX = $(TCPREFIX)
  endif
  LIBCXX = y
  CLANG = y
  TARGET_ARCH += -mmacosx-version-min=$(OSX_MIN_SUPPORTED_VERSION)
endif

ifeq ($(TARGET),IOS32)
  override TARGET = UNIX
  TARGET_IS_DARWIN = y
  TARGET_IS_IOS = y
  DARWIN_SDK_VERSION = 8.3
  IOS_MIN_SUPPORTED_VERSION = 5.1
  ifeq ($(HOST_IS_DARWIN),y)
    DARWIN_SDK ?= /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${DARWIN_SDK_VERSION}.sdk
    LLVM_TARGET = armv7-apple-darwin
  else
    DARWIN_TOOLCHAIN ?= $(HOME)/opt/darwin-toolchain
    DARWIN_SDK ?= $(DARWIN_TOOLCHAIN)/lib/SDKs/iPhoneOS$(DARWIN_SDK_VERSION).sdk
    DARWIN_LIBS ?= $(DARWIN_TOOLCHAIN)/lib/armv7-iOS-$(IOS_MIN_SUPPORTED_VERSION)-SDK$(DARWIN_SDK_VERSION).sdk
    TCPREFIX = $(DARWIN_TOOLCHAIN)/bin/armv7-apple-darwin-
    LLVM_PREFIX = $(TCPREFIX)
  endif
  LIBCXX = y
  CLANG = y
  TARGET_ARCH += -miphoneos-version-min=$(IOS_MIN_SUPPORTED_VERSION)
endif

ifeq ($(TARGET),IOS64)
  override TARGET = UNIX
  TARGET_IS_DARWIN = y
  TARGET_IS_IOS = y
  DARWIN_SDK_VERSION = 8.3
  IOS_MIN_SUPPORTED_VERSION = 7.0
  ifeq ($(HOST_IS_DARWIN),y)
    DARWIN_SDK ?= /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${DARWIN_SDK_VERSION}.sdk
    LLVM_TARGET = aarch64-apple-darwin
  else
    DARWIN_TOOLCHAIN ?= $(HOME)/opt/darwin-toolchain
    DARWIN_SDK ?= $(DARWIN_TOOLCHAIN)/lib/SDKs/iPhoneOS$(DARWIN_SDK_VERSION).sdk
    DARWIN_LIBS ?= $(DARWIN_TOOLCHAIN)/lib/arm64-iOS-$(IOS_MIN_SUPPORTED_VERSION)-SDK$(DARWIN_SDK_VERSION).sdk
    TCPREFIX = $(DARWIN_TOOLCHAIN)/bin/aarch64-apple-darwin-
    LLVM_PREFIX = $(TCPREFIX)
  endif
  LIBCXX = y
  CLANG = y
  TARGET_ARCH += -miphoneos-version-min=$(IOS_MIN_SUPPORTED_VERSION) -arch arm64
  ASFLAGS += -arch arm64
endif

ifeq ($(filter $(TARGET),UNIX WINE),$(TARGET))
  ifeq ($(HOST_IS_LINUX)$(TARGET_IS_DARWIN),yn)
    TARGET_IS_LINUX := y
  endif
  ifeq ($(HOST_IS_DARWIN),y)
    TARGET_IS_DARWIN := y
  endif
endif

ifeq ($(TARGET),UNIX)
  HAVE_POSIX := y
  HAVE_WIN32 := n
  HAVE_MSVCRT := n
  HAVE_VASPRINTF := y

  ifeq ($(ARMV6),y)
    TARGET_ARCH += -march=armv6

    ifneq ($(CLANG),y)
      # Force-disable thumb just in case the gcc binary was built with
      # thumb enabled by default.  This fixes the dreaded gcc error
      # "sorry, unimplemented: Thumb-1 hard-float VFP ABI".
      TARGET_ARCH += -marm
    endif
  endif

  ifeq ($(ARMV7),y)
    TARGET_ARCH += -march=armv7-a
  endif

  ifeq ($(TARGET_IS_ARMHF),y)
    ifeq ($(ARMV6),y)
      TARGET_ARCH += -mfpu=vfp
    endif

    ifeq ($(NEON),y)
      TARGET_ARCH += -mfpu=neon
    endif

    TARGET_ARCH += -mfloat-abi=hard
  endif

  ifeq ($(TARGET_IS_ARM)$(TARGET_IS_LINUX),yy)
    ifeq ($(TARGET_IS_ARMHF),y)
      LLVM_TARGET = arm-linux-gnueabihf
    else
      LLVM_TARGET = arm-linux-gnueabi
    endif
  endif
endif

ifeq ($(TARGET),ANDROID)
  # Modern NDK (r23+) with the unified LLVM toolchain; tested with r27c.
  ANDROID_NDK ?= $(firstword $(ANDROID_NDK_HOME) $(wildcard $(HOME)/Library/Android/sdk/ndk/27.*) $(wildcard $(HOME)/Android/Sdk/ndk/27.*))

  ANDROID_SDK_PLATFORM = android-35

  # minimum API level the native code is compiled for (= minSdkVersion)
  ANDROID_API = 21

  ifeq ($(ARMV7),y)
    ANDROID_ABI3 = armeabi-v7a
    LLVM_TARGET = armv7a-linux-androideabi$(ANDROID_API)
    TARGET_ARCH += -march=armv7-a -mfloat-abi=softfp -mfpu=neon -mthumb
  else ifeq ($(X86),y)
    ANDROID_ABI3 = x86
    LLVM_TARGET = i686-linux-android$(ANDROID_API)
  else ifeq ($(X64),y)
    ANDROID_ABI3 = x86_64
    LLVM_TARGET = x86_64-linux-android$(ANDROID_API)
  else
    AARCH64 := y
    ANDROID_ABI3 = arm64-v8a
    LLVM_TARGET = aarch64-linux-android$(ANDROID_API)
  endif
  ANDROID_ABI5 = $(ANDROID_ABI3)
  HAVE_FPU := y

  ifeq ($(HOST_IS_DARWIN),y)
    ANDROID_HOST_TAG = darwin-x86_64
  else ifeq ($(HOST_IS_WIN32),y)
    ANDROID_HOST_TAG = windows-x86_64
  else
    ANDROID_HOST_TAG = linux-x86_64
  endif

  ANDROID_TOOLCHAIN = $(ANDROID_NDK)/toolchains/llvm/prebuilt/$(ANDROID_HOST_TAG)
  LLVM_PREFIX = $(ANDROID_TOOLCHAIN)/bin/
  TCPREFIX = $(ANDROID_TOOLCHAIN)/bin/llvm-

  CLANG = y
  LIBCXX = y

  TARGET_ARCH += -fpic -funwind-tables

  TARGET_IS_LINUX := y
  TARGET_IS_ANDROID := y
  HAVE_POSIX := y
  HAVE_WIN32 := n
  HAVE_MSVCRT := n
  HAVE_VASPRINTF := y
endif

ifeq ($(HAVE_CE),y)
  TCPREFIX := arm-mingw32ce-
  HAVE_FPU := n

  ifeq ($(XSCALE),y)
    TARGET_ARCH += -mcpu=xscale
  else
    TARGET_ARCH += -mcpu=strongarm1110
  endif
endif

######## target definitions

TARGET_INCLUDES =
TARGET_CXXFLAGS =
TARGET_CPPFLAGS = -I$(TARGET_OUTPUT_DIR)/include

ifneq ($(WINVER),)
  TARGET_CPPFLAGS += -DWINVER=$(WINVER) -D_WIN32_WINDOWS=$(WINVER)
  TARGET_CPPFLAGS += -D_WIN32_WINNT=$(WINVER) -D_WIN32_IE=$(WINVER)
endif

ifeq ($(HAVE_CE),y)
  TARGET_CPPFLAGS += -D_WIN32_WCE=0x0$(CE_MAJOR)$(CE_MINOR)
  TARGET_CPPFLAGS += -DWIN32_PLATFORM_PSPC=$(CE_MAJOR)$(CE_MINOR)
endif

ifeq ($(HAVE_WIN32),y)
  TARGET_CPPFLAGS += -DWIN32_LEAN_AND_MEAN
  TARGET_CPPFLAGS += -DNOMINMAX
  ifeq ($(TARGET),CYGWIN)
  TARGET_CPPFLAGS += -DWIN32
  endif
endif

ifeq ($(TARGET),WINE)
  TARGET_CPPFLAGS += -D__WINE__
  TARGET_CPPFLAGS += -DWINE_STRICT_PROTOTYPES
  # -mno-cygwin
endif

ifeq ($(TARGET),ALTAIR)
  TARGET_CPPFLAGS += -DGNAV
endif

ifeq ($(HAVE_POSIX),y)
  TARGET_CPPFLAGS += -DHAVE_POSIX
  TARGET_CPPFLAGS += -DHAVE_STDINT_H
  TARGET_CPPFLAGS += -DHAVE_UNISTD_H
  TARGET_CPPFLAGS += -DHAVE_VASPRINTF
endif

ifeq ($(HAVE_MSVCRT),y)
  TARGET_CPPFLAGS += -DHAVE_MSVCRT
  TARGET_CPPFLAGS += -DUNICODE -D_UNICODE
  TARGET_CPPFLAGS += -DSTRICT
endif

ifeq ($(HAVE_WIN32),n)
  TARGET_INCLUDES += -I$(SRC)/unix
endif

ifeq ($(TARGET),WINE)
  TARGET_INCLUDES += -I$(SRC)/wine
endif

ifeq ($(HOST_IS_PI)$(TARGET_IS_PI),ny)
  TARGET_CPPFLAGS += --sysroot=$(PI) -isystem $(PI)/usr/include/arm-linux-gnueabihf -isystem $(PI)/usr/include
endif

ifeq ($(HOST_IS_ARM)$(TARGET_HAS_MALI),ny)
  # cross-crompiling for Cubieboard
  TARGET_CPPFLAGS += --sysroot=$(CUBIE) -isystem $(CUBIE)/usr/include/arm-linux-gnueabihf
  TARGET_CPPFLAGS += -isystem $(CUBIE)/usr/local/stow/sunxi-mali/include
endif

ifeq ($(TARGET_IS_KOBO),y)
  TARGET_CPPFLAGS += -DKOBO
  TARGET_CPPFLAGS += -isystem $(KOBO)/include
endif

ifeq ($(TARGET),ANDROID)
  TARGET_CPPFLAGS += -DANDROID

endif

####### compiler target

ifeq ($(HAVE_WIN32),y)
  ifeq ($(TARGET),WINE)
    TARGET_ARCH += -m32
  else
    TARGET_ARCH += -mwin32
  endif

  WINDRESFLAGS := -I$(OUT)/include -I$(SRC) $(TARGET_CPPFLAGS)
endif

ifeq ($(TARGET),PC)
  TARGET_ARCH += -mwindows -mms-bitfields
endif

ifeq ($(TARGET),CYGWIN)
  WINDRESFLAGS += -I./Data
endif

####### linker configuration

TARGET_LDFLAGS =
TARGET_LDLIBS =
TARGET_LDADD =
TARGET_STATIC ?= n

ifeq ($(TARGET),PC)
  TARGET_LDFLAGS += -Wl,--major-subsystem-version=5
  TARGET_LDFLAGS += -Wl,--minor-subsystem-version=00

  # default to "console"; see SCREEN_LDLIBS
  TARGET_LDFLAGS += -Wl,-subsystem,console
endif

ifeq ($(HAVE_WIN32),y)
  ifeq ($(HAVE_CE),y)
    TARGET_LDFLAGS += -Wl,--major-subsystem-version=$(CE_MAJOR)
    TARGET_LDFLAGS += -Wl,--minor-subsystem-version=$(CE_MINOR)
  endif

  ifeq ($(TARGET),WINE)
    TARGET_LDLIBS += -lpthread
  else
  ifneq ($(TARGET),CYGWIN)
    # link libstdc++-6.dll statically, so we don't have to distribute it
    TARGET_STATIC = y
  endif
  endif
endif

ifeq ($(HAVE_POSIX),y)
ifneq ($(TARGET),ANDROID)
  TARGET_LDLIBS += -lpthread
  ifeq ($(TARGET_IS_LINUX),y)
    TARGET_LDLIBS += -lrt # for clock_gettime()
    ifeq ($(TARGET_IS_KOBO),y)
      TARGET_LDLIBS += $(topdir)/lib/alsa-lib/src/.libs/libasound.a
    else ifeq ($(TARGET),UNIX)
      TARGET_LDLIBS += -lpulse-simple -lpulse -lasound
    endif
    TARGET_LDLIBS += -ldl
  endif
endif
endif

ifeq ($(HOST_IS_PI)$(TARGET_IS_PI),ny)
  TARGET_LDFLAGS += --sysroot=$(PI) -L$(PI)/usr/lib/arm-linux-gnueabihf
endif

ifeq ($(HOST_IS_ARM)$(TARGET_HAS_MALI),ny)
  # cross-crompiling for Cubieboard
  TARGET_LDFLAGS += --sysroot=$(CUBIE)
  TARGET_LDFLAGS += -L$(CUBIE)/lib/arm-linux-gnueabihf
  TARGET_LDFLAGS += -L$(CUBIE)/usr/lib/arm-linux-gnueabihf
  TARGET_LDFLAGS += -L$(CUBIE)/usr/local/stow/sunxi-mali/lib
endif

ifeq ($(TARGET_IS_KOBO),y)
  TARGET_LDFLAGS += -L$(KOBO)/lib
  TARGET_LDFLAGS += -static-libstdc++

  # use our glibc version and its ld.so on the Kobo, not the one from
  # the stock Kobo firmware, as it may be incompatible
  TARGET_LDFLAGS += -Wl,--dynamic-linker=/opt/tophat/lib/ld-linux-armhf.so.3
  TARGET_LDFLAGS += -Wl,--rpath=/opt/tophat/lib
endif

ifeq ($(TARGET),ANDROID)
  TARGET_LDFLAGS += -Wl,--no-undefined
  TARGET_LDFLAGS += -static-libstdc++
  # required for Android 15+ devices with 16 KB memory pages
  TARGET_LDFLAGS += -Wl,-z,max-page-size=16384
endif

ifneq ($(filter PC WINE CYGWIN,$(TARGET)),)
  TARGET_LDLIBS += -lwinmm
endif

ifeq ($(TARGET),CYGWIN)
  TARGET_LDLIBS += -lintl
endif

ifeq ($(HAVE_CE),y)
  ifneq ($(TARGET),ALTAIR)
    TARGET_CPPFLAGS += -DHAVE_NOTE_PRJ_DLL
    TARGET_CPPFLAGS += -DHAVE_AYGSHELL_DLL
    TARGET_CPPFLAGS += -DHAVE_IMGDECMP_DLL
  endif
endif

ifeq ($(TARGET),UNIX)
  ifeq ($(TARGET_IS_DARWIN),n)
  TARGET_LDLIBS += -lm
  endif
endif

ifeq ($(TARGET),ANDROID)
  TARGET_LDLIBS += -lm -lc

  TARGET_LDLIBS += -llog
endif

ifeq ($(TARGET_STATIC),y)
  TARGET_LDFLAGS += -static
endif

######## output files

TARGET_EXEEXT = .exe

ifeq ($(TARGET),UNIX)
  TARGET_EXEEXT :=
endif

ifeq ($(TARGET),ANDROID)
  TARGET_EXEEXT :=
endif
