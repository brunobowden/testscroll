#
# Makefile
# Drive
#
# Created by harry on 11/26/14.
# Copyright (c) 2014 Cohesive Front. All rights reserved.
#

SDK := iphonesimulator
J2OBJC_HOME := ../../j2objc
SRC_DIR := Java/main

# Find all files in SRC_DIR, but remove SRC_DIR from the paths
SRC_FILES := $(subst $(SRC_DIR)/, , $(shell find "$(SRC_DIR)" -name '*.java' -type f))
SRC_FOLDERS := $(sort $(dir $(addprefix $(SRC_DIR)/, $(SRC_FILES))))

ifndef DERIVED_FILES_DIR
	XCODE_PROJECT := $(shell find . -maxdepth 2 -type d -name '*.xcodeproj')
	BUILD_CONFIGURATION := Debug
	SDK := $(SDK)
	DERIVED_FILES_DIR := $(shell xcodebuild -project "$(XCODE_PROJECT)" -showBuildSettings \
		-configuration $(BUILD_CONFIGURATION) -sdk $(SDK) \
		| grep DERIVED_FILES_DIR \
		| sed -E "s/[^=]+=[[:space:]]+(.+)/\1/")
endif

ifeq ($(BUILD_CONFIGURATION), Debug)
	J2OBJC_FLAGS += -g
endif

BUILD_DIR := $(DERIVED_FILES_DIR)
J2OBJC_FLAGS += --no-package-directories -sourcepath $(SRC_DIR):$(TST_DIR) --prefix harrycheung=HC -use-arc
# Flatten the list of Objective-C files as that is how Xcode will expect them
OBJC_FILES := $(addprefix $(BUILD_DIR)/, $(notdir $(SRC_FILES:.java=.m)))
vpath %.java $(SRC_FOLDERS)

OBJC_HEADERS := $(OBJC_FILES:.m=.h)

TRANSLATE_LIST=$(BUILD_DIR)/.translate_list

.PHONY: clean init-translate-list show  $(TESTS)

default: translate

translate: $(BUILD_DIR) init-translate-list $(OBJC_FILES) $(OBJC_HEADERS)
	@if [ -s $(TRANSLATE_LIST) ]; then \
		xargs "$(J2OBJC_HOME)/j2objc" $(J2OBJC_FLAGS) -d $(BUILD_DIR) < "$(TRANSLATE_LIST)"; \
	fi
	@rm -f "$(TRANSLATE_LIST)"

$(BUILD_DIR)/%.m $(BUILD_DIR)/%.h: %.java
	@echo $< >> "$(TRANSLATE_LIST)"

init-translate-list: $(BUILD_DIR)
	@rm -f "$(TRANSLATE_LIST)"
	@touch "$(TRANSLATE_LIST)"

$(BUILD_DIR):
	@mkdir -p "$(BUILD_DIR)"

clean:
	@rm -rf "$(BUILD_DIR)"
