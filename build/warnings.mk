WARNINGS = -Wall -Wextra
WARNINGS += -Wwrite-strings -Wcast-qual -Wpointer-arith -Wsign-compare
WARNINGS += -Wundef
WARNINGS += -Wmissing-declarations
WARNINGS += -Wredundant-decls

CXXFLAGS += $(WARNINGS)
CXXFLAGS += -Wmissing-noreturn

# disable some warnings, we're not ready for them yet
CXXFLAGS += -Wno-unused-parameter
CXXFLAGS += -Wno-missing-field-initializers 
CXXFLAGS += -Wcast-align

# plain C warnings

CFLAGS += $(WARNINGS)
CFLAGS += -Wmissing-prototypes -Wstrict-prototypes
CFLAGS += -Wnested-externs

# make warnings fatal (for perfectionists)

ifeq ($(TARGET),ANDROID)
# modern NDK clang emits ~300 new warnings (mostly deprecations) on this
# legacy code; keep them non-fatal until they are cleaned up
WERROR ?= n
else ifneq ($(TARGET),CYGWIN)
WERROR ?= $(DEBUG)
endif

ifeq ($(WERROR),y)
CXXFLAGS += -Werror
CFLAGS += -Werror
endif

#CXXFLAGS += -pedantic
#CXXFLAGS += -pedantic-errors

# -Wdisabled-optimization
# -Wunused -Wshadow -Wunreachable-code
# -Wfloat-equal
