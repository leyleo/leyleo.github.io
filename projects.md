---
layout: page
title: "项目"
tagline: 想说的太多
header: My Projects
---
{% include JB/setup %}

## TeamDisk

#### 是什么？
    TeamDisk是一个基于WebDAV协议的网盘项目解决方案，是对私有云盘技术的一次尝试。方案包含了从搭建网盘服务器端，到用户权限的后台管理，到移动客户端及PC端工具等一系列子项目。

由[@chenfan](https://github.com/chenfan)和[@leyleo](https://github.com/leyleo)开发。该方案使用MIT协议。

#### 包含项目
* __服务端WebDAV程序__

    程序是基于[SabreDAV](https://code.google.com/p/sabredav/)来开发，通过PHP来模拟webdav服务器。并在SabreDAV的基础上添加了权限管理模块，通过后台管理模块，管理员可以添加资源组，同时为这些组分配资源目录的使用权限。做到了不同权限组都只能访问到自身权限下的资源。

* __后台管理及资源服务操作API__

    这部分的程序是管理员后台操作模块，管理可通过后台为用户创建账号，添加组以及为他们分配权限等等用户管理操作。

    管理员所有的变更都是通过API来完成，目前开发了管理员使用的用户管理、文件夹API。有新的业务场景可以在此基础上进行扩展，也可供第三方开发使用API。

* __HTML5版本客户端程序__

    该版本客户端使用HTML5开发，并使用[TideSDK](http://www.tidesdk.org/)打包，实现了跨浏览器，Win，MAC等平台的统一开发。功能上，实现对WebDAV服务端文件的基本操作，包括拷贝，下载，删除等。

**以上三部分源码在项目：[teamdisk](https://github.com/chenfan/teamdisk)**

* __iPhone客户端__

    能访问WebDAV服务器端文件的iPhone客户端，实现对服务端文件的访问，重命名，移动，删除等操作，并能上传本地相册内容。支持第三方应用打开文件，文档/图片预览，音视频播放，及内置音乐播放器等功能。

**该部分源码在项目：[TeamDisk_iOS](https://github.com/leyleo/TeamDisk_iOS)**

* __挂载网盘的工具__

  OSX平台挂载TeamDisk网盘的工具。

**该部分源码在项目：[TeamDisk_MountDisk_OSX](https://github.com/leyleo/TeamDisk_MountDisk_OSX)**

----
欢迎吐槽
