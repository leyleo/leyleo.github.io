---
layout: post
title: "关于ImageMagick"
description: "ImageMagick的安装和简单使用。"
category: 技术
tags: [OS X, ImageMagick, 图像处理]
excerpt: "关于Imagemagick
ubuntu里自带有该程序，通过 [convert -version] 查看版本，安装目录为 [/usr/bin/X11] ."

---
{% include JB/setup %}

关于Imagemagick
ubuntu里自带有该程序，通过`convert -version`查看版本，安装目录为`/usr/bin/X11`.

### Mac OS安装

#### 1.下载source code

第1步. 下载 [ImageMagick 源代码](http://www.imagemagick.com.cn/download.html)

第2步. `tar -xzvf ImageMagick.tar.gz`

#### 2. 配置并编译

第3步. `cd ImageMagick-6.x.x LDFLAGS="-L/usr/lib" CPPFLAGS="-I/usr/include" --enable-shared`

第4步. `./configure`

第5步. `make`

#### 3. 安装

第6步. `sudo make install`   注：需要root权限

#### 4. 测试

第7步. `display filename`  注：打开名为filename的图片

### 相关命令：

	$ convert icon.jpg icon.png //转换文件格式
	$ display icon.png //打开icon.png
	$ convert icon.png -resize 57x57\! icon_57.png
	$ convert -list format //查看支持的文件类型

### 问题

#### 问题描述

解决**convert: no decode delegate for this image format**的问题：在使用 `convert -quality 50% vipbanner.jpg newbanner.jpg` 时提示失败，原因是**没有找到可用的delegate**。

#### 解决方案

第1步. 去下载 [jpeg delegate](http://www.imagemagick.org/download/delegates/)
 里找到对应的格式文件，下载下来，解压，进入对应文件夹，执行：

	./configure -prefix=/usr/local
	make
	make install

第2步. 重装 [ImageMagick](http://www.imagemagick.org/download/) 下载最新的版本，解压，进入对应文件夹，执行：

	./configure
	make
	sudo make install 

然后测试一下，可以使用了。

### ImageMagick可以做什么

Here are just a few examples of what ImageMagick can do (摘自[ImageMagick官网文档](http://www.imagemagick.org/script/index.php)):

Format conversion: convert an image from one format to another (e.g. PNG to JPEG).

Transform: resize, rotate, crop, flip or trim an image.

Transparency: render portions of an image invisible.

Draw: add shapes or text to an image.

Decorate: add a border or frame to an image.

Special effects: blur, sharpen, threshold, or tint an image.

Animation: create a GIF animation sequence from a group of images.

Text & comments: insert descriptive or artistic text in an image.

Image identification: describe the format and attributes of an image.

Composite: overlap one image over another.

Montage: juxtapose image thumbnails on an image canvas.

Generalized pixel distortion: correct for, or induce image distortions including perspective.

Morphology of shapes: extract features, describe shapes and recognize patterns in images.

Motion picture support: read and write the common image formats used in digital film work.

Image calculator: apply a mathematical expression to an image or image channels.

Discrete Fourier transform: implements the forward and inverse DFT.

High dynamic-range images: accurately represent the wide range of intensity levels found in real scenes ranging from the brightest direct sunlight to the deepest darkest shadows.

Encipher or decipher an image: convert ordinary images into unintelligible gibberish and back again.

Virtual pixel support: convenient access to pixels outside the image region.

Large image support: read, process, or write mega-, giga-, or tera-pixel image sizes.

Threads of execution support: ImageMagick is thread safe and most internal algorithms execute in parallel to take advantage of speed-ups offered by multicore processor chips.

Heterogeneous distributed processing: certain algorithms are OpenCL-enabled to take advantage of speed-ups offered by executing in concert across heterogeneous platforms consisting of CPUs, GPUs, and other processors.

ImageMagick on the iPhone: convert, edit, or compose images on your iOS comuting device such as the iPhone or iPad.