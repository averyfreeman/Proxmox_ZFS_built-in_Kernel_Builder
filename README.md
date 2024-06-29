# Ubuntu ZFS kernel builder - 
---
#### builds kernel that supports ZFS by default 

I've updated this repo to build kernel v6 using Ubuntu 24.04. They're
a good match for Proxmox, since Proxmox tracks Ubuntu's kernel dev tree.
I've included a `.config` file from zen kernel on Arch in `build` dir:
if you want to use your own `.config`, replace it before building, or
pull your current config from `/usr/lib/modules/$(uname -r)/.config` or
`zcat /proc/config.gz > .config` (even works inside build container). 

Codebase for Proxmox PVE kernel: [https://github.com/proxmox/pve-kernel](https://github.com/proxmox/pve-kernel)
See (specifically) patches: [https://github.com/proxmox/pve-kernel/tree/master/patches/kernel](https://github.com/proxmox/pve-kernel/tree/master/patches/kernel) 

The build system is entirely encapsulated in a docker container,
so you don't have to install any local dependencies other than Docker.
If you'd rather run the image without the rest of the build environment, 
an image is available from [docker://averyfreeman/zfs-kernel-builder](docker://averyfreeman/zfs-kernel-builder),
however customization not possible using image alone (read-only).

      if you have suggestions, please submit a PR.

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

Do note: The kernel config process will require some user intervention - simply hitting enter for all questions should be fine if you're in a hurry.

### Resources:

Find the versions you'd like to use with the builder from their source repositories:

- Latest kernel tags: [https://github.com/torvalds/linux](https://github.com/torvalds/linux)
- Latest zfs tags: [https://github.com/openzfs/zfs](https://github.com/openzfs/zfs)

`Last updated 20240628`
