#!/bin/bash
monitorport=5800
monitoraddress=localhost
ifname=mc1
qemu-system-x86_64 -enable-kvm \
	-name 'Win10' \
	-cpu host,-hypervisor,-kvm \
	-smp sockets=1,cores=4,threads=2 \
	-m 8192 \
	-drive if=ide,media=cdrom,id=cdrom0 \
	-drive if=ide,media=cdrom,id=cdrom1 \
	-pidfile pid \
	-device virtio-vga \
	-netdev user,id=net0 \
	-device virtio-net,netdev=net0,mac=00:00:00:00:00:02 \
	-machine usb=on \
	-device usb-tablet \
	-display sdl,gl=on \
	-monitor tcp:localhost:5800,server=on \
	-monitor unix:unix,server=on,wait=off \
	-rtc base=localtime \
	-nodefaults
