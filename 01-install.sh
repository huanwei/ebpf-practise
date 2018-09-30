#!/bin/bash

#centos7的linux内核版本为3.10，而ebpf的支持是在3.15版本加入的，tc的class队列是4.5版本才加入的，需要手动升级内核。

#下载内核
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install kernel-ml -y

#查看本机现有的内核
sudo awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg

#选择刚下载的新版内核（0号）
sudo grub2-set-default 0

#配置并重启
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo reboot

#然后执行after-restart.sh