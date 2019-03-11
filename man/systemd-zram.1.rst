==============
 systemd-zram
==============

-----------------------------------------
Use a part of your RAM as compressed swap
-----------------------------------------

:Author: Manuel Domínguez López <mdomlop@gmail.com>
:Date:   2019-01-11
:Copyright: GPLv3
:Version: 1.0
:Manual section: 1
:Manual group: system tools

SINOPSIS
========

With systemd:

``systemctl`` [start | stop | enable | disable] ``systemd-zram``

If no systemd systemd-zram.service is running:

``systemd-zram`` [start | stop]

DESCRIPTION
============

``zram`` is a Linux kernel feature that provides a form of virtual memory
compression. ``zram`` module increases performance by avoiding paging to disk and
using a compressed block device in RAM instead, inside which paging takes place
until it is necessary to use the swap space on a hard disk drive. Since using
``zram`` is an alternative way to provide swapping on RAM, ``zram`` allows Linux
to make a better use of RAM when swapping/paging is required, especially on
older computers with less RAM installed.

This program provides a systemd service to automatically load and configure
such module at system boot.

By default ``systemd-zram`` compress the 75 % of RAM with ``lzo`` compression
algorithm. By editing systemd service you can choose different compression
algorithm or percentage. To see available algorithms do
``cat /sys/block/zram0/comp_algorithm`` once time ``zram`` module is loaded.

SYSTEMD SERVICE EDITING
=======================

If you want tune compression method or percentage of RAM used by this program
you must edit the associated systemd service.

Execute ``systemctl edit systemd-zram`` and change the values of this variables:

    Environment=COMP_ALGORITHM=lzo

or

    Environment=FRACTION=75

If you choose a compression algorithm that is not included in
``/sys/block/zram0/comp_algorithm``, the program will complaint and fallback to
the default value, which is ``lzo``.

If you choose an invalid value for percent-value of ``FRACTION``, the program
will fallback to ``75``.


EXECUTION WITH SYSTEMD
======================

Although it is perfectly possible to run this program directly, this is not
recommended at all if the systemd service is active in some way.

The recommended method of execution is through systemd:

To start the service execute as root:

    # systemctl start systemd-zram

To stop it:

    # systemctl stop systemd-zram

If you want to enable zram at boot, just run as root:

    # systemctl enable systemd-zram

And for disable it at boot:

    # systemctl disable systemd-zram


FILES
=====

``/usr/bin/systemd-zram.sh``
    The program itself. A shell script with all the code.
``/usr/lib/systemd/system/systemd-zram.service``
    The associated systemd service. It controls the execution of the program.


BUGS
====

Please if you found one, let me know.

Report bugs to <mdomlop@gmail.com>


SEE ALSO
========

systemd(1) systemd.service(5)

