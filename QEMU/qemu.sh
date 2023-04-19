#!/bin/bash
monitorport=5800
monitoraddress=localhost
ifname=qemu0
qemu-system-x86_64 -enable-kvm \
	-name 'Win10' \
	-M q35 \
	-cpu host,+topoext \
	-smp sockets=1,cores=12,threads=2 \
	-m 8192 \
	-drive if=ide,media=cdrom,id=cdrom0 \
	-drive if=ide,media=cdrom,id=cdrom1 \
	-drive if=pflash,file=OVMF.fd,unit=0,format=raw,readonly=on \
	-drive if=pflash,file=VAR.fd,unit=1,format=raw \
	-pidfile pid \
	-device qemu-xhci \
	-device virtio-vga \
	-netdev tap,ifname=$ifname,script=ifup,id=net0 \
	-device virtio-net,netdev=net0,mac=10:00:00:00:00:00 \
	-device usb-tablet \
	-display sdl,gl=on \
	-monitor tcp:$monitoraddress:$monitorport,server=on \
	-monitor unix:unix,server=on,wait=off \
	-rtc base=localtime \
	-nodefaults
