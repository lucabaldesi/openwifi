#!/bin/bash
if [ "$#" -ne 3 ]; then
    echo "You must enter exactly 3 arguments: \$OPENWIFI_DIR \$XILINX_DIR ARCH_BIT(32 or 64)"
    exit 1
fi

OPENWIFI_DIR=$1
XILINX_DIR=$2
ARCH_OPTION=$3

if [ -f "$OPENWIFI_DIR/LICENSE" ]; then
    echo "\$OPENWIFI_DIR is found!"
else
    echo "\$OPENWIFI_DIR is not correct. Please check!"
    exit 1
fi

if [ -d "$XILINX_DIR/SDK" ]; then
    echo "\$XILINX_DIR is found!"
else
    echo "\$XILINX_DIR is not correct. Please check!"
    exit 1
fi

if [ "$ARCH_OPTION" != "32" ] && [ "$ARCH_OPTION" != "64" ]; then
    echo "\$ARCH_OPTION is not correct. Should be 32 or 64. Please check!"
    exit 1
else
    echo "\$ARCH_OPTION is valid!"
fi

source $XILINX_DIR/SDK/2018.3/settings64.sh
if [ "$ARCH_OPTION" == "64" ]; then
    LINUX_KERNEL_SRC_DIR=$OPENWIFI_DIR/adi-linux-64/
    ARCH="arm64"
    CROSS_COMPILE="aarch64-linux-gnu-"
else
    LINUX_KERNEL_SRC_DIR=$OPENWIFI_DIR/adi-linux/
    ARCH="arm"
    CROSS_COMPILE="arm-none-eabi-"
fi

# check if user entered the right path to analog device linux
if [ -d "$LINUX_KERNEL_SRC_DIR" ]; then
    echo " setup linux kernel path ${LINUX_KERNEL_SRC_DIR}"
else
    echo "Error: path to adi linux: ${LINUX_KERNEL_SRC_DIR} not found. Can not continue."
    exit 1
fi

set -x

home_dir=$(pwd)

cd $OPENWIFI_DIR/driver/side_ch
make KDIR=$LINUX_KERNEL_SRC_DIR ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE

cd $home_dir