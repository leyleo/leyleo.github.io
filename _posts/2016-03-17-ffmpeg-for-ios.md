---
layout: post
title: "iOS FFmpeg编译"
description: "iOS FFmpeg编译"
category: 技术
tags: [iOS, RTMP, FFmpeg, X264, AAC]
excerpt: "前一篇文章\"iOS RTMP上推直播视频\"提到用FFmpeg库来实现直播流的转码和RTMP上推，这篇主要记录了FFmpeg，及相关x264、fdk-aac、librtmp的编译方法。"

---
{% include JB/setup %}

之前的文章[iOS RTMP上推直播视频](/技术/2016/03/15/iOS-rtmp-live-stream)提到用**FFmpeg**库来实现直播流的转码和**RTMP**上推，这篇主要记录了**FFmpeg**，及相关`x264`、`fdk-aac`、`librtmp`的编译方法。时间及水平有限，直接上步骤，不做解释了。

### 编译FFmpeg

#### 1. 下载需要的文件

下载`gas-preprocessor.pl`文件，下载地址：[https://github.com/yuvi/gas-preprocessor](https://github.com/yuvi/gas-preprocessor)

下载FFmpeg编译脚本`build-ffmpeg.sh`，下载地址：[https://github.com/kewlbear/FFmpeg-iOS-build-script](https://github.com/kewlbear/FFmpeg-iOS-build-script)

下载FFmpeg源码，下载地址：[http://www.ffmpeg.org](http://www.ffmpeg.org)

#### 2. 准备编译脚本

将`gas-preprocessor.pl`文件，并拷贝到`/usr/local/bin`目录下。

将**FFmpeg源码**文件夹放置到与`build-ffmpeg.sh`同级的目录，并确保`build-ffmpeg.sh`中的`SOURCE`与**FFmpeg源码**路径一致。

```sh
# build-ffmpeg.sh
SOURCE="ffmpeg" # SOURCE 为下载的FFmpeg源码的目录
FAT="FFmpeg-iOS" # FAT 为编译生成的库文件的目录
```

##### 备注1：x264

如果需要将`x264`编译进FFmpeg，需要取消对下面这句话的注释。

```sh
# build-ffmpeg.sh
X264=`pwd`/fat-x264 # 设置X264库所在的路径
```
> 参考来源：[http://www.cocoachina.com/bbs/3g/read.php?tid=202570](http://www.cocoachina.com/bbs/3g/read.php?tid=202570)

##### 备注2：fdk-aac

如果需要将`fdk-aac`编译进FFmpeg，需要取消对下面这句话的注释。

```sh
# build-ffmpeg.sh
FDK_AAC=`pwd`/fdk-aac/fdk-aac-ios
```

另外，需要修改下面部分，添加`--enable-nonfree`字段。

```sh
# build-ffmpeg.sh
if [ "$FDK_AAC" ]
then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-nonfree --enable-libfdk-aac"
fi
```
如果编译时出现异常，可以尝试将编译脚本中的`-fembed-bitcode` 状态去掉。

> 参考来源：[https://github.com/kewlbear/FFmpeg-iOS-build-script/issues/52](https://github.com/kewlbear/FFmpeg-iOS-build-script/issues/52)

##### 备注3：rtmp

如果要将`rtmp`编译到FFmpeg，需要添加以下代码：

```sh
# build-ffmpeg.sh
RTMP=`pwd`/librtmp

# 下面代码跟在 CONFIGURE_FLAGS 配置阶段 if [ "$FDK_AAC" ] 代码段后面
if [ "$RTMP" ]
then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-protocol=librtmp --enable-librtmp"
fi

# 下面代码跟在 CFLAGS 和 LDFLAGS 配置阶段 if [ "$FDK_AAC" ] 代码段后面
if [ "$RTMP" ]
then
  CFLAGS="$CFLAGS -I$RTMP/include"
  LDFLAGS="$LDFLAGS -L$RTMP/lib"
fi
```

编译时如果出现下面提示：

```
ERROR: librtmp not found using pkg-config
```
需要进入**FFmpeg/configure**文件，将

```sh
# configure
enabled librtmp && require_pkg_config librtmp librtmp/rtmp.h RTMP_Socket
```

改成

```sh
# configure
enabled librtmp
```

> 参考来源：[http://www.cnblogs.com/fpzeng/p/3202344.html](http://www.cnblogs.com/fpzeng/p/3202344.html)

#### 3. 编译

##### 编译x264

首先，下载`x264`源文件：[http://git.videolan.org/git/x264.git](http://www.videolan.org/developers/x264.html)，及`x264 iOS`版编译脚本：[https://github.com/kewlbear/x264-ios](https://github.com/kewlbear/x264-ios)

然后执行编译脚本：

```sh
./build-x264.sh
```

将编译后的库文件`x264-iOS`目录拷贝到上面`FFmpeg-iOS-build-script`编译脚本的根目录，改名为`fat-x264`（即放置在备注1提到的脚本中x264的库文件所在位置）。

##### 编译fdk-aac

首先，下载`fdk-aac`源文件：[fdk-aac-ios](https://github.com/verybigdog/fdk-aac-ios)，该版本能支持arm64的编译。

然后，依次运行下面脚本：

```sh
./autogen.sh

./build_ios_xcode6.sh
```

注意：需要先安装**automake**和**libtool**

```sh
brew install automake

brew install libtool
```

将编译后的`libfdk-aac`目录拷贝到上面`FFmpeg-iOS-build-script`编译脚本的根目录下的`fdk-aac`目录下，并改名字为`fdk-aac-ios`（即放置在备注2提到的脚本中fdk-aac的库文件所在位置）。

##### 编译librtmp

**首先，需要编译`openssl`。** 从[openssl官网](http://www.openssl.org)下载最新稳定版本，解压为`openssl-1.0.2g`。

分别编译各个版本的库文件，以**armv7**为例：

```sh
cd openssl-1.0.2g

mkdir /tmp/openssl-1.0.2g-armv7

./configure BSD-generic32 --openssldir=/tmp/openssl-1.0.2g-armv7

vi Makefile
```

编辑`Makefile`下面内容。

* 将`CROSS_COMPILE`修改为：

```sh
# Makefile
CROSS_COMPILE= /usr/bin/
```

* 在`CC`配置的末尾添加对应版本信息：

```sh
# Makefile
CC= $(CROSS_COMPILE)gcc -arch armv7
```

* 在`CFLAG`配置的末尾添加`-isysroot`，使其指向系统的`iPhoneOS.sdk`，即得如下：

```sh
# Makefile
CFLAG= -DOPENSSL_THREADS -pthread -D_THREAD_SAFE -D_REENTRANT -DDSO_DLFCN -DHAVE_DLFCN_H -O3 -fomit-frame-pointer -Wall -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
```

然后进行**Make**:

```sh
make clean

make && make install
```

依次类推，`armv7`、`armv7s`、`arm64`等**真机设备**如上配置。如果是**模拟器**，则需要在上面配置`CFLAG`那一步，将`isysroot`的内容指向`iPhoneSimulator.sdk`，并设置最低版本`-miphoneos-version-min=7.0`，即得整体如下配置：

```sh
# Makefile
CFLAG= -DOPENSSL_THREADS -pthread -D_THREAD_SAFE -D_REENTRANT -DDSO_DLFCN -DHAVE_DLFCN_H -O3 -fomit-frame-pointer -Wall -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk -miphoneos-version-min=7.0
```

最后生成`openssl`的库文件：

```sh
cd openssl

mkdir include lib

cp -r /tmp/openssl-1.0.2g-armv7/include/openssl/* include/

lipo /tmp/openssl-1.0.2g-arm64/lib/libcrypto.a /tmp/openssl-1.0.2g-armv7/lib/libcrypto.a /tmp/openssl-1.0.2g-armv7s/lib/libcrypto.a /tmp/openssl-1.0.2g-i386/lib/libcrypto.a /tmp/openssl-1.0.2g-x86_64/lib/libcrypto.a -create -output lib/libcrypto.a

lipo /tmp/openssl-1.0.2g-arm64/lib/libssl.a /tmp/openssl-1.0.2g-armv7/lib/libssl.a /tmp/openssl-1.0.2g-armv7s/lib/libssl.a /tmp/openssl-1.0.2g-i386/lib/libssl.a /tmp/openssl-1.0.2g-x86_64/lib/libssl.a -create -output lib/libssl.a
```

**然后编译`librtmp`。** 直接从`git`获取源代码。

```sh
git clone git://git.ffmpeg.org/rtmpdump
```

与上面`openssl`编译类似，分别对各个版本进行编译，最后合成一个Fat库文件。下面以`armv7`版本为例：

```sh
cp -r rtmpdump rtmpdump-armv7

cd rtmpdump-armv7

vi Makefile
```

在`CC`配置的末尾添加对应版本信息：

```sh
# Makefile
CC= $(CROSS_COMPILE)gcc -arch armv7
```

然后执行下面操作：

```sh
export CROSS_COMPILE=/usr/bin/

export XCFLAGS="-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk -I/tmp/openssl/include/ -arch armv7"

export XLDFLAGS="-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk -L/tmp/openssl/lib -arch armv7"

mkdir /tmp/librtmp-armv7

make SYS=darwin

make SYS=darwin prefix=/tmp/librtmp-armv7 install
```

依次类推，`armv7`、`armv7s`、`arm64`等**真机设备**如上配置。如果是**模拟器**，则需要在配置`XCFLAGS`和`XLDFLAGS`的地方，将`isysroot`的内容指向`iPhoneSimulator.sdk`，并设置最低版本`-miphoneos-version-min=7.0`，即如下操作：

```sh
export CROSS_COMPILE=/usr/bin/

export XCFLAGS="-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk -I/tmp/openssl/include/ -arch i386 -miphoneos-version-min=7.0"

export XLDFLAGS="-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk -L/tmp/openssl/lib -arch i386 -miphoneos-version-min=7.0"

mkdir /tmp/librtmp-i386

make SYS=darwin

make SYS=darwin prefix=/tmp/librtmp-i386 install
```

最后生成`librtmp`库文件。

```sh
cd librtmp

mkdir include lib

cp -r /tmp/librtmp-armv7/include/librtmp/* include/

lipo /tmp/librtmp-arm64/lib/librtmp.a /tmp/librtmp-armv7/lib/librtmp.a /tmp/librtmp-armv7s/lib/librtmp.a /tmp/librtmp-i386/lib/librtmp.a /tmp/librtmp-x86_64/lib/librtmp.a -create -output lib/librtmp.a
```

然后将`openssl`的库文件合到`librtmp`目录去，并拷贝到上面`FFmpeg-iOS-build-script`编译脚本的根目录下（即放置在备注3提到的脚本中librtmp的库文件所在位置）。

##### 编译FFmpeg

运行脚本：

```sh
./build-ffmpeg.sh
```

##### 问题1

如果出现`Out of tree builds are impossible with config.h in source dir.`这样的提示，删除`ffmpeg\config.h`即可。这是因为之前执行过`./configure`。

##### 问题2

如果提示`yasm not found`，可以通过`brew install yasm`进行安装。

### 添加到项目中

将各种编译完成的库添加到项目中去。

#### 注意1

工程中需要添加依赖库：

* libz
* libbz2
* libiconv

#### 注意2

工程中`target->build settings`中的**Header Search Paths**和**Library Search Paths**需要添加对应路径。

```
Header Search Paths:
$(PROJECT_DIR)/fat-x264/include
$(PROJECT_DIR)/fdk-aac-ios/include
$(PROJECT_DIR)/librtmp/include
$(PROJECT_DIR)/FFmpeg-iOS/include

Library Search Paths:
$(PROJECT_DIR)/fat-x264/lib
$(PROJECT_DIR)/fdk-aac-ios/lib
$(PROJECT_DIR)/librtmp/lib
$(PROJECT_DIR)/FFmpeg-iOS/lib
```

#### 注意3

工程中用到x264库的时候，不仅需要将**x264**编译到FFmpeg库中，还需要将上面编译得到的**fat-x264**目录添加到工程中去。

否则会出现类似下面的错误提示：

```
Undefined symbols for architecture arm64:  "_x264_encoder_close", referenced from:      _X264_close in libavcodec.a(libx264.o)
```
---

> 参考文章

[FFmpeg框架在iOS平台上的编译和使用](http://www.jianshu.com/p/147c03553e63)

[Building librtmp for iOS](https://media.fish/building-librtmp-for-ios-and-android/)

[iOS设备编译rtmp脚本](http://songjihe.com/2016/03/13/rtmpbian-yi-jiao-ben/)：未编译成功

[OpenSSL-for-iOS](https://github.com/x2on/OpenSSL-for-iPhone)：未编译成功
