---
layout: post
title: "android模拟器及调试相关"
description: ""
category: 技术
tags: [Android, adb, hosts]
excerpt: ""

---
{% include JB/setup %}

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
