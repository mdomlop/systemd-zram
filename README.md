Systemd zRAM service
--------------------

Use a part of your RAM as compressed swap.


[`zram`](https://en.wikipedia.org/wiki/Zram) is a Linux kernel feature
that provides a form of virtual memory compression. `zram` module increases
performance by avoiding paging to disk and using a compressed block device in
RAM instead, inside which paging takes place until it is necessary to use the
swap space on a hard disk drive. Since using `zram` is an alternative way to
provide swapping on RAM, `zram` allows Linux to make a better use of RAM when
swapping/paging is required, especially on older computers with less RAM
installed.

This program provides a systemd service to automatically load and configure
such module at system boot.


Installation
------------

You can choose between different installation methods. Note that uninstallation
don't removes active zram disk.

### Classic method ###

- Build and install:

        $ make
        # make install

- Uninstall:

        # make uninstall

### Debian package ###

- Build and install:

        $ make deb
        # dpkg -i systemd-zram_*.deb

- Uninstall:

        # apt purge systemd-zram

Usage
-----

To start the service execute as root:

        # systemctl start systemd-zram

To stop it:

        # systemctl stop systemd-zram

If you want to enable zram at boot, just run as root:

        # systemctel enable systemd-zram

And for disable it at boot:

        # systemctl disable systemd-zram


