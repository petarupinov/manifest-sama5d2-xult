#########################################################
########## Linux4SAM: sync, checkout and build ##########
#########################################################

# 1. Repo init and sync
repo init -u https://github.com/petarupinov/manifest-sama5d2-xult.git -m sama5d2-xult-linux.xml
#repo init -u git://github.com/petarupinov/manifest-sama5d2-xult.git -m sama5d2-xult-linux.xml
repo sync -j4
# 2. Bootstrap - secondary bootloader
cd at91bootstrap/
git checkout remotes/linux4sam/at91bootstrap-3.x -b base
git checkout -b dev
git reset --hard v3.9.0
make clean && make mrproper && make ARCH=arm CROSS_COMPILE=arm-none-eabi- distclean | tee clean_at91bootstrap.log
make ARCH=arm CROSS_COMPILE=arm-none-eabi- sama5d2_xplaineddf_uboot_defconfig | tee config_at91bootstrap.log
make ARCH=arm CROSS_COMPILE=arm-none-eabi- | tee build_at91bootstrap.log
# 3. U-Boot - BOOTLOADER
cd ../u-boot-at91/
git checkout remotes/linux4sam/u-boot-2019.04-at91 -b base
git checkout -b dev
git reset --hard linux4sam_6.2
make clean && make mrproper && make ARCH=arm CROSS_COMPILE=arm-none-eabi- distclean | tee clean_u-boot-at91.log
make ARCH=arm CROSS_COMPILE=arm-none-eabi- sama5d2_xplained_spiflash_defconfig | tee config_u-boot-at91.log
make ARCH=arm CROSS_COMPILE=arm-none-eabi- | tee build_u-boot-at91.log
cp ../u-boot-env.txt .
./tools/mkenvimage -s 0x2000 -o u-boot-env.bin u-boot-env.txt | tee build_u-boot-env.log
# 4. Kernel
cd ../ && cd linux-at91/
git checkout remotes/linux4sam/linux-4.19-at91 -b base
git checkout -b dev
git reset --hard linux4sam_6.2
make clean && make mrproper && make ARCH=arm CROSS_COMPILE=arm-none-eabi- distclean | tee clean_kernel.log
make ARCH=arm CROSS_COMPILE=arm-none-eabi- sama5_defconfig | tee config_kernel.log
make ARCH=arm CROSS_COMPILE=arm-none-eabi- -j$(nproc) | tee build_kernel.log
# 5. Device Tree Overlays (DTO) and Flattened Image Tree (FIT)
cd ../dt-overlay-at91/
export KERNEL_DIR=../linux-at91/
make ARCH=arm CROSS_COMPILE=arm-none-eabi- sama5d2_xplained_dtbos | tee build_dtbos.log
make ARCH=arm CROSS_COMPILE=arm-none-eabi- sama5d2_xplained.itb | tee build_itb.log
cd ../
