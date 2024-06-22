#!/bin/bash
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export TZ='America/Los_Angeles'
cd /app
# bash bootstrap.sh
apt-get update && apt-get upgrade -y
printf "\n"
printf "\nI made this container interactive by default since it requires 2 arguments"
printf "\nHere are what you need to get started:"
printf "\n\n"
printf "\nkernel version - tracks git repo tags - reference:"
printf "\nLinux kernel: https://github.com/torvalds/linux/tags"
printf "\nHead -n3 as of 20240621 (descending): 6.10-rc4 (through rc1) - 6.9 - 6.8"
printf "\n\n"
printf "\nzfs version - tracks git repo tags - reference:"
printf "\nOpenzfs zfs: https://github.com/openzfs/zfs/tags"
printf "\nHead -n5 as of 20240621 (descending): 2.2.4 - 2.1.15 - 2.2.3 - 2.2.2 - 2.1.14"
printf "\n\n"
printf "\nchoice of deb, rpm or zst (all will build .tar) zst for Arch Linux + derivs):"
printf "\n\n"
printf "\n2 extra arguments are possible (optional):"
printf "\nVendor option - from zfs configure - use all lowercase:  toss fedora redhat"
printf "\ngentoo arch sles slackware lunar ubuntu debian alpine openeuler\n"
printf "\n(I am in the process of splitting to different containers for each OS)\n"
printf "\n"
printf "\nbuild using build.sh + args"
printf "\n./build.sh \$KERNEL_VERSION \$ZFS_VERSION \$BUILD_OPTION \$VENDOR"
printf "\nkernel and zfs versions required, build options are deb, rpm or tar "
printf "\n - if you put nothing for the 3rd argument, it builds debs as ubuntu"
printf "\n\n"
printf "\nexample:"
printf "\n./build.sh 6.10-rc4 2.2.4 all ubuntu"
printf "\nif you want to try re-installing all depends, can run ./bootstrap.sh (no args)"
printf "\nGood luck!\n"
bash
