# This Makefile fragment builds the Android package (XCSoar.apk).
# We're not using NDK's Makefiles because our Makefile is so big and
# complex, we don't want to duplicate that for another platform.

ifeq ($(TARGET),ANDROID)

ANDROID_KEYSTORE ?= $(HOME)/.android/mk.keystore
ANDROID_KEY_ALIAS ?= mk
ANDROID_BUILD = $(TARGET_OUTPUT_DIR)/build
ANDROID_BIN = $(TARGET_BIN_DIR)

ANDROID_SDK ?= $(firstword $(ANDROID_HOME) $(ANDROID_SDK_ROOT) $(wildcard $(HOME)/Library/Android/sdk) $(wildcard $(HOME)/Android/Sdk))
ANDROID_SDK_PLATFORM_DIR = $(ANDROID_SDK)/platforms/$(ANDROID_SDK_PLATFORM)
ANDROID_ABI_DIR = $(ANDROID_BUILD)/libs/$(ANDROID_ABI5)

ANDROID_LIB_NAMES = tophat

# The APK is packaged by Gradle (see android/build.gradle); this
# Makefile builds the native library and generated resources first.
# For release builds, set ANDROID_KEYSTORE_PASS (and optionally
# ANDROID_KEY_PASS) in the environment.
GRADLE_FLAGS = --console=plain -PtophatOutput=$(abspath $(TARGET_OUTPUT_DIR))
ifneq ($(V),2)
GRADLE_FLAGS += -q
endif
GRADLE = cd android && ./gradlew $(GRADLE_FLAGS)
GRADLE_APK_DIR = $(TARGET_OUTPUT_DIR)/gradle/outputs/apk

JAVA_PACKAGE = org.tophat
CLASS_NAME = $(JAVA_PACKAGE).NativeView
CLASS_SOURCE = $(subst .,/,$(CLASS_NAME)).java
CLASS_CLASS = $(patsubst %.java,%.class,$(CLASS_SOURCE))

NATIVE_CLASSES = NativeView EventBridge InternalGPS NonGPSSensors NativeInputListener DownloadUtil BatteryReceiver
NATIVE_CLASSES += NativePortListener
NATIVE_CLASSES += NativeLeScanCallback
NATIVE_CLASSES += NativeBMP085Listener
NATIVE_CLASSES += NativeI2CbaroListener
NATIVE_CLASSES += NativeNunchuckListener
NATIVE_CLASSES += NativeVoltageListener
NATIVE_SOURCES = $(patsubst %,android/src/%.java,$(NATIVE_CLASSES))
NATIVE_PREFIX = $(TARGET_OUTPUT_DIR)/include/$(subst .,_,$(JAVA_PACKAGE))_
NATIVE_HEADERS = $(patsubst %,$(NATIVE_PREFIX)%.h,$(NATIVE_CLASSES))

