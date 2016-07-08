---
layout: post
title: "android模拟器及调试相关"
description: ""
category: 技术
tags: [Android, adb, hosts]
excerpt: ""

---
{% include JB/setup %}

> 将文件拖拽到模拟器后，不重启模拟器刷新的方法：

```sh
adb shell am broadcast -a android.intent.action.MEDIA_MOUNTED -d file:///sdcard/
```

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

> 使用`Bitmap`出现`outofmemoryerror`的问题：

* [Android OutOfMemory 的思考](http://blog.csdn.net/luckyjda/article/details/8768516)
* [how to correct this error: java.lang.OutOfMemoryError](http://stackoverflow.com/questions/18321554/how-to-correct-this-error-java-lang-outofmemoryerror)

> 获取文件的二进制数据的方式之一

```java
/**
 * 获得文件数据
 * @param path String类型：文件的路径
 * @return byte[]：返回文件的二进制数据，文件不存在则返回null
 */
public static byte[] getDataFromFile(String path) {
	File file = new File(path);
	if (file.exists()) {
		try {
			FileInputStream inputStream = new FileInputStream(file);
			byte[] data = new byte[(int)file.length()];
			inputStream.read(data);
			inputStream.close();
			return data;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	return null;
}
```

> 修改hosts

修改路径为：`/system/etc/hosts`

模拟器中的修改方法：

```sh
adb root
adb remount
adb shell
echo -e \\n >> /system/etc/hosts
echo ***.***.***.***  www.whatever.com >> /system/etc/hosts
```
