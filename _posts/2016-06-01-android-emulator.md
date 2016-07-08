---
layout: post
title: "Android模拟器及调试相关"
description: "Android模拟器及调试相关"
category: 技术
tags: [Android, adb, hosts]
excerpt: ""

---
{% include JB/setup %}

#### 1. 将文件拖拽到模拟器后，不重启模拟器的刷新方法

```sh
adb shell am broadcast -a android.intent.action.MEDIA_MOUNTED -d file:///sdcard/
```

> 注： 推荐一款安卓模拟器—— [Genymotion](https://www.genymotion.com)，比原生的好用很多倍。上述方法在Genymotion上实测可行。

如果有多个设备，可以使用`adb devices`获取设备列表

```sh
> adb devices

List of devices attached
192.168.56.103:5555	device
192.168.56.101:5555	device
192.168.56.102:5555	device
```

然后使用`adb -s deviceId`来指定某一个设备

```sh
adb -s 192.168.56.103:5555 shell am broadcast -a android.intent.action.MEDIA_MOUNTED -d file:///sdcard/
```

#### 2. 修改设备hosts

设备中 **hosts** 的修改路径为：`/system/etc/hosts`

模拟器中的修改方法为：

```sh
adb root #获取root权限
adb remount #以root权限重新挂载
adb shell

# 如果有多条信息的话，重复下面两条操作
echo -e \\n >> /system/etc/hosts
echo ***.***.***.***  www.whatever.com >> /system/etc/hosts
```
