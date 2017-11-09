#!/bin/sh

# Antonio Galea <antonio.galea@gmail.com>
# Thanks to Przemysław Tomczyk for suggesting swapoff parallelization
# Systemd service and packaging by Manuel Domínguez López <mdomlop@gmail.com>
# Distributed under the GPL version 3 or above, see terms at
#      https://gnu.org/licenses/gpl-3.0.txt

PROGRAM_NAME='systemd-zram'
DESCRIPTION='Use compressed RAM as in-memory swap'
VERSION='0.1b'
AUTHOR='Antonio Galea'  # See AUTHORS file
MAIL='antonio.galea@gmail.com'
LICENSE='GPLv3+'  # Read LICENSE file.

FRACTION=75

#MEMORY=`perl -ne'/^MemTotal:\s+(\d+)/ && print $1*1024;' < /proc/meminfo`
MEMORY=`grep ^MemTotal: /proc/meminfo | awk '{print $2 * 1024}'`
CPUS=`nproc`
SIZE=$(( MEMORY * FRACTION / 100 / CPUS ))

case "$1" in
  "start")
    param=`modinfo zram|grep num_devices|cut -f2 -d:|tr -d ' '`
    modprobe zram $param=$CPUS
    for n in `seq $CPUS`; do
      i=$((n - 1))
      echo $SIZE > /sys/block/zram$i/disksize
      mkswap /dev/zram$i
      swapon /dev/zram$i -p 10
    done
    ;;
  "stop")
    for n in `seq $CPUS`; do
      i=$((n - 1))
      swapoff /dev/zram$i && echo "disabled disk $n of $CPUS" &
    done
    wait
    sleep .5
    modprobe -r zram
    ;;
  *)
    echo "Usage: `basename $0` (start | stop)"
    exit 1
    ;;
esac
