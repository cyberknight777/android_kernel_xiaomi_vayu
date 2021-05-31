#!/usr/bin/bash

export ARCH=arm64
export SUBARCH=arm64
export CONFIG=nethunter_defconfig
export CURRENTDIR=$(pwd)
export PATH=$CURRENTDIR/compiler/toolchains/proton-clang/bin:$PATH
export ZIPNAME="kernel-nethunter-vayu-$(date '+%Y%m%d').zip"
echo "#"
echo "# Menuconfig"
echo "#"
make O=out $CONFIG;
make O=out CC="ccache clang" LD=ld.lld AS=llvm-as NM=llvm-nm STRIP=llvm-strip OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf HOSTAS=llvm-as HOSTLD=ld.lld CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- menuconfig
cp -rf out/.config arch/arm64/configs/$CONFIG;

echo "#"
echo "# Compile Kernel"
echo "#"
make O=out CC=clang $CONFIG;
time make -j$(nproc --all) O=out CC="ccache clang" LD=ld.lld AS=llvm-as NM=llvm-nm STRIP=llvm-strip OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf HOSTAS=llvm-as HOSTLD=ld.lld CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- Image.gz-dtb dtbo.img
echo -e "\033[1;36mPress enter to continue \e[0m"
read a1

echo "#"
echo "# Compile set of modules to out/modules"
echo "#"
mkdir -p out/modules
make CC=clang CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- O=out modules_prepare 
make CC=clang CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- O=out modules INSTALL_MOD_PATH=$CURRENTDIR/out/modules
make CC=clang CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- O=out modules_install INSTALL_MOD_PATH=$CURRENTDIR/out/modules
echo -e "\033[1;36mPress enter to continue \e[0m"
read a1

echo "#"
echo "# Making Anykernel3.zip"
echo "#"
find out/arch/arm64/boot/dts/qcom -name '*.dtb' -exec cat {} + > out/arch/arm64/boot/dtb
cp out/arch/arm64/boot/dtbo.img anykernel3-vayu
cp out/arch/arm64/boot/dtb anykernel3-vayu
cp out/arch/arm64/boot/Image.gz-dtb anykernel3-vayu
find out/modules/lib/modules/4.14.190-cyberknight777-1.0/ -type f -iname '*.ko' -exec cp {} anykernel3-vayu/modules/system/lib/modules/ \;
cd anykernel3-vayu
zip -r9 $ZIPNAME *
exit 0
