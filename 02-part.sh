#!/bin/bash

#part from 02-after-restart.sh
#下载cmake用于编译llvm
cd /home/llvm-build
make
make install

#覆盖旧版本llvm
cp -f /home/clang/bin/* /bin

#安装elf支持
yum install -y elfutils-libelf-devel-static

#安装bison、flex，编译安装新版本iproute2
#bison和flex可通过yum安装
yum install -y bison flex

#iproute详见官网，或：
yum update -y --enablerepo=elrepo-kernel iproute

#安装bcc
git clone https://github.com/iovisor/bcc.git
mkdir bcc/build; cd bcc/build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
make
sudo make install