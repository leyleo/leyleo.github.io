---
layout: post
title: "MobileProvision相关"
description: "如何使用命令行安装mobile provision文件"
category: 技术
tags: [OS X, Provision, shell]
excerpt: "如何安装.mobileprovision文件？主要步骤有两步：1. 从mobileprovision文件中提取出UUID; 2. 将命名为对应UUID.mobileprovision的文件拷贝到以下目录。"

---
{% include JB/setup %}

##MobileProvision相关
###如何安装.mobileprovision文件
文章来源：[stackoverflow](http://stackoverflow.com/questions/10398456/can-an-xcode-mobileprovision-file-be-installed-from-the-command-line)

主要步骤有两步：

1. 从mobileprovision文件中提取出UUID;
2. 将命名为对应UUID.mobileprovision的文件拷贝到 `~/Library/MobileDevice/Provisioning\ Profiles/` 目录下。

主要问题就是如何取出文件中的UUID，及其他相关的信息。
 
####方法1： 直接`grep`文件，并用正则匹配出UUID。
该方法的问题在于能很快取出UUID，但是不能方便取出其他参数信息。

```
uuid=`grep UUID -A1 -a adhoc.mobileprovision | grep -io "[-A-Z0-9]\{36\}"`
cp adhoc.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/$uuid.mobileprovision
```

批量处理的代码如下：

```
ios profiles:download:all --type distribution
for file in *.*provision*; do
    uuid=`grep UUID -A1 -a "$file" | grep -io "[-A-Z0-9]\{36\}"`
    extension="${file##*.}"
    echo "$file -> $uuid"
    mv -f "$file" ~/Library/MobileDevice/Provisioning\ Profiles/"$uuid.$extension"
done
```

####方法2：先解密文件，再使用`PlistBuddy`获取对应字段。
文章来源：[stackoverflow](http://stackoverflow.com/questions/6398364/parsing-mobileprovision-files-in-bash/10490095#10490095)

> 首先是解密`*.mobileprovision`文件。

**使用security**：`security cms -D -i abc.mobileprovision`

`security cms`: Encode or decode CMS messages.

**使用openssl**： `openssl smime -inform der -verify -noverify -in file.mobileprovision`

> PlistBuddy是mac系统自带的一个工具，路径在`/usr/libexec/PlistBuddy`下。

* 下面这段代码用`openssl`将解密后的文件写入临时plist文件中，然后用`PlistBuddy`来获得UUID：

```
openssl smime -inform der -verify -noverify -in file.mobileprovision > tmp.plist
/usr/libexec/PlistBuddy -c 'Print :Entitlements:application-identifier' tmp.plist
```

* 下面这段Python脚本用`security`和`PlistBuddy`来获得UUID：

```
command = "/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $(security cms -D -i abc.mobileprovision)"
uuid = os.popen(command).readline().rstrip('\n')
```

* 下面这篇完整shell代码也用`security`和`PlistBuddy`来获取UUID，来源：[GithubGist](https://gist.github.com/djromero/5dce571a1a40e8bd07f3#file-update_provisioning_profile-sh)：

```
#!/bin/sh
# 
# Download and install a single iOS provisioning profile
# Requires https://github.com/nomad/cupertino
#
# Usage
# - Login to your account once:
# ios login
# - Configure TEAM and PROFILE (instructions below)
# - Run update_provisioning_profile.sh at anytime, usually after adding/removing devices to the profile

# Configure the team identifier
# Copy it from developer portal or just use cupertino to get it:
# ios devices 
# Copy the string in parens and set it as TEAM
TEAM="team id"

# Configure the profile name you want to manage
# Copy it from developer portal or use cupertino to get a list (ignoring Xcode managed profiles):
# ios profiles --team ${TEAM} | grep -v 'iOS Team Provisioning Profile' 
# Copy the name as-is and set as PROFILE
PROFILE="profile name"

# Fetch the profile using `cupertino` tool
# you need to run `ios login` once to setup the account
ios profiles:download "${PROFILE}" --team ${TEAM}
PROFILE_FILE=`echo $PROFILE | tr ' ' '_'` # `cupertino` tool will replace spaces with _
UUID=`/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $(security cms -D -i ${PROFILE_FILE}.mobileprovision)`

# copy where Xcode can find it
cp ${PROFILE_FILE}.mobileprovision "$HOME/Library/MobileDevice/Provisioning Profiles/${UUID}.mobileprovision"

# clean
rm ${PROFILE_FILE}.mobileprovision
```

###其他相关文档：

* [https://gist.github.com/benvium/2568707](https://gist.github.com/benvium/2568707)
* [mpParse](https://github.com/dwelch2344/mpParse) 项目工程，可编译成可执行文件：用oc写的。
* [mpParse](https://gist.github.com/jessearmand/711794) 代码段，用oc写的。
* [.mobileprovision Files Structure and Reading](http://0xc010d.net/mobileprovision-files-structure-and-reading/)文章。