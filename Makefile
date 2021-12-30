obj-m	+= sm750fb.o

sm750fb-objs := sm750.o sm750_hw.o sm750_accel.o sm750_cursor.o ddk750_chip.o ddk750_power.o \
		ddk750_mode.o ddk750_display.o ddk750_swi2c.o ddk750_sii164.o ddk750_dvi.o \
		ddk750_hwi2c.o

# Add fb_mode_helpers.c to provide required video mode database "helpers" which are required,
# but not built into the CentOS 8 kernel. The content of fb_mode_helpers.c is extracted from
# drivers/video/fbdev/core/modedb.c.
sm750fb-objs += fb_mode_helpers.o

modules:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

modules_install:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules_install

install: modules_install

clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
