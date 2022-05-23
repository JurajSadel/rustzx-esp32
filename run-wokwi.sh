#!/usr/bin/env bash

set -e

# Gitpod tasks do not source the user environment
if [ "${USER}" == "gitpod" ]; then
    export CURRENT_PROJECT=/workspace/rustzx-esp32
    which idf.py >/dev/null || {
        source /home/gitpod/export-rust.sh > /dev/null 2>&1
        export IDF_TOOLS_PATH=/home/gitpod/.espressif
        source /home/gitpod/.espressif/frameworks/esp-idf-release-v4.4/export.sh
    }
else
    export CURRENT_PROJECT=~/workspace/
fi

pip3 install websockets==10.2

# ESP32 board
export ESP_BOARD="esp32s2"
export ESP_ELF="rustzx-esp32"

if [ "${ESP_BOARD}" == "esp32c3" ]; then
    export WOKWI_PROJECT_ID="330910629554553426"
    export ESP_ARCH="riscv32imc-esp-espidf"
    export ESP_BOOTLOADER_OFFSET="0x0000"
    export ESP_PARTITION_TABLE_OFFSET="0x8000"
    export ESP_APP_OFFSET="0x10000"
elif [ "${ESP_BOARD}" == "esp32s2" ]; then
    export WOKWI_PROJECT_ID="330831847505265234"
    export ESP_ARCH="xtensa-esp32s2-espidf"
    export ESP_BOOTLOADER_OFFSET="0x1000"
    export ESP_PARTITION_TABLE_OFFSET="0x8000"
    export ESP_APP_OFFSET="0x10000"
else
    export WOKWI_PROJECT_ID="331440829570744915"
    export ESP_ARCH="xtensa-esp32-espidf"
    export ESP_BOOTLOADER_OFFSET="0x1000"
    export ESP_PARTITION_TABLE_OFFSET="0x8000"
    export ESP_APP_OFFSET="0x10000"
fi

cargo +esp espflash save-image app.bin --target "${ESP_ARCH}" --release --features "esp32s2_ili9341"

find target/${ESP_ARCH}/release -name bootloader.bin -exec cp {} . \;
find target/${ESP_ARCH}/release -name partition-table.bin -exec cp {} . \;

echo "Project URL:  https://wokwi.com/projects/${WOKWI_PROJECT_ID}"
python3  ~/esp32-wokwi-gitpod-websocket-server/server.py

