---
layout: post
title: "web前端页面性能分析"
description: "使用PhantomJS和YSlow进行web前端页面性能分析"
category: 技术
tags: [shell, web]
excerpt: "网上有很多工具和服务可以用来做web前端页面性能分析，这里我们介绍一组比较流行的开源项目："

---
{% include JB/setup %}

网上有很多工具和服务可以用来做web前端页面性能分析，这里我们介绍一组比较流行的开源项目：

* [PhantomJS](http://phantomjs.org)
* [YSlow](http://yslow.org)
* HTTP tracking工具：[HAR Adopters](http://www.softwareishard.com/blog/har-adopters/)

通过它们可以实现很多功能：截屏，网络监控，自动化测试，页面性能分析等。

#### 网络请求分析

##### 1. 生成har文件（json格式）：

```sh
phantomjs netsniff.js http://www.sina.com.cn
```

##### 2. 在netsniff.js里添加对ua的设定：

```js
page.settings.userAgent = system.args[2];
```

这样就可以抓取不同UA的内容，生成对应的har文件。

##### 3. 渲染har文件：

使用[harviewer](https://github.com/janodvarko/harviewer)可视化工具查看网络请求过程、页面结构等。如下图所示：

![](http://www.softwareishard.com/har/images/scr-har-viewer.png)
![](http://www.softwareishard.com/har/images/scr-har-viewer-stats.png)  ![](http://www.softwareishard.com/har/images/scr-har-viewer-dom.png)

[点击访问在线工具](http://www.softwareishard.com/har/viewer/)

#### YSlow分析

用yslow来分析har文件：

```sh
yslow -i all -f plain baidu.har
```

用phantomjs的yslow，取特定UA进行分析：

```sh
phantomjs yslow.js -i all -f json -u "Mozilla/5.0 (iPhone; CPU iPhone OS 8_1_2 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12B440 Safari/600.1.4" "http://sae.sina.com.cn/?m=front&a=mobile" > saemobile.json
```

#### 图像处理

* 使用phantomjs生成png截图文件：

```sh
phantomjs rasterize http://www.baidu.com
```

也可以在里面设定UA和page.viewport的大小，来抓取对应UA和尺寸的效果图。

* 使用`ImageMagick`压缩图片：

[ImageMagick](http://www.imagemagick.com.cn/index.html) 是一个免费的创建、编辑、合成图片的软件，它可以读取、转换、写入多种格式的图片。关于更详细的介绍，可以参考我的这篇文章：[关于ImageMagick](http://leyleo.github.io/技术/2015/03/28/ImageMagick)。

```sh
convert -quality 50% filename newfilename
```

* 使用`OptiPNG`压缩PNG：

[OptiPNG](http://optipng.sourceforge.net) 是一个针对PNG格式图片进行压缩的开源项目。

#### js/css压缩及混淆项目

* [UglifyJS2](https://github.com/mishoo/UglifyJS2)
* [yuicompressor](http://yui.github.io/yuicompressor/)
* [jsmin](http://crockford.com/javascript/jsmin)

-----

附：YSlow基于[23条规则(来自Yahoo)](https://developer.yahoo.com/performance/rules.html) 的分析：

1. 减少http请求
2. 使用CDN
3. 避免空的src/href
4. 设置缓存控制
5. GZip压缩
6. 将CSS放到文件头
7. 将脚本放到文件末尾
8. 避免css表达式
9. 使用外部js/css
10. 减少DNS查找
11. 压缩js/css
12. 避免重定向
13. 删除重复js/css
14. 配置ETags
15. 设置ajax缓存
16. 使用ajax get
17. 减少dom数量
18. 避免出现404
19. 减少cookie的大小
20. 使用cookie-free的子域名
21. Avoid Filters
22. Do Not Scale Images in HTML
23. Make favicon.ico Small and Cacheable
