#!/bin/bash
rm .version
# Color Code Script
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White
nocol='\033[0m'         # Default

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
DEFCONFIG="karate_defconfig"
KERNEL="Image.gz-dtb"

# Hyper Kernel Details
BASE_VER="Raiden-o"
VER="-$(date +"%Y-%m-%d"-%H%M)"
K_VER="$BASE_VER$VER-karate"

# Vars
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="arunkumar"
export KBUILD_BUILD_HOST="BlackBox"

# Paths
KERNEL_DIR=`pwd`
RESOURCE_DIR="/home/arun_assain98/kernel"
ANYKERNEL_DIR="$RESOURCE_DIR/Raiden"
TOOLCHAIN_DIR="/home/arun_assain98/kernel/toolchain"
REPACK_DIR="$ANYKERNEL_DIR"
PATCH_DIR="$ANYKERNEL_DIR/patch"
MODULES_DIR="$ANYKERNEL_DIR/modules"
ZIP_MOVE="$RESOURCE_DIR/kernel_out"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm64/boot"


# Functions
function make_kernel {
		make $DEFCONFIG $THREAD
                make savedefconfig
		make $KERNEL $THREAD
                make dtbs $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

function make_modules {
		cd $KERNEL_DIR
		make modules $THREAD
                mkdir $MODULES_DIR
		find $KERNEL_DIR -name '*.ko' -exec cp {} $MODULES_DIR/ \;
		cd $MODULES_DIR
        $STRIP --strip-unneeded *.ko && mkdir pronto && mv wlan.ko pronto_wlan.ko && mv pronto_wlan.ko pronto
        cd $KERNEL_DIR
}

function make_zip {
		cd $REPACK_DIR
                zip -r `echo $K_VER`.zip *
                mkdir $ZIP_MOVE
		mv  `echo $K_VER`.zip $ZIP_MOVE
		cd $KERNEL_DIR
}

DATE_START=$(date +"%s")

		export CROSS_COMPILE=$TOOLCHAIN_DIR/bin/aarch64-linux-gnu-
		export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/lib/
                STRIP=$TOOLCHAIN_DIR/bin/aarch64-linux-gnu-strip
		rm -rf $MODULES_DIR/*
		rm -rf $ZIP_MOVE/*
		cd $ANYKERNEL_DIR
		rm -rf zImage
                cd $KERNEL_DIR
		make clean && make mrproper
		echo "cleaned directory"
		echo "Compiling Raiden-Kernel"

echo -e "${restore}"

		make_kernel
                #make_modules
		make_zip

echo -e "${green}"
echo $K_VER.zip
echo "------------------------------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo " "
cd $ZIP_MOVE
ls
