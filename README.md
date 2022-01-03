# Silicon Motion SM750 driver module for CentOS 8

## Introduction
This project provides a usable CentOS 8 driver for the the Silicon Motion SM750 display controller. While the Linux
kernel source contains the necessary pieces for a functional driver, kernels built for CentOS 8 do not provide all
of them. The easiest way I found to get a working driver was to extract the needed pieces from the kernel source tree
and put them together in a way that can be built simply as an out-of-tree kernel module for CentOS 8.

The assembled pieces are:
* `drivers/staging/sm750fb`

  The `sm750fb` driver exists in the "staging" part of the Linux core kernel tree, but the driver is not built or provided
  as a kernel module package for CentOS 8. The `smb750fb` source code from the Linux kernel source tree is replicated here.
  
* `drivers/video/fbdev/core/modedb.c`

  The `smb750fb` driver requires some symbols which are provided by the kernel's existing `modedb.c`, but they are
  _only_ provided if the Linux kernel is configured with `CONFIG_FB_MODE_HELPERS=y`. Since CentOS 8 kernels are not
  built with `CONFIG_FB_MODE_HELPERS` set, the needed symbols must be provided by the driver module itself (or a custom
  kernel must be built using `CONFIG_FB_MODE_HELPERS=y`). For simplicity, the small chunk of `modedb.c` containing the
  needed symbols has been extracted into this repository's `fb_mode_helpers.c` file.

## How to Install
### Prepare
You need the `kernel-devel` package installed on your system to perform the required out-of-tree build of this module.

```bash
$ sudo dnf install kernel-devel
```

### Clone and build
```
$ git clone https://github.com/NCAR/sm750fb_centos8
...(git messages)...
$ cd sm750fb_centos8
$ make                  # Build the module as a normal user.
...build messages...

```
### Configure for use
The `sm750fb` module needs to be told the video resolution of the attached display. This can be done with
a file under `/etc/modprobe.d` or via the kernel command line. See the `readme` file in the repository for
details on the video resolution format. The examples below assume a 1920x1080 monitor using the default
refresh rate of 60 Hz.

 - **via modprobe.d file**
   
   Create a file under `/etc/modprobe.d` with the monitor details. Mine is named `/etc/modprobe.d/sm750fb.conf`,
   and looks like this:
   
   ```
   #
   # Monitor timing to use for the sm750fb (Silicon Motion SM750) framebuffer
   # graphics driver
   #
   options sm750fb g_option=1920x1080	# HD monitor
   ```

 - **via kernel command line**

   The equivalent configuration provided on the kernel command line would be:
   ```
   sm750fb.g_option=1920x1080
   ```

### Install the module
The command below will install the module in the appropriate location under `/lib/modules`. _The module will
also load automatically_ after the installation if the the SM750 device is attached to the system, so make
sure you've configured as described above before you proceed! 
```
$ sudo -E make install  # Install as root. The -E is important here!
...install messages...
```
