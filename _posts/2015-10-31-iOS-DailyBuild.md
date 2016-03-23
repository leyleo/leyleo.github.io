---
layout: post
title: "iOS Daily Build简易脚本"
description: "iOS Daily Build简易脚本"
category: 技术
tags: [OS X, iOS, shell, xcode]
excerpt: "准备工作：1. 将脚本文件改名为工程的名字，例如这个DailyBuildTest的项目，就把脚本改名为DailyBuildTest.sh，并放到工程的根目录下。2. 将template.plist文件放到工程的根目录下。"

---
{% include JB/setup %}

#### 准备工作

1. 将  [脚本文件]({{BASE _PATH}}/assets/images/201510/DailyBuildTest.sh) 改名为工程的名字，例如这个**DailyBuildTest**的项目，就把脚本改名为`DailyBuildTest.sh`，并放到工程的根目录下。
2. 将  [template.plist]({{BASE _PATH}}/assets/images/201510/template.plist) 文件放到工程的根目录下。

#### 0. 从git同步

从git上同步最新的代码下来，并判断是否有更新，如果没有更新则退出。

``` sh
# 同步代码
git pull
# 判断近一日是否有提交更新
GitLog=`git log --since=1.days`
if [[ ! $GitLog ]]; then
	echo "nothing changed"
	exit 0
fi
```

#### 1. 获取脚本名字

获取当前日期，及工程的名字，拼接成生成的安装包的名字

``` sh
Date=`date +_%m%d`
ProjectName=`basename $0 .sh`
FILE_NAME=$ProjectName"_DailyBuild"$Date
echo $FILE_NAME
```

#### 2. 编译

首先设置工程的DailyBuild编译配置：

![configurations]({{BASE _PATH}}/assets/images/201510/DailyBuild_Configuration_1.png)

![configurations]({{BASE _PATH}}/assets/images/201510/DailyBuild_Configuration_2.png)

##### 查看本地的可用签名

`security find-identity -v -p codesigning`

示例：

``` sh
xxxxxxx@DailyBuildTest:security find-identity -v -p codesigning

1) F57**********************************018 "iPhone Distribution: Beijing XXX XXX Co., Ltd. (S8******SU)"
2) 6C0**********************************559 "iPhone Developer: XXX XXX XXX (5B******NR)"
2 valid identities found
```

> 关于**security**的用法请参考 [security doc](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/security.1.html)

##### 编译工程

`xcodebuild clean -configuration DailyBuild`：清除DailyBuild配置的已编译内容。

`xcodebuild -configuration DailyBuild`：使用DailyBuild配置编译工程。

`xcodebuild -configuration DailyBuild -target TargetName CODE_SIGN_IDENTITY="SignString"`：使用DailyBuild配置编译工程，并生成名字为TargetName的应用文件，并用SignString串签名。

示例：

```sh
xcodebuild clean -configuration DailyBuild
xcodebuild -configuration DailyBuild -target $ProjectName CODE_SIGN_IDENTITY="iPhone Developer: XXX XXX XXX (BA******R6)"
```

> 关于**xcodebuild**的用法请参考： [xcodebuild](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/xcodebuild.1.html)

#### 3. 检查是否编译成功

检查是否编译成功，如果不存在对应的文件，则退出。

```sh
AppPath="./build/DailyBuild-iphoneos/$ProjectName.app"
AppPath=`pwd`"/$AppPath"
echo "AppPath: "$AppPath
if [ ! -d "$AppPath" ]
then
	echo "编译异常"
	exit 0
fi
```

##### 查看应用的当前签名信息

`codesign -vv -d filename.app`

示例：

```sh
xxxxxxx@DailyBuildTest:codesign -vv -d DailyBuildTest.app

Executable=/.../DailyBuildTest.app/DailyBuildTest
Identifier=com.sae.DailyBuildTest
Format=bundle with Mach-O thin (arm64)
CodeDirectory v=20200 size=466 flags=0x0(none) hashes=14+5 location=embedded
Signature size=4363
Authority=iPhone Developer: XXX XXX XXX (5B******NR)
Authority=Apple Worldwide Developer Relations Certification Authority
Authority=Apple Root CA
Signed Time=Apr 21, 2015, 4:30:35 PM
Info.plist entries=26
TeamIdentifier=87******NG
Sealed Resources version=2 rules=12 files=8
Internal requirements count=1 size=180
```

##### 验证应用的签名是否完整

`codesign --verify filename.app`: 如果没有任何输出，代表签名是完整的。

##### 重新签名应用

`codesign -s 'SignString' filename.app`: 对未签名的应用进行签名

`codesign -f -s 'SignString' filename.app`: 对已签名的应用重新签名，`-f`：替换之前的签名

示例：

```sh
xxxxxxx@DailyBuildTest:codesign -f -s 'iPhone Developer: XXX XXX (8G******AS)' DailyBuildTest.app

DailyBuildTest.app: replacing existing signature
```

> 关于**codesign**的用法请参考:  [codesign](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/codesign.1.html)

#### 4. 打包

用**xcrun**进行打包

```sh
rm -rf ipa/
mkdir -p ipa
ResultIpaPath=`pwd`"/ipa/$FILE_NAME.ipa"
echo "result ipa path: "$ResultIpaPath
xcrun -sdk iphoneos PackageApplication -v $AppPath -o $ResultIpaPath
```

##### 生成ipa包

