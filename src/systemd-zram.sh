#!/bin/sh

# Antonio Galea <antonio.galea@gmail.com>
# Thanks to Przemysław Tomczyk for suggesting swapoff parallelization
# Systemd service and packaging by Manuel Domínguez López <mdomlop@gmail.com>
# Distributed under the GPL version 3 or above, see terms at
#      https://gnu.org/licenses/gpl-3.0.txt

EXECUTABLE_NAME='systemd-zram'
PROGRAM_NAME='Systemd zRAM'
DESCRIPTION='Use compressed RAM as in-memory swap'
VERSION='0.2b'
AUTHOR='Manuel Domínguez López'  # See AUTHORS file
MAIL='mdomlop@gmail.com'
LICENSE='GPLv3+'  # Read LICENSE file.

# You can change the compression algorithm and the fraction number editing the
# systemd service.
DEF_FRACTION=75
DEF_COMP_ALGORITHM='lzo'


test -z $FRACTION && FRACTION=$DEF_FRACTION
test -z $COMP_ALGORITHM && COMP_ALGORITHM=$DEF_COMP_ALGORITHM

MEMORY=`grep ^MemTotal: /proc/meminfo | awk '{print $2}'`
CPUS=`nproc`
SIZE=$(( MEMORY * FRACTION / 100 / CPUS ))

fallback() {
    echo -n 'Warning: Unsupported compression algorithm selected: '
    echo -n $COMP_ALGORITHM
    echo ', falling back to lzo.'
    COMP_ALGORITHM='lzo'
}

case "$1" in
  "start")
    modprobe zram num_devices=$CPUS

    # Check compression algorithm support
    grep -qw "$COMP_ALGORITHM" /sys/block/zram0/comp_algorithm || fallback

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
