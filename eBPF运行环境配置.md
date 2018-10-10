##### centos7的linux内核版本为3.10，而ebpf的支持是在3.15版本加入的，tc的class队列是4.5版本才加入的，需要手动升级内核。

#### 下载内核
```
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install kernel-ml -y
```
查看本机现有的内核
```
sudo awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
```

选择刚下载的新版内核（0号）
```
sudo grub2-set-default 0
```

配置并重启
```
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo reboot
```
#### 安装内核开发环境
```
yum --enablerepo=elrepo-kernel install kernel-ml-devel -y
```

先卸载原版内核 headers ，然后再安装最新版内核 headers
```
yum remove kernel-headers
```
带有依赖关系的包也会被卸载，gcc，golang等都需要重新安装
```
yum --enablerepo=elrepo-kernel -y install kernel-ml-headers
yum install -y gcc 
yum install -y gcc-c++
yum install -y golang
```
#### 编译安装clang、llvm

同样的，编译代码用到的clang在yum上版本过低，需要自行编译安装
下载必要源码
```
cd /home
wget http://releases.llvm.org/6.0.1/llvm-6.0.1.src.tar.xz
wget http://releases.llvm.org/6.0.1/cfe-6.0.1.src.tar.xz
wget http://releases.llvm.org/6.0.1/compiler-rt-6.0.1.src.tar.xz
wget http://releases.llvm.org/6.0.1/clang-tools-extra-6.0.1.src.tar.xz
```
解压缩
```
tar xf llvm-6.0.1.src.tar.xz
tar xf cfe-6.0.1.src.tar.xz
tar xf compiler-rt-6.0.1.src.tar.xz
tar xf clang-tools-extra-6.0.1.src.tar.xz
```
移动到规定的目录
```
mv llvm-6.0.1.src llvm
mv cfe-6.0.1.src llvm/tools/clang
mv clang-tools-extra-6.0.1.src llvm/tools/clang/tools/extra
mv compiler-rt-6.0.1.src llvm/projects/compiler-rt
```
删除压缩包
```
# rm -f llvm-6.0.1.src.tar.xz
# rm -f cfe-6.0.1.src.tar.xz
# rm -f clang-tools-extra-6.0.1.src.tar.xz
# rm -f compiler-rt-6.0.1.src.tar.xz
```

下载cmake用于编译llvm
```
wget https://cmake.org/files/v3.12/cmake-3.12.2.tar.gz
tar xzf cmake-3.12.2.tar.gz
cd ./cmake-3.12.2
./bootstrap
gmake
make install
cd ..
# rm -f cmake-3.12.2.tar.gz
mkdir llvm-build
cd llvm-build
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/home/clang -DLLVM_OPTIMIZED_TABLEGEN=1 ../llvm
make
make install
```

覆盖旧版本llvm
```
cp -f /home/clang/bin/* /bin
```
#### 安装elf支持
```
yum install -y elfutils-libelf-devel-static
```
#### 安装bison、flex，编译安装新版本iproute2

bison和flex可通过yum安装

yum install -y bison flex

yum install -y git
git clone https://github.com/iovisor/bcc.git
mkdir bcc/build; cd bcc/build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
make
sudo make install

iproute详见官网，或：

yum update -y --enablerepo=elrepo-kernel iproute
