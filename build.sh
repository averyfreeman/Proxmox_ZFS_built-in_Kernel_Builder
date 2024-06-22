#!/usr/bin/env bash
# Last updated 20240619
# Script requires 2 arguments - 3rd will default to deb if no arg given:
# KERNEL_VER ZFS_VER
export KERNEL_VER=$1
export ZFS_VER=$2
export OPTION=$3
export VENDOR=$4

export CORES="$(echo "$(nproc) / 2" | bc -l | cut -d '.' -f1)"
echo "using $CORES cores"

case $OPTION in

  '')
    echo 'you chose nothing - defaulting to deb'
    export KERNEL_PKG='deb-pkg'
    export ZFS_PKG='deb' 
    ;;
  'all')
    echo 'you chose all'
    export KERNEL_PKG='deb-pkg rpm-pkg tarzst-pkg'
    export ZFS_PKG='deb rpm tgz' 
    ;;
  'tar')
    echo 'you chose tar'
    export KERNEL_PKG='tar-pkg'
    export ZFS_PKG='tgz' 
    ;;
  'rpm')
    echo 'you chose rpm'
    export KERNEL_PKG='rpm-pkg'
    export ZFS_PKG='rpm' 
    ;;
  'deb')
    echo 'you chose deb'
    export KERNEL_PKG='deb-pkg'
    export ZFS_PKG='deb' 
    ;;
esac
  # coming to a snapcraft container soon:
  # (is this option specifically for Ubuntu Core?):
  # 'snap')
  #   echo 'you chose snap (zfs will be deb)'
  #   export KERNEL_PKG='snap-pkg'
  #   export ZFS_PKG='deb' 
  #   ;;

if [[ $VENDOR ]]; then
  export VENDOR=$VENDOR
else
  export VENDOR=$(lsb_release -i -s)
fi

if [[ $3 -ne 0 ]]; then
  export APPENDAGE=.$3
else
  export APPENDAGE=".zfs"
fi



# echo "Requires three command line arguments, 3rd optional:"
echo "Requires two command line arguments - 3rd is optional (deb is default)"
echo "args \$4 can be \$VENDOR if not building for Ubuntu, \$5 will be suffix (broken)"
echo "usage: ./build.sh \$KERNEL_VER \$ZFS_VER \$PKG_TYPE"
echo "example: ./build.sh 6.9 2.2.4 rpm redhat"

# use gcc:
#export CC=cc CXX=c++ HOSTCC=cc HOSTCXX=c++ HOSTLD=ld STRIP=strip NM=nm OBJDUMP=objdump OBJCOPY=objcopy TOOLCHAIN="gnu"
# use clang:
export CC=clang; export CXX=clang++; export HOSTCC=clang; export HOSTCXX=clang++
export LD=ld.lld; export HOSTLD=ld.lld; export STRIP=llvm-strip; export NM=llvm-nm
export OBJDUMP=llvm-objdump; export OBJCOPY=llvm-objcopy; export DLLTOOL=llvm-dlltool
export TOOLCHAIN="llvm"


# note: $APPENDAGE doesn't echo variable in sed (kernel conf)
# APPENDAGE=.clang.zfs 

echo "Creating build directory and downloading source files"
PROJECTROOT=$(pwd)/build
if test -f "$PROJECTROOT"; then
    echo "$PROJECTROOT exists."
   else
    mkdir $PROJECTROOT
fi

cd $PROJECTROOT

git clone -b v$KERNEL_VER --depth 1 https://github.com/torvalds/linux.git linux-$KERNEL_VER
git clone -b zfs-$ZFS_VER --depth 1 https://github.com/openzfs/zfs.git zfs-$ZFS_VER

export ZFS_DIR=$(pwd)/zfs-$ZFS_VER
export KERNEL_DIR=$(pwd)/linux-$KERNEL_VER

cd $KERNEL_DIR

if [[ -f /app/.config ]] ; then
    cp /app/.config $KERNEL_DIR/.config
    echo "Copied .config file from $PROJECTROOT"
  else
    echo "kernel .config file not found in $PROJECTROOT, using"
    echo ".config file from currently running kernel"
    echo "command: zcat /proc/config.gz > .config"
    zcat /proc/config.gz > $KERNEL_DIR/.config
    # exit 1
fi

make oldconfig

echo "Setting kernel build flags - IMPORTANT NOTE: "
echo "This process will likely ask you questions later, so keep an eye on it"

echo "Adding $APPENDAGE string to the end of the kernel identifier"

sed -i 's/CONFIG_LOCALVERSION="*.*/CONFIG_LOCALVERSION=".zfs"/g' .config

echo "Saving as default .config for future reference"
make savedefconfig

echo "Preparing - Note:"
echo "if orig .config is older than $KERNEL_VER, it might ask you about new features"
echo "But you can safely hit ENTER through all of these questions"

make -j$CORES modules modules_prepare

echo "Creating configuration for zfs build"
cd $ZFS_DIR

export CC=clang; export CXX=clang++; HOSTCC=clang; export HOSTCXX=clang++
export LD=ld.lld; export HOSTLD=ld.lld; export STRIP=llvm-strip
export NM=llvm-nm; export OBJDUMP=llvm-objdump; export OBJCOPY=llvm-objcopy
export DLLTOOL=llvm-dlltool; export TOOLCHAIN="llvm"
# possible flags
export WITH_GNU_LD="--with-gnu-ld=no"
export WITH_VENDOR="--with-vendor=$VENDOR"


make clean && make distclean
sh autogen.sh

# --disable-silent-rules \

./configure \
  $WITH_VENDOR \
  $WITH_GNU_LD \
  --prefix=/usr \
  --disable-nls \
  --enable-linux-builtin \
  --enable-pam \
  --enable-pyzfs \
  --without-libintl-prefix \
  --with-linux="$KERNEL_DIR" \
  --with-linux-obj="$KERNEL_DIR"
  
echo "Copying built-in modules to kernel dir"
./copy-builtin $KERNEL_DIR

echo "Building zfs base"
make -j$CORES 
make -j$CORES $ZFS_PKG

echo "Building kernel -- *** IF IT ASKS YOU ABOUT ZFS, SAY y !! ***"
cd $KERNEL_DIR
export CC=cc; export CXX=c++; export HOSTCC=cc; export HOSTCXX=c++; export HOSTLD=ld
export STRIP=strip; export NM=nm; export OBJDUMP=objdump; export OBJCOPY=objcopy

cat >>.config <<EOF
CONFIG_ZFS=y
EOF
echo ".config appended with CONFIG_ZFS=y"

# now make kernel
make -j$CORES bzImage
cp -v ./arch/x86/boot/bzImage /app/build/vmlinuz

# tar first, since packaging can rely on .tar
make -j$CORES tar-pkg
make -j$CORES $KERNEL_PKG

# move pkgs to output dir build
cd $PROJECTROOT

for pkg in $(find . -type f \( \
  -name '*.deb' -o -name '*.rpm' \
  -o -name '*.tar' -o -name '*.tar.gz' \)); do 
  mv $pkg $PROJECTROOT; 
done

mkdir unnecessary-pkgs
mv zfs-initramfs* zfs-dracut* zfs-dkms* unnecessary-pkgs/
echo "All done!  Your package files should be in build dir, with the"
echo "ones rendered unnecessary by the zfs kernel moved to"
echo "unnecessary-pkgs dir"
# which rpm is used for the zfs CLI tools?
# echo "If you created rpms, try using the kmod-zfs package to install CLI utils"
