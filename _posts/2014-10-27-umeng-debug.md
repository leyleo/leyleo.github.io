---
layout: post
title: "UMeng iOS错误分析"
description: "根据友盟的错误日志进行Debug."
category: 技术
tags: [iOS, Debug]
excerpt: "为了方便，程序中使用了友盟的统计分析，其中的错误分析很有用。在错误分析中看到了Application received signal SIGSEGV字样，顿时凌乱了~~ 不知道是不是我还在使用旧版错误分析的原因，翻了文档也没找到下载csv文件的地方。怎么搞？"

---
{% include JB/setup %}

为了方便，程序中使用了友盟的统计分析，其中的错误分析很有用。
在错误分析中看到了Application received signal SIGSEGV字样，顿时凌乱了~~ 不知道是不是我还在使用旧版错误分析的原因，翻了文档也没找到下载csv文件的地方。怎么搞？

```
Application received signal SIGSEGV
(null)
(
	0   CoreFoundation                      0x2ae57c37  + 150
	1   libobjc.A.dylib                     0x38602c8b objc_exception_throw + 38
	2   CoreFoundation                      0x2ae57b65  + 0
	3   MyAppBinary                         0xa3e51 MyAppBinary + 654929
	4   libsystem_platform.dylib            0x38cc2873 _sigtramp + 34
	5   MyAppBinary                         0x891e9 MyAppBinary + 545257
	6   MyAppBinary                         0x891e9 MyAppBinary + 545257
	7   MyAppBinary                         0x88ff5 MyAppBinary + 544757
	8   MyAppBinary                         0x97a35 MyAppBinary + 604725
	9   MyAppBinary                         0x98641 MyAppBinary + 607809
	10  MyAppBinary                         0x8dc1d MyAppBinary + 564253
	11  MyAppBinary                         0x7e9f7 MyAppBinary + 502263
	12  libdispatch.dylib                   0x38b627bb  + 10
	13  libdispatch.dylib                   0x38b627a7  + 22
	14  libdispatch.dylib                   0x38b65fa3 _dispatch_main_queue_callback_4CF + 718
	15  CoreFoundation                      0x2ae1d9d1  + 8
	16  CoreFoundation                      0x2ae1c0d1  + 1512
	17  CoreFoundation                      0x2ad6a211 CFRunLoopRunSpecific + 476
	18  CoreFoundation                      0x2ad6a023 CFRunLoopRunInMode + 106
	19  GraphicsServices                    0x321630a9 GSEventRunModal + 136
	20  UIKit                               0x2e3761d1 UIApplicationMain + 1440
	21  MyAppBinary                         0xa1b73 MyAppBinary + 646003
	22  libdyld.dylib                       0x38b82aaf  + 2
)

dSYM UUID: CEE0BC6E-9EB6-3BB7-A5DD-2AAD1A96E396
CPU Type: armv7
Slide Address: 0x00004000
Binary Image: MyAppBinary
Base Address: 0x0007c00
```

Step1. 找到提交App时使用的DYSM文件。

从`XCode->Window->Organizer`找到出现错误的那个版本，从它的`.xcarchive->dSYMs`找到`MyAppBinary.app.dSYM`，继续进入，`Contents->Resources->DWARF`，最后找到**MyAppBinary**。这就是编译后的二进制文件。

Step2. 建议把**MyAppBinary**拷贝出来，在MyAppBinary对应的目录执行下面代码，要注意对应**Binary Image**和**CPU Type**.

```
atos -arch armv7 -o SAEMobile 0x891e9
```

Step3. 这时候，就可以看到具体是哪里出问题啦~

----

参考文章：

[http://blog.csdn.net/smking/article/details/9342899
symbolicating-ios-crash-logs](http://blog.csdn.net/smking/article/details/9342899
symbolicating-ios-crash-logs)
