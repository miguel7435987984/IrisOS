#
# Copyright (C) 2026 The IrisOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#

# Seleção de Bootanimation baseada no alvo
ifeq ($(TARGET_ARCH),x86_64)
    # Alvo PC (Widescreen 16:9 / Landscape)
    PRODUCT_COPY_FILES += \
        vendor/iris/bootanimation/bootanimation_pc.zip:$(TARGET_COPY_OUT_PRODUCT)/media/bootanimation.zip
else
    # Alvo Mobile (Vertical / Portrait)
    PRODUCT_COPY_FILES += \
        vendor/iris/bootanimation/bootanimation_mobile.zip:$(TARGET_COPY_OUT_PRODUCT)/media/bootanimation.zip
endif

# Inclusão de Overlays RRO da identidade IrisOS
DEVICE_PACKAGE_OVERLAYS += vendor/iris/overlay/common
PRODUCT_PACKAGE_OVERLAYS += vendor/iris/overlay/branding
