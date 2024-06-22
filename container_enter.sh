#!/bin/bash
IMAGE=$1
# IMAGE="averyfreeman/zfs-kernel-builder-ubuntu"
echo "this script runs the container image in interactive mode (opens command prompt)" 
echo "if you are not getting enough feedback, try running"
echo "dpkg-reconfigure debconf"
echo "and set to interactive mode" 
docker run -v $(pwd)/build:/app/build -it $IMAGE /bin/bash