ANDROID_JAVA_SOURCES := $(wildcard android/src/*.java)

DRAWABLE_DIR = $(ANDROID_BUILD)/res/drawable
RAW_DIR = $(ANDROID_BUILD)/res/raw

ifeq ($(TESTING),y)
ICON_SVG = $(topdir)/Data/graphics/logo_red.svg
else
ICON_SVG = $(topdir)/Data/graphics/logo.svg
endif

ICON_WHITE_SVG = $(topdir)/Data/graphics/logo_white.svg

$(ANDROID_BUILD)/res/drawable-ldpi/icon.png: $(ICON_SVG) | $(ANDROID_BUILD)/res/drawable-ldpi/dirstamp
	$(Q)rsvg-convert --width=36 $< -o $@

$(ANDROID_BUILD)/res/drawable/icon.png: $(ICON_SVG) | $(ANDROID_BUILD)/res/drawable/dirstamp
	$(Q)rsvg-convert --width=48 $< -o $@

$(ANDROID_BUILD)/res/drawable-hdpi/icon.png: $(ICON_SVG) | $(ANDROID_BUILD)/res/drawable-hdpi/dirstamp
	$(Q)rsvg-convert --width=72 $< -o $@

$(ANDROID_BUILD)/res/drawable-xhdpi/icon.png: $(ICON_SVG) | $(ANDROID_BUILD)/res/drawable-xhdpi/dirstamp
	$(Q)rsvg-convert --width=96 $< -o $@

$(ANDROID_BUILD)/res/drawable-xxhdpi/icon.png: $(ICON_SVG) | $(ANDROID_BUILD)/res/drawable-xxhdpi/dirstamp
	$(Q)rsvg-convert --width=144 $< -o $@

$(ANDROID_BUILD)/res/drawable-xxxhdpi/icon.png: $(ICON_SVG) | $(ANDROID_BUILD)/res/drawable-xxxhdpi/dirstamp
	$(Q)rsvg-convert --width=192 $< -o $@

$(ANDROID_BUILD)/res/drawable/notification_icon.png: $(ICON_WHITE_SVG) | $(ANDROID_BUILD)/res/drawable/dirstamp
	$(Q)rsvg-convert --width=24 $< -o $@

$(ANDROID_BUILD)/res/drawable-hdpi/notification_icon.png: $(ICON_WHITE_SVG) | $(ANDROID_BUILD)/res/drawable-hdpi/dirstamp
	$(Q)rsvg-convert --width=36 $< -o $@

$(ANDROID_BUILD)/res/drawable-xhdpi/notification_icon.png: $(ICON_WHITE_SVG) | $(ANDROID_BUILD)/res/drawable-xhdpi/dirstamp
	$(Q)rsvg-convert --width=48 $< -o $@

$(ANDROID_BUILD)/res/drawable-xxhdpi/notification_icon.png: $(ICON_WHITE_SVG) | $(ANDROID_BUILD)/res/drawable-xxhdpi/dirstamp
	$(Q)rsvg-convert --width=72 $< -o $@

$(ANDROID_BUILD)/res/drawable-xxxhdpi/notification_icon.png: $(ICON_WHITE_SVG) | $(ANDROID_BUILD)/res/drawable-xxxhdpi/dirstamp
	$(Q)rsvg-convert --width=96 $< -o $@

OGGENC = oggenc --quiet --quality 1

SOUNDS = fail insert remove beep_bweep beep_clear beep_drip traffic_low traffic_important traffic_urgent above below one_oclock two_oclock three_oclock four_oclock five_oclock six_oclock seven_oclock eight_oclock nine_oclock ten_oclock eleven_oclock twelve_oclock airspace
SOUND_FILES = $(patsubst %,$(RAW_DIR)/%.ogg,$(SOUNDS))

$(SOUND_FILES): $(RAW_DIR)/%.ogg: Data/sound/%.wav | $(RAW_DIR)/dirstamp
	@$(NQ)echo "  OGGENC  $@"
	$(Q)$(OGGENC) -o $@ $<

PNG1 := $(patsubst Data/bitmaps/%.bmp,$(DRAWABLE_DIR)/%.png,$(BMP_BITMAPS))

# workaround for an ImageMagick bug (observed with the Debian package
# 8:6.7.7.10-2): it corrupts 4-bit gray-scale images when converting
# BMP to PNG (TRAC #2220)
PNG1b := $(filter $(DRAWABLE_DIR)/vario_scale_%.png,$(PNG1))
PNG1 := $(filter-out $(DRAWABLE_DIR)/vario_scale_%.png,$(PNG1))
$(DRAWABLE_DIR)/vario_scale_%.png: Data/bitmaps/vario_scale_%.bmp | $(DRAWABLE_DIR)/dirstamp
	$(Q)$(IM_PREFIX)convert -depth 8 $< $@

$(PNG1): $(DRAWABLE_DIR)/%.png: Data/bitmaps/%.bmp | $(DRAWABLE_DIR)/dirstamp
	$(Q)$(IM_PREFIX)convert $< $@

PNG2 := $(patsubst $(DATA)/graphics/%.bmp,$(DRAWABLE_DIR)/%.png,$(BMP_LAUNCH_ALL))
$(PNG2): $(DRAWABLE_DIR)/%.png: $(DATA)/graphics/%.bmp | $(DRAWABLE_DIR)/dirstamp
	$(Q)$(IM_PREFIX)convert $< $@

PNG3 := $(patsubst $(DATA)/graphics/%.bmp,$(DRAWABLE_DIR)/%.png,$(BMP_SPLASH_80) $(BMP_SPLASH_160) $(BMP_TITLE_110) $(BMP_TITLE_320))
$(PNG3): $(DRAWABLE_DIR)/%.png: $(DATA)/graphics/%.bmp | $(DRAWABLE_DIR)/dirstamp
	$(Q)$(IM_PREFIX)convert $< $@

PNG4 := $(patsubst $(DATA)/icons/%.bmp,$(DRAWABLE_DIR)/%.png,$(BMP_ICONS) $(BMP_ICONS_160) $(BMP_ICONS_420))
$(PNG4): $(DRAWABLE_DIR)/%.png: $(DATA)/icons/%.png | $(DRAWABLE_DIR)/dirstamp
	$(Q)cp $< $@

PNG5 := $(patsubst $(DATA)/graphics/%.bmp,$(DRAWABLE_DIR)/%.png,$(BMP_DIALOG_TITLE) $(BMP_PROGRESS_BORDER))
$(PNG5): $(DRAWABLE_DIR)/%.png: $(DATA)/graphics/%.bmp | $(DRAWABLE_DIR)/dirstamp
	$(Q)$(IM_PREFIX)convert $< $@

PNG_FILES = $(PNG1) $(PNG1b) $(PNG2) $(PNG3) $(PNG4) $(PNG5) \
	$(ANDROID_BUILD)/res/drawable-ldpi/icon.png \
	$(ANDROID_BUILD)/res/drawable/icon.png \
	$(ANDROID_BUILD)/res/drawable-hdpi/icon.png \
	$(ANDROID_BUILD)/res/drawable-xhdpi/icon.png \
	$(ANDROID_BUILD)/res/drawable-xxhdpi/icon.png \
	$(ANDROID_BUILD)/res/drawable-xxxhdpi/icon.png \
	$(ANDROID_BUILD)/res/drawable/notification_icon.png \
	$(ANDROID_BUILD)/res/drawable-hdpi/notification_icon.png \
	$(ANDROID_BUILD)/res/drawable-xhdpi/notification_icon.png \
	$(ANDROID_BUILD)/res/drawable-xxhdpi/notification_icon.png \
	$(ANDROID_BUILD)/res/drawable-xxxhdpi/notification_icon.png

ifeq ($(TESTING),y)
MANIFEST = android/testing/AndroidManifest.xml
else
MANIFEST = android/AndroidManifest.xml
endif

ifeq ($(FAT_BINARY),y)

# generate a "fat" APK file with binaries for all ABIs

ANDROID_LIB_BUILD =

# Example: $(eval $(call generate-abi,tophat,armeabi-v7a,ANDROID7))
define generate-abi

ANDROID_LIB_BUILD += $$(ANDROID_BUILD)/libs/$(2)/lib$(1).so

$$(ANDROID_BUILD)/libs/$(2)/lib$(1).so: $$(OUT)/$(3)/bin/lib$(1).so | $$(ANDROID_BUILD)/libs/$(2)/dirstamp
	$$(Q)cp $$< $$@

$$(OUT)/$(3)/bin/lib$(1).so:
	$$(Q)$$(MAKE) TARGET=$(3) DEBUG=$$(DEBUG) USE_CCACHE=$$(USE_CCACHE) $$@

endef

# Example: $(eval $(call generate-abi,tophat))
define generate-all-abis
$(eval $(call generate-abi,$(1),armeabi-v7a,ANDROID7))
$(eval $(call generate-abi,$(1),x86,ANDROID86))
$(eval $(call generate-abi,$(1),arm64-v8a,ANDROIDAARCH64))
$(eval $(call generate-abi,$(1),x86_64,ANDROIDX64))
endef

$(foreach NAME,$(ANDROID_LIB_NAMES),$(eval $(call generate-all-abis,$(NAME))))

else # !FAT_BINARY

# add dependency to this source file
$(call SRC_TO_OBJ,$(SRC)/Android/Main.cpp): $(NATIVE_HEADERS)
$(call SRC_TO_OBJ,$(SRC)/Android/EventBridge.cpp): $(NATIVE_HEADERS)
$(call SRC_TO_OBJ,$(SRC)/Android/InternalSensors.cpp): $(NATIVE_HEADERS)
$(call SRC_TO_OBJ,$(SRC)/Android/Battery.cpp): $(NATIVE_HEADERS)
$(call SRC_TO_OBJ,$(SRC)/Android/NativePortListener.cpp): $(NATIVE_HEADERS)
$(call SRC_TO_OBJ,$(SRC)/Android/NativeLeScanCallback.cpp): $(NATIVE_HEADERS)
$(call SRC_TO_OBJ,$(SRC)/Android/NativeInputListener.cpp): $(NATIVE_HEADERS)
$(call SRC_TO_OBJ,$(SRC)/Android/DownloadManager.cpp): $(NATIVE_HEADERS)
$(call SRC_TO_OBJ,$(SRC)/Android/NativeBMP085Listener.cpp): $(NATIVE_HEADERS)
$(call SRC_TO_OBJ,$(SRC)/Android/NativeI2CbaroListener.cpp): $(NATIVE_HEADERS)
$(call SRC_TO_OBJ,$(SRC)/Android/NativeNunchuckListener.cpp): $(NATIVE_HEADERS)
$(call SRC_TO_OBJ,$(SRC)/Android/NativeVoltageListener.cpp): $(NATIVE_HEADERS)

ANDROID_LIB_BUILD = $(patsubst %,$(ANDROID_ABI_DIR)/lib%.so,$(ANDROID_LIB_NAMES))
$(ANDROID_LIB_BUILD): $(ANDROID_ABI_DIR)/lib%.so: $(TARGET_BIN_DIR)/lib%.so $(ANDROID_ABI_DIR)/dirstamp
	$(Q)cp $< $@

# Generate JNI headers with "javac -h" (javah was removed in JDK 10).
# Only the classes with native methods are compiled; the rest of the
# package is resolved through -sourcepath (via a symlinked package tree,
# because android/src is flat).
JAVAH_DIR = $(TARGET_OUTPUT_DIR)/javah
IOIO_SRC = android/ioio/software
JAVAH_SOURCEPATH = $(JAVAH_DIR)/src:$(IOIO_SRC)/IOIOLib/src:$(IOIO_SRC)/IOIOLib/target/android/src:$(IOIO_SRC)/IOIOLibAccessory/src:$(IOIO_SRC)/IOIOLibBT/src:$(IOIO_SRC)/IOIOLibAndroidDevice/src

$(JAVAH_DIR)/stamp: $(NATIVE_SOURCES) | $(TARGET_OUTPUT_DIR)/include/dirstamp
	@$(NQ)echo "  JAVAC -h $(TARGET_OUTPUT_DIR)/include"
	$(Q)rm -rf $(JAVAH_DIR) && mkdir -p $(JAVAH_DIR)/src/org
	$(Q)ln -s $(abspath android/src) $(JAVAH_DIR)/src/org/tophat
	$(Q)javac -nowarn -implicit:none -h $(TARGET_OUTPUT_DIR)/include -d $(JAVAH_DIR)/classes \
	  -cp $(ANDROID_SDK_PLATFORM_DIR)/android.jar -sourcepath $(JAVAH_SOURCEPATH) \
	  $(patsubst %,$(JAVAH_DIR)/src/org/tophat/%.java,$(NATIVE_CLASSES))
	@touch $@

$(NATIVE_HEADERS): $(JAVAH_DIR)/stamp

endif # !FAT_BINARY

# Copy the generated resources and native libraries into a clean tree
# for Gradle (its resource merger rejects our "dirstamp" files).
ANDROID_STAGED = $(ANDROID_BUILD)/staged
$(ANDROID_STAGED)/stamp: $(ANDROID_LIB_BUILD) $(PNG_FILES) $(SOUND_FILES)
	@$(NQ)echo "  STAGE   $(ANDROID_STAGED)"
	$(Q)rm -rf $(ANDROID_STAGED) && mkdir -p $(ANDROID_STAGED)
	$(Q)cp -R $(ANDROID_BUILD)/res $(ANDROID_STAGED)/res
	$(Q)cp -R $(ANDROID_BUILD)/libs $(ANDROID_STAGED)/jniLibs
	$(Q)find $(ANDROID_STAGED) -name dirstamp -delete
	@touch $@

ANDROID_APK_DEPS = $(ANDROID_STAGED)/stamp \
	$(ANDROID_JAVA_SOURCES) $(MANIFEST) android/build.gradle

$(ANDROID_BIN)/XCSoar-debug.apk: $(ANDROID_APK_DEPS) | $(ANDROID_BIN)/dirstamp
	@$(NQ)echo "  GRADLE  $@"
	$(Q)$(GRADLE) assembleDebug
	$(Q)cp $(GRADLE_APK_DIR)/debug/TopHat-debug.apk $@

$(ANDROID_BIN)/XCSoar.apk: $(ANDROID_APK_DEPS) | $(ANDROID_BIN)/dirstamp
	@$(NQ)echo "  GRADLE  $@"
	$(Q)$(GRADLE) assembleRelease -PtophatKeystore=$(ANDROID_KEYSTORE) -PtophatKeyAlias=$(ANDROID_KEY_ALIAS)
	$(Q)if [ -f $(GRADLE_APK_DIR)/release/TopHat-release.apk ]; then \
	  cp $(GRADLE_APK_DIR)/release/TopHat-release.apk $@; \
	else \
	  echo "warning: $(ANDROID_KEYSTORE) not found, release APK is unsigned"; \
	  cp $(GRADLE_APK_DIR)/release/TopHat-release-unsigned.apk $@; \
	fi

endif
