# Silicon Motion SM750 driver module for CentOS 8

## Background
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

## Prepare
To build this module, you will need the `kernel-devel` package installed on your system to perform the
required out-of-tree build.

```bash
$ sudo dnf install kernel-devel
```
## Configure for Use of Module
The `sm750fb` module requires a `g_option` parameter containing the video details for the attached
display. Since installing the module will also cause an immediate load of the module, a value for `g_option`
should be set _before_ performing the module installation below.

This configuration can be done either via a file under `/etc/modprobe.d` or via the kernel command line. See
the `readme` file for details on the format for `g_option`. The examples below are for a 1920x1080 monitor
using the default refresh rate of 60 Hz.

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

## Installation
Two methods for installing this driver module are described below. The first sets up use of DKMS, which
will automatically rebuild the module any time a new kernel is installed. The second method is a basic
installation, which builds against the currently running kernel, and needs to be performed again any time
the kernel is updated.

### Installation Using DKMS
Linux's Dynamic Kernel Module Support (DKMS) package enables automatic build of a kernel module whenever
a new kernel is installed. To allow use of DKMS, this repository provides a ready-to-use `dkms.conf` file.

#### Install DKMS
Of course, the `dkms` package is required to use DKMS:

```bash
$ sudo dnf install dkms
```
#### Clone repository and install using DKMS
Setting up for builds of this module via DKMS is just a matter of cloning this repository and executing a
single `dkms` command:
```
$ git clone htpps://github.com/NCAR/sm750fb_centos8.git
...
$ sudo dkms install sm750fb_centos8
...
```
The dkms command above will:
 1. copy the cloned repository contents to `/usr/src/sm750fb_centos8-4.18`, which will then serve as DKMS's source code base for building the module
 2. set up automatic build upon future kernel updates
 3. build and install the module against the current running kernel

#### Verify
Execute `dkms status` to verify the installation. You should see a line of output as shown below.
```
$ dkms status sm750fb_centos8
sm750fb_centos8/4.18, 4.18.0-348.2.1.el8_5.x86_64, x86_64: installed
```
#### Stop use of DKMS
If desired, you can cancel use of DKMS and remove the automatically built `sm750fb` module(s) using the following command:
```
$ sudo dkms remove sm750fb_centos8/4.18
```

### Basic Installation
#### Clone, build, and install
```
$ git clone https://github.com/NCAR/sm750fb_centos8.git
...
$ cd sm750fb_centos8
$ make                  # Build the module as a normal user.
...
$ sudo -E make install  # Install as root. The -E is important here!
...
```
