---
layout: post
title: "为Mac添加开机启动脚本"
description: "为Mac添加开机启动脚本"
category: 技术
tags: [OS X, shell]
excerpt: "希望每次开机的时候，系统能够执行/path/to/script.sh脚本。"

---
{% include JB/setup %}

希望每次开机的时候，系统能够自动执行`/path/to/script.sh`脚本。于是稍微了解了一下Mac启动相关的内容。

### 方法一：使用**launchd**

The root process on OS X is **launchd**. In addition to initializing the system, the **launchd** process coordinates the launching of system daemons in an orderly manner. Like the inetd process, **launchd** launches daemons on-demand. ... When a service request comes in, if the daemon is not running, launchd automatically starts the daemon to process the request.

From [The Life Cycle of a Daemon](https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/Lifecycle.html)

#### **launchd**启动过程

当系统启动，kernel正常运行，**launchd** 就开始启动来完成系统的初始化工作。整个初始化工作包括以下几步：

1. 载入位于`/System/Library/LaunchDaemons/`和`/Library/LaunchDaemons/`目录中每一个要求适时启动(launch-on-demand)的系统级(system-level)守护进程(daemon)的**plist**文件参数；
2. 注册这些进程需要的sockets和描述文件(file descriptors)；
3. 启动那些需要一直运行的进程；
4. 当收到某一服务请求时，启动响应进程并将请求传递过去；
5. 当系统关机时，向所有**launchd**启动的进程发送`SIGTERM`信号。

当用户登录时，用户级**launchd**启动，过程类似上面：

1. 载入位于`/System/Library/LaunchAgents`，`/Library/LaunchAgents`及用户自己`Library/LaunchAgents`目录中每一个要求适时启动的用户代理(user agent)的**plist**文件参数；
2. 注册这些用户代理需要的sockets和描述文件(file descriptors)；
3. 启动那些需要一直运行的用户代理；
4. 当收到某一服务请求时，启动响应用户代理并将请求传递过去；
5. 当用户登出时，向所有该**launchd**启动的用户代理发送`SIGTERM`信号。

如下图所示，[点击查看大图](https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Art/bootstrap_session_2x.png)：

<!-- ![](https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Art/bootstrap_session_2x.png) -->
<img src="https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Art/bootstrap_session_2x.png" alt="bootstrap_session_2x.png" style="width: 500px;"/>

#### **plist**文件

那该怎么描述上面提到的**plist**文件呢？

Key | 描述信息
--- | ---
Label | launchd中每个进程的唯一标识。(required)
ProgramArguments | 包含可执行文件、运行参数等用来启动进程的参数。(required)
KeepAlive | 用来指定该进程是适时启动还是一直运行。
... | ...

详细请查看：[launchd.plist manual page](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man5/launchd.plist.5.html#//apple_ref/doc/man/5/launchd.plist)

以**Karabiner**的启动守护进程为例，如下图所示：

![org.pqrs.Karabiner.load.plist]({{BASE_PATH}}/assets/images/201603/org.pqrs.Karabiner.load.plist.png)

#### 实例操作

对于文章开头提到的脚本`/path/to/script.sh`，我们添加对应的**plist**文件到所需的目录即可。

Step1. 创建`com.my.test.plist`文件，并写入配置：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>             <string>com.my.test</string>
    <key>Disabled</key>
      <false/>
    <key>RunAtLoad</key>
      <true/>
    <key>KeepAlive</key>
      <false/>
    <key>ProgramArguments</key>
      <array>
        <string>/path/to/script.sh</string>
      </array>
</dict>
</plist>
```

Step2. 将上面文件以root权限放在`/Library/LaunchDaemons/`目录下。

> 参考文章：

* [Creating Launch Daemons and Agents](https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html)
* [launchd manual page](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man8/launchd.8.html)
* [Mac OSX的开机启动配置](http://www.tanhao.me/talk/1287.html/)

### 方法二：使用**loginwindow**

As the final part of system initialization, **launchd** launches **loginwindow**. The **loginwindow** program controls several aspects of user sessions and coordinates the display of the login window and the authentication of users.

From [The Life Cycle of a Daemon](https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/Lifecycle.html)

#### 实例操作

Step1. 打开终端工具，如**Terminal.app**或者**iTerm.app**等

Step2. 输入下面命令，按照提示输入密码即可：

```
sudo defaults write com.apple.loginwindow LoginHook /path/to/script.sh
```

#### 说明

* 如果希望查看当前登录启动脚本，执行：

```
sudo defaults read com.apple.loginwindow LoginHook
```

* 如果希望删除该项启动脚本，执行：

```
sudo defaults delete com.apple.loginwindow LoginHook
```

* 如果希望在登出系统时执行脚本，将**LoginHook**换成**LogoutHook**即可：

```
sudo defaults write com.apple.loginwindow LogoutHook /path/to/script.sh
```

* 该方法最多只能设置一个执行脚本，且已经不被Apple推荐。

> 参考文章：

* [Mac OS X: Creating a login hook](https://support.apple.com/en-us/HT2420)
* [Login and Logout Scripts](https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CustomLogin.html)
