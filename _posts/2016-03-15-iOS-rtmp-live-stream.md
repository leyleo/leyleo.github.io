---
layout: post
title: "iOS RTMP上推直播视频"
description: "iOS RTMP上推直播视频"
category: 技术
tags: [iOS, RTMP, FFmpeg, VideoCore]
excerpt: "最近收集了一些关于视频直播的资料，目前主流的技术是上推使用RTMP协议，服务端基于nginx的nginx-rtmp-module模块来增加对HLS的支持，下行播放支持RTMP协议和HLS协议。"

---
{% include JB/setup %}

最近收集了一些关于视频直播的资料，目前主流的技术是上推使用RTMP协议，服务端基于**nginx**的`nginx-rtmp-module`模块来增加对HLS的支持，下行播放支持RTMP协议和HLS协议。

* RTMP协议

[Real Time Messaging Protocol](http://www.adobe.com/cn/devnet/rtmp.html) 是Adobe公司为Flash播放器和服务器之间音、视频及数据传输开发的实时消息传送协议。协议中，视频必须是H264编码，音频必须是AAC或MP3编码，且多以flv格式封包。

* HLS协议

[Http Live Streaming](https://developer.apple.com/streaming/) 是由Apple公司定义的基于HTTP的流媒体实时传输协议。它的原理是将整个流分为一个一个小的文件来下载，每次只下载若干个。传输内容包括两部分：一是M3U8描述文件，二是TS媒体文件。TS媒体文件中的视频必须是H264编码,音频必须是AAC或MP3编码。

在客户端上要完成直播视频的采集及RTMP上推，主要需要以下几个步骤：

1. 音视频的采集；
2. 对视频进行H264编码，对音频进行AAC编码；
3. 对编码后的音、视频数据进行FLV封包；
4. 建立RTMP连接并上推到服务端。

在音视频的采集上，直接使用`AVFoundation.framework`的`AVCaptureSession`即可获得原始的`CMSampleBufferRef`格式音视频数据。

而在将原始视频编码过程中，有两种方案：一种是利用第三方库[FFmpeg](http://ffmpeg.org) 进行编码，一种是利用iOS自身的[`AVAssetWriter`](https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVAssetWriter_Class/index.html) 或[VideoToolBox.framework](https://www.objc.io/issues/23-video/videotoolbox/)的`VTCompressionSession`进行编码。`FFmpeg`因其跨平台及功能丰富等诸多优势，被广泛使用。而使用`AVAssetWriter`编码需要将视频写入本地文件，然后通过实时监听文件内容的改变，读取文件并处理封包。从iOS8开始，`VideoToolBox`提供了硬件编码支持，可以使用`VTCompressionSession`进行编码。

### 相关项目及文档

> 使用FFmpeg编码：

* [FFmpeg相关资料 专栏文章](http://blog.csdn.net/leixiaohua1020/article/details/42658139)
* [iOS推流器 文章](http://blog.csdn.net/leixiaohua1020/article/details/47072519)
* [简单的基于FFmpeg的移动端 项目](https://github.com/leixiaohua1020/simplest_FFmpeg_mobile)
* [IOS手机直播Demo技术简介 文章](https://www.zybuluo.com/qvbicfhdx/note/126161)
* [利用FFmpeg+x264将iOS摄像头实时视频流编码为h264文件 文章](http://depthlove.github.io/2015/09/18/use-FFmpeg-and-x264-encode-iOS-camera-video-to-h264/)

> 使用iOS自身编码：

* [iOS RTMP视频直播开发笔记 文章](http://itony.me/813.html)
* [IFVideoPicker 项目](https://github.com/ifactorylab/IFVideoPicker)
* [GDCL Video Encoding 项目](http://www.gdcl.co.uk/2013/02/20/iOS-Video-Encoding.html)
* [VideoCore 项目](https://github.com/leyleo/VideoCore)

### VideoCore

VideoCore是一个开源的iOS平台音视频RTMP推流项目。支持实时滤镜效果和水印功能。在视频编码方面，iOS8以下使用AVAssetWriter进行编码：先把数据写入本地临时文件appendPixelBuffer，再读取文件数据fread. iOS8及以上采用了VideoToolBox的硬编码：VTCompressionSessionCreate创建session，当pushBuffer数据来时，调用VTCompressionSessionEncodeFrame压缩数据。

推流的初始化过程如下，[查看大图](https://github.com/leyleo/VideoCore/raw/master/docs/img/VCSimpleSession初始化推流.jpg)：

![](https://github.com/leyleo/VideoCore/raw/master/docs/img/VCSimpleSession初始化推流.jpg)

预览界面的初始化过程如下，[查看大图](https://github.com/leyleo/VideoCore/raw/master/docs/img/VCSimpleSession初始化预览.jpg)：

![](https://github.com/leyleo/VideoCore/raw/master/docs/img/VCSimpleSession初始化预览.jpg)

水印和滤镜特效的初始化过程如下，[查看大图](https://github.com/leyleo/VideoCore/raw/master/docs/img/VCSimpleSession初始化特效.jpg)：

![](https://github.com/leyleo/VideoCore/raw/master/docs/img/VCSimpleSession初始化特效.jpg)

音视频的编码过程如下图所示，[查看大图](https://github.com/leyleo/VideoCore/raw/master/docs/img/音视频Buffer传递过程.jpg)：

![](https://github.com/leyleo/VideoCore/raw/master/docs/img/音视频Buffer传递过程.jpg)

相关类的类图如下，[查看大图](https://github.com/leyleo/VideoCore/raw/master/docs/img/VideoCore类图2.jpg)：

![](https://github.com/leyleo/VideoCore/raw/master/docs/img/VideoCore类图2.jpg)
