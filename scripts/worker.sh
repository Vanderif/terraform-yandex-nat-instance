#!/usr/bin/env bash
sudo yum update
sudo yum install mdadm -y
sudo mkdir /data
sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=5 /dev/vdb /dev/vdc /dev/vdd /dev/vde /dev/vdf
sudo mkfs.xfs /dev/md0
sudo sh -c 'echo "/dev/md0  /data  xfs  defaults  0 0" >> /etc/fstab'
sudo mount -a