`xcrun -sdk iphoneos PackageApplication -v $AppPath -o $ResultIpaPath`: 注意`$ResultIpaPath`应为全路径，否则会默认生成在`/var/folder/...`目录下。

> 关于**xcrun**的用法请参考: [xcrun](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/xcrun.1.html)

> 注意：如果要用xcrun重新签名app，可能会出现下面的错误：

```sh
error: /usr/bin/codesign --force --preserve-metadata=identifier,entitlements,resource-rules --sign iPhone Developer: XXX XXX XXX (5B******NR) --resource-rules=/var/folders/v8/hg1z09vn7r93pq7vlz50jl1c0000gn/T/c3Cn397C9I/Payload/DailyBuildTest.app/ResourceRules.plist /var/folders/v8/hg1z09vn7r93pq7vlz50jl1c0000gn/T/c3Cn397C9I/Payload/DailyBuildTest.app failed with error 1. Output: Warning: usage of --preserve-metadata with option "resource-rules" (deprecated in Mac OS X >= 10.10)!
Warning: --resource-rules has been deprecated in Mac OS X >= 10.10!
/var/folders/v8/hg1z09vn7r93pq7vlz50jl1c0000gn/T/c3Cn397C9I/Payload/DailyBuildTest.app/ResourceRules.plist: cannot read resources
```

解决方案：

`project -> Targets -> Current target -> Build Settings -> Code Signing Resource Rules Path` add: `$(SDKROOT)/ResourceRules.plist`

> 参考：[stackoverflow](http://stackoverflow.com/questions/26459911/resource-rules-has-been-deprecated-in-mac-os-x-10-10?lq=1)

#### 5. 上传打包文件到SAE

将打包好的ipa文件上传到SAE的daily build项目里，并将文件的路径存到`$IPA_URL`中，

```sh
CurlResult=`curl "http://xxxxx.sinaapp.com/upload" -F "attachment=@$ResultIpaPath"`
echo "curl result: "$CurlResult
isUploadSuccess=`echo $CurlResult | grep "0"`
if [ ! $isUploadSuccess ]
	then
	echo "upload package fail!"
	exit 0
fi
# http://xxxxx.sinaapp.com/upload 接口将文件存储于SAE storage中
IPA_URL="http://xxxxx-package.stor.sinaapp.com/"$FILE_NAME".ipa"
echo "upload to: "$IPA_URL
```

#### 6. 生成plist文件

需要将编译项目的一些信息（url，bundle-identifier，bundle-version，title等）填到**template.plist**里面，初始状态如下：

![template plist]({{BASE _PATH}}/assets/images/201510/DailyBuild_template_plist.png)

```sh
if [ ! "$MANIFEST_NAME" ]
then
MANIFEST_NAME=$FILE_NAME".plist"
echo "manifest: "$MANIFEST_NAME
fi

PlistPath=`pwd`"/ipa/$MANIFEST_NAME"
TemplatePlist=`pwd`"/template.plist"

BUNDLE_DISPLAY_NAME=`/usr/libexec/PlistBuddy -c "print :CFBundleDisplayName" $AppPath/info.plist`
BUNDLE_VERSION=`/usr/libexec/PlistBuddy -c "print :CFBundleShortVersionString" $AppPath/info.plist`
BUNDLE_IDENTIFIER=`/usr/libexec/PlistBuddy -c "print :CFBundleIdentifier" $AppPath/info.plist`

/usr/libexec/PlistBuddy -c "merge $TemplatePlist" $PlistPath
/usr/libexec/PlistBuddy -c "set :items:0:assets:0:url $IPA_URL" $PlistPath
/usr/libexec/PlistBuddy -c "set :items:0:metadata:bundle-identifier $BUNDLE_IDENTIFIER" $PlistPath
/usr/libexec/PlistBuddy -c "set :items:0:metadata:bundle-version $BUNDLE_VERSION" $PlistPath
/usr/libexec/PlistBuddy -c "set :items:0:metadata:title $BUNDLE_DISPLAY_NAME" $PlistPath
/usr/libexec/PlistBuddy -c "save" $PlistPath

echo "plist path: $PlistPath"
if [[ ! PlistPath ]]; then
	echo "generate plist fail"
	exit 0
fi
```

> 关于**Plist**的用法请参考: [Plist](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man5/plist.5.html)

> 关于**PlistBuddy**的用法请参考: [PlistBuddy](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man8/PlistBuddy.8.html)

#### 7. 上传plist文件

将plist上传到SAE项目目录

```sh
UploadPlistResult=`curl "http://xxxxx.sinaapp.com/upload" -F "attachment=@$PlistPath"`
echo $UploadPlistResult
isUploadPlistSuccess=`echo $UploadPlistResult | grep "0"`
if [ ! $isUploadPlistSuccess ]
	then
	echo "upload plist fail!"
	exit 0
fi
```

#### 8. 上传 change note

从git上获得当天的git log，作为文本上传到SAE项目目录

```sh
LogPath=`pwd`"/ipa/Log_$FILE_NAME.log"
echo `git log ios --pretty=format:'%ci | %s' --since=1.days` >> $LogPath
UploadLogResult=`curl "http://xxxxx.sinaapp.com/upload" -F "attachment=@$LogPath"`
echo $UploadLogResult
isUploadLogSuccess=`echo $UploadLogResult | grep "0"`
if [ ! $isUploadLogSuccess ]
	then
	echo "upload log fail!"
	exit 0
fi
```

#### 9. 制作Daily Build下载页面

略
