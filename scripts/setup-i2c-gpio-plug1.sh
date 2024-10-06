#!/bin/bash

CFG=/etc/psw/psw.conf

if [ ! -r "$CFG" ]; then
        echo "Missing config file $CFG. Aborting."
        exit 1
fi

modprobe gpio-pca953x

echo 0x20 > /sys/class/i2c-adapter/i2c-0/delete_device 2>/dev/null
echo pca9554 0x20 > /sys/class/i2c-adapter/i2c-0/new_device

echo 0x21 > /sys/class/i2c-adapter/i2c-0/delete_device 2>/dev/null
echo pca9554 0x21 > /sys/class/i2c-adapter/i2c-0/new_device

# initialize all GPIOs present in the config file. Those starting with a - are
# inverted.

while read port gpio desc; do
	[ -n "${port##\#*}" ] || continue
        num="${gpio#-}"
	echo $num > /sys/class/gpio/export
	echo out > /sys/class/gpio/gpio$num/direction
	# cut the power
	if [ "$gpio" = "$num" ]; then
		echo 0 > /sys/class/gpio/gpio$num/value
        else
		echo 1 > /sys/class/gpio/gpio$num/value
        fi
done < "$CFG"
