#
# Copyright (C) 2026 The IrisOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#

# Herdando configurações da base LineageOS
$(call inherit-product-if-exists, vendor/lineage/config/common.mk)

# Carrega a identidade e versionamento do IrisOS
include vendor/iris/config/version.mk
include vendor/iris/config/branding.mk

# Propriedades de Usabilidade e Performance
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    persist.sys.timezone=America/Sao_Paulo \
    ro.config.notification_sound=Argon.ogg \
    ro.config.alarm_alert=Helium.ogg \
    ro.config.ringtone=Orion.ogg

# Se o alvo for PC (x86_64), ativa o modo Desktop e suporte a múltiplas janelas livres
ifeq ($(TARGET_ARCH),x86_64)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    persist.sys.debug.desktop_mode=true \
    persist.sys.freeform_window=true \
    ro.iris.target=pc
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.iris.target=mobile
endif

# Pacotes essenciais do IrisOS
PRODUCT_PACKAGES += \
    IrisWallpapers
