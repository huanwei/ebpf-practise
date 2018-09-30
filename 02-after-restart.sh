#!/bin/bash

# 安装内核开发环境
yum --enablerepo=elrepo-kernel install -y kernel-ml-devel

#先卸载原版内核 headers ，然后再安装最新版内核 headers
yum remove -y kernel-headers

#带有依赖关系的包也会被卸载，gcc，golang等都需要重新安装
yum --enablerepo=elrepo-kernel -y install kernel-ml-headers
yum install -y gcc
yum install -y gcc-c++
yum install -y golang

#编译安装clang、llvm

#同样的，编译代码用到的clang在yum上版本过低，需要自行编译安装
#下载必要源码
cd /home
wget http://releases.llvm.org/6.0.1/llvm-6.0.1.src.tar.xz
wget http://releases.llvm.org/6.0.1/cfe-6.0.1.src.tar.xz
wget http://releases.llvm.org/6.0.1/compiler-rt-6.0.1.src.tar.xz
wget http://releases.llvm.org/6.0.1/clang-tools-extra-6.0.1.src.tar.xz

#解压缩
tar xf llvm-6.0.1.src.tar.xz
tar xf cfe-6.0.1.src.tar.xz
tar xf compiler-rt-6.0.1.src.tar.xz
tar xf clang-tools-extra-6.0.1.src.tar.xz

#移动到规定的目录
mv llvm-6.0.1.src llvm
mv cfe-6.0.1.src llvm/tools/clang
mv clang-tools-extra-6.0.1.src llvm/tools/clang/tools/extra
mv compiler-rt-6.0.1.src llvm/projects/compiler-rt

#删除压缩包
#rm -f llvm-6.0.1.src.tar.xz
#rm -f cfe-6.0.1.src.tar.xz
#rm -f clang-tools-extra-6.0.1.src.tar.xz
#rm -f compiler-rt-6.0.1.src.tar.xz

#下载cmake用于编译llvm
wget https://cmake.org/files/v3.12/cmake-3.12.2.tar.gz
tar xzf cmake-3.12.2.tar.gz
cd ./cmake-3.12.2
./bootstrap
gmake
make install
cd ..
#rm -f cmake-3.12.2.tar.gz
mkdir llvm-build
cd llvm-build
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/home/clang -DLLVM_OPTIMIZED_TABLEGEN=1 ../llvm
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
cd /home
git clone https://github.com/iovisor/bcc.git
mkdir bcc/build; cd bcc/build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
make
sudo make install