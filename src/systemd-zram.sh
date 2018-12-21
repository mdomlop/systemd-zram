#!/bin/sh

# Antonio Galea <antonio.galea@gmail.com>
# Thanks to Przemysław Tomczyk for suggesting swapoff parallelization
# Systemd service and packaging by Manuel Domínguez López <mdomlop@gmail.com>
# Distributed under the GPL version 3 or above, see terms at
#      https://gnu.org/licenses/gpl-3.0.txt

EXECUTABLE_NAME='systemd-zram'
PROGRAM_NAME='Systemd zRAM'
DESCRIPTION='Use compressed RAM as in-memory swap'
VERSION='0.1b'
AUTHOR='Manuel Domínguez López'  # See AUTHORS file
MAIL='mdomlop@gmail.com'
LICENSE='GPLv3+'  # Read LICENSE file.

FRACTION=50
COMP_ALGORITHM='lzo'

#MEMORY=`perl -ne'/^MemTotal:\s+(\d+)/ && print $1*1024;' < /proc/meminfo`
MEMORY=`grep ^MemTotal: /proc/meminfo | awk '{print $2}'`
CPUS=`nproc`
SIZE=$(( MEMORY * FRACTION / 100 / CPUS ))

case "$1" in
  "start")
    modprobe zram num_devices=$CPUS

    # Check compression algorithm support
    if [ `grep -c "$COMP_ALGORITHM" /sys/block/zram0/comp_algorithm` -eq 0 ]; then
        echo 'warning: unsupported compression algorithm used, falling back to lzo'
        COMP_ALGORITHM='lzo'
    fi;

    for n in `seq $CPUS`; do
      i=$((n - 1))
      echo $COMP_ALGORITHM > /sys/block/zram$i/comp_algorithm
      echo ${SIZE}K > /sys/block/zram$i/disksize
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
