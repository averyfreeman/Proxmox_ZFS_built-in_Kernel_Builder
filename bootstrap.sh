#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update

echo "If you're running this script outside of the dockerized build environment"
echo "please note, it installs requirements for building kernels on a debian-based"
echo "distribution, and was specifically written using ubuntu 24.04" 
echo "YMMV on other platforms."

echo "are build scripts going to complain if I dont reinstall everything in Dockerfile?" 
apt-get install -y apt-utils language-pack-en-base
apt-get build-dep -y linux-meta
apt-get install -y build-essential autoconf automake libtool \
	gawk alien fakeroot curl dkms libblkid-dev uuid-dev libudev-dev \
	libssl-dev zlib1g-dev libaio-dev libattr1-dev libelf-dev \
	linux-headers-generic python3 python3-dev python3-setuptools \
	python3-cffi libffi-dev dwarves llvm clang lld lldb libpam0g-dev \
	git byacc bc bison flex rsync language-pack-en rpm tar gzip zstd \
	alien python3-setuptools-whl python3-distutils-extra python3-pytest-runner \
	python3-stdeb python3-distlib python3-packaging python3-cffi libblkid-dev \
	libtirpc-dev libpam0g-dev rpm bash-completion python3-argcomplete \
	libcurl4-openssl-dev debhelper dh-python po-debconf python3-all-dev \
	python3-sphinx parallel cppcheck shellcheck udisks2 udisks2-lvm2 libpmemblk-dev \
	libpmemblk1-debug blktool blktrace libdevmapper-dev libprimecount-dev gvfs-libs

zcat /proc/config.gz > /app/.config
