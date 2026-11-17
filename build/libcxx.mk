# libc++, the C++ standard library implementation from the LLVM
# project.

ifeq ($(LIBCXX),y)

ifeq ($(TARGET),ANDROID)
# the NDK's clang uses its bundled libc++ automatically;
# -static-libstdc++ (see targets.mk) selects libc++_static
LIBCXX_CXXFLAGS = -DLIBCXX
else
LIBCXX_CXXFLAGS += -stdlib=libc++
LIBCXX_LDFLAGS += -stdlib=libc++
endif

else

LIBCXX_CXXFLAGS_INTERNAL = -Wno-char-subscripts -Wno-sign-compare
LIBCXX_CPPFLAGS = -nostdinc++ -isystem $(LIBCXX)/include -DLIBCXX
LIBCXX_SOURCES = \
	$(SRC)/LibCXX.cpp \
	$(LIBCXX)/src/algorithm.cpp \
	$(LIBCXX)/src/hash.cpp \
	$(LIBCXX)/src/string.cpp

ifeq ($(TARGET),ANDROID)
LIBCXX_CPPFLAGS_INTERNAL += -D__APPLE__=0
LIBCXX_SOURCES += $(LIBCXX)/src/new.cpp
endif

$(eval $(call link-library,libcxx,LIBCXX))

endif
