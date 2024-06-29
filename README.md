# Proxmox ZFS built-in kernel builder: 
---
#### Containerized build system for kernels that support ZFS by default 

I've updated this repo to build kernel v6 using Ubuntu 24.04. They're a good match for Proxmox, since Proxmox tracks Ubuntu's kernels closely: The two are identical except for the name and a few patches linked below.

I've included a `.config` file from zen kernel on Arch in `build` dir: if you want to use your own `.config`, replace it before building, or pull your current config from `/usr/lib/modules/$(uname -r)/.config` or `zcat /proc/config.gz > .config` (even works inside build container). 

Codebase for Ubuntu/Proxmox PVE kernel: [https://github.com/proxmox/pve-kernel](https://github.com/proxmox/pve-kernel)
See (specifically) patches: [https://github.com/proxmox/pve-kernel/tree/master/patches/kernel](https://github.com/proxmox/pve-kernel/tree/master/patches/kernel) 

This build system I've created is entirely encapsulated in a docker container, so users don't have to install the plethora of dependencies required to build a kernel, and instead only need to install Docker (Podman, Nerdctl, etc.) If you'd rather run the image by itself, without downloading the rest of the build environment, the image is available from:

[docker://averyfreeman/proxmox-zfs-kernel-builder](docker://averyfreeman/proxmox-zfs-kernel-builder)

However, due to their read-only nature, customization not possible using image alone. You can, however, still use your own `.config` file, or whatever else could be referenced through the `build` folder (right now, `.config` is all that's supported).


      if you have suggestions, please submit a PR.



# This is a simple project with a singular purpose: 
#### to build a kernel that supports the ZFS filesystem without any additional configuration
---

## The stability of zfs as an in-tree module

- compiles zfs modules into kernel
- renders `zfs-initramfs`, `zfs-dracut`, `zfs-dkms` packages unnecessary
- when using this kernel, only need `zfs-utils` package
- build specified kernel (updated for v6.9+)
- Mainline build environment, using typical `.config` & `.patch` files 

## Kernel tested with Ubuntu only

To run, simply build the Dockerfile:

```bash
$ docker build . -t ubuntu-zfs-kernel
```

and then run the container with `$KERNEL_VERSION` and `$ZFS_VERSION` 

Example:
```bash
$ ./container_run.sh $KERNEL_VERSION $ZFS_VERSION
```

The above two arguments, `$KERNEL_VERSION` and `$ZFS_VERSION` **are required.**

Each build cycle creates `deb` packages (by default), along with `.tar` files.

You can add a 3rd argument to specify what kind of packages you want to build:
The options are `deb`, `tar` and `rpm` (`tar` builds `tar-zst`, but unfortunately
resulting packages don't appear to be compatible with Arch Linux)

Do note: The kernel config process will require some user intervention - simply hitting enter for all questions should be fine if you're in a hurry.

### Resources:

Find the versions you'd like to use with the builder from their source repositories:

- Latest kernel tags: [https://github.com/torvalds/linux](https://github.com/torvalds/linux)
- Latest zfs tags: [https://github.com/openzfs/zfs](https://github.com/openzfs/zfs)

`Last updated 20240628`
