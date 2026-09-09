#
# Copyright (C) 2026 The IrisOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#

IRIS_VERSION_MAJOR := 1
IRIS_VERSION_MINOR := 0
IRIS_VERSION := $(IRIS_VERSION_MAJOR).$(IRIS_VERSION_MINOR)

ifndef IRIS_BUILD_TYPE
    IRIS_BUILD_TYPE := Community
endif

# Data do build no formato YYYYMMDD
IRIS_DATE := $(shell date -u +%Y%m%d)

# Versão completa de exibição
IRIS_DISPLAY_VERSION := IrisOS-$(IRIS_VERSION)-$(IRIS_BUILD_TYPE)-$(IRIS_DATE)

# Propriedades do sistema injetadas no build.prop
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.iris.version=$(IRIS_VERSION) \
    ro.iris.build.type=$(IRIS_BUILD_TYPE) \
    ro.iris.build.date=$(IRIS_DATE) \
    ro.iris.display.version=$(IRIS_DISPLAY_VERSION) \
    ro.modversion=$(IRIS_DISPLAY_VERSION)
