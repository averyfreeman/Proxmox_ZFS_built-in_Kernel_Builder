# zfs kernel builder

I've updated this repo to build kernel v6 using Ubuntu 24.04
Also a good match for Proxmox, as Proxmox uses Ubuntu kernels
I've included a `.config` file  from the zen kernel in build dir
if you want to use your own `.config`, replace it before building

Sources for `.config` are places like `/usr/lib/modules/$KVER/.config`
or `zcat /proc/config.gz` to use your own

The build system is entirely encapsulated in a docker container,
so you don't have to install any local dependencies other than Docker.
If you'd rather run the builder without building the container
The docker container is docker://averyfreeman/zfs-kernel-builder
but customization is not possible

      if you have suggestions, please submit a PR.

---

## The stability of zfs as an in-tree module

- compiles zfs modules into kernel
- renders `zfs-initramfs`, `zfs-dracut`, `zfs-dkms` packages unnecessary
- when using this kernel, only need `zfs-utils` package
- build specified kernel (updated for v6.9+)
- Vanilla build system: incorporate your own `.config` 

## Kernel tested with Ubuntu only

To run, simply build the Dockerfile:

```bash
$ docker build . -t zfs-kernel-builder
```

and then run the container with `$KERNEL_VERSION` and `$ZFS_VERSION` 

Example:
```bash
$ ./container_run.sh $KERNEL_VERSION $ZFS_VERSION
```

The above two arguments, `$KERNEL_VERSION` and `$ZFS_VERSION` **are required.**

Do note: The kernel config process will require some user intervention - simply hitting enter for all questions should be fine if you're in a hurry.

### Resources:

Find the versions you'd like to use with the builder:

- Latest kernel tags: [https://github.com/torvalds/linux](https://github.com/torvalds/linux)
- Latest zfs tags: [https://github.com/openzfs/zfs](https://github.com/openzfs/zfs)

Tested Ubuntu 24.04.
