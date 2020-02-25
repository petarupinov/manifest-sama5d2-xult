#########################################################
########## Linux4SAM: sync, checkout and build ##########
#########################################################

# 1. Repo init and sync
repo init -u https://github.com/petarupinov/manifest-sama5d2-xult.git -m sama5d2-xult-linux.xml
#repo init -u git://github.com/petarupinov/manifest-sama5d2-xult.git -m sama5d2-xult-linux.xml
repo sync -j4
# 2. Bootstrap - secondary bootloader
cd at91bootstrap/
git checkout remotes/origin/at91bootstrap-3.x -b base
git checkout -b dev
git reset --hard v3.9.0
make clean && make mrproper && make ARCH=arm CROSS_COMPILE=arm-none-eabi- distclean
make ARCH=arm CROSS_COMPILE=arm-none-eabi- sama5d2_xplaineddf_uboot_defconfig
make ARCH=arm CROSS_COMPILE=arm-none-eabi-
# 3. U-Boot - BOOTLOADER
cd ../u-boot-at91/
git checkout remotes/origin/u-boot-2019.04-at91 -b base
git checkout -b dev
git reset --hard linux4sam_6.2
make clean && make mrproper && make ARCH=arm CROSS_COMPILE=arm-none-eabi- distclean
make ARCH=arm CROSS_COMPILE=arm-none-eabi- sama5d2_xplained_spiflash_defconfig
make ARCH=arm CROSS_COMPILE=arm-none-eabi-
#./tools/mkenvimage -s 0x2000 -o u-boot-env.bin u-boot-env.txt
# 4. Kernel
cd ../ && cd linux-at91/
git checkout remotes/origin/linux-4.19-at91 -b base
git checkout -b dev
git reset --hard linux4sam_6.2
make clean && make mrproper && make ARCH=arm CROSS_COMPILE=arm-none-eabi- distclean
make ARCH=arm CROSS_COMPILE=arm-none-eabi- sama5_defconfig
make ARCH=arm CROSS_COMPILE=arm-none-eabi- -j$(nproc)
# 5. Device Tree Overlays (DTO) and Flattened Image Tree (FIT)
cd ../dt-overlay-at91/
export KERNEL_DIR=../linux-at91/
make ARCH=arm CROSS_COMPILE=arm-none-eabi- sama5d2_xplained_dtbos
make ARCH=arm CROSS_COMPILE=arm-none-eabi- sama5d2_xplained.itb
cd ../
