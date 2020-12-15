  
#!/bin/bash
if [ "$#" -lt 3 ]; then
    echo "You must enter at least 3 arguments: \$OPENWIFI_DIR \$XILINX_DIR ARCH_BIT(32 or 64)"
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

if [ "$ARCH_OPTION" == "64" ]; then
    LINUX_KERNEL_SRC_DIR_NAME=adi-linux-64
    LINUX_KERNEL_CONFIG_FILE=$OPENWIFI_DIR/kernel_boot/kernel_config_zynqmp
    ARCH_NAME="arm64"
    CROSS_COMPILE_NAME="aarch64-linux-gnu-"
    IMAGE_TYPE=Image
else
    LINUX_KERNEL_SRC_DIR_NAME=adi-linux
    LINUX_KERNEL_CONFIG_FILE=$OPENWIFI_DIR/kernel_boot/kernel_config
    ARCH_NAME="arm"
    CROSS_COMPILE_NAME="arm-none-eabi-"
    IMAGE_TYPE=uImage
fi

home_dir=$(pwd)

set -x

cd $OPENWIFI_DIR/
git submodule init $LINUX_KERNEL_SRC_DIR_NAME
git submodule update $LINUX_KERNEL_SRC_DIR_NAME
cd $OPENWIFI_DIR/$LINUX_KERNEL_SRC_DIR_NAME
git checkout 2019_R1
git pull origin 2019_R1
cp $OPENWIFI_DIR/driver/xilinx_dma/xilinx_dma.c $OPENWIFI_DIR/$LINUX_KERNEL_SRC_DIR_NAME/drivers/dma/xilinx/xilinx_dma.c
cp $LINUX_KERNEL_CONFIG_FILE ./.config
source $XILINX_DIR/SDK/2018.3/settings64.sh
export ARCH=$ARCH_NAME
export CROSS_COMPILE=$CROSS_COMPILE_NAME

make oldconfig && make prepare && make modules_prepare

if [ "$#" -gt 3 ]; then
    if [ -f "$OPENWIFI_DIR/$LINUX_KERNEL_SRC_DIR_NAME/arch/$ARCH_NAME/boot/$IMAGE_TYPE" ]; then
        echo "Kernel found! Skip the time costly Linux kernel compiling."
    else
        make -j12 $IMAGE_TYPE UIMAGE_LOADADDR=0x8000
        make modules
    fi
fi

cd $home_dir
