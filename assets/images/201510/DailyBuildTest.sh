#!/bin/sh

#  DailyBuild.sh
#  
#
#  Created by Ley Liu on 15-02-04.
#  Copyright (c) 2012年 LL. All rights reserved.

# 0. get fresh code
# git pull

# GitLog=`git log --since=1.days`
# if [[ ! $GitLog ]]; then
# 	echo "nothing changed"
# 	exit 0
# fi

# 1. get script parameters
Date=`date +_%m%d`
ProjectName=`basename $0 .sh`
FILE_NAME=$ProjectName"_DailyBuild"$Date
echo $FILE_NAME

# 2. build
echo "-- build --"
xcodebuild clean -configuration DailyBuild
# xcodebuild -configuration DailyBuild
xcodebuild -configuration DailyBuild -target $ProjectName CODE_SIGN_IDENTITY="iPhone Developer: XXX XXX XXX (**********)"

# 3. prepare ipa
AppPath="./build/DailyBuild-iphoneos/$ProjectName.app"
AppPath=`pwd`"/$AppPath"
echo "AppPath: "$AppPath
if [ ! -d "$AppPath" ] 
then
	echo "编译异常"
	exit 0
fi

# 4. sign code
rm -rf ipa/
mkdir -p ipa
ResultIpaPath=`pwd`"/ipa/$FILE_NAME.ipa"
echo "result ipa path: "$ResultIpaPath
xcrun -sdk iphoneos PackageApplication -v $AppPath -o $ResultIpaPath

# 5. upload file
if [ ! -f "$ResultIpaPath" ]
	then
	echo "打包失败"
	exit 0
fi

CurlResult=`curl "http://xxxxx.sinaapp.com/upload" -F "attachment=@$ResultIpaPath"`

# 
echo "curl result: "$CurlResult
isUploadSuccess=`echo $CurlResult | grep "0"`
if [ ! $isUploadSuccess ]
	then
	echo "upload package fail!"
	exit 0
fi

IPA_URL="http://xxxxx-package.stor.sinaapp.com/"$FILE_NAME".ipa"
echo "upload to: "$IPA_URL

echo "prepare plist"

# 6. get info from info.plist
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

# 7. upload plist

echo "upload plist"
UploadPlistResult=`curl "http://xxxxx.sinaapp.com/upload" -F "attachment=@$PlistPath"`
echo $UploadPlistResult
isUploadPlistSuccess=`echo $UploadPlistResult | grep "0"`
if [ ! $isUploadPlistSuccess ]
	then
	echo "upload plist fail!"
	exit 0
fi

# 8. upload change note
# echo "--- Get Change notes ---"
# LogPath=`pwd`"/ipa/Log_$FILE_NAME.log"
# echo `git log ios --pretty=format:'%ci | %s' --since=1.days` >> $LogPath
# UploadLogResult=`curl "http://xxxxxx.sinaapp.com/upload" -F "attachment=@$LogPath"`
# echo $UploadLogResult
# isUploadLogSuccess=`echo $UploadLogResult | grep "0"`
# if [ ! $isUploadLogSuccess ]
# 	then
# 	echo "upload log fail!"
# 	exit 0
# fi

echo "--- Everything is Done! `date +"%Y-%m-%d %T"` ---"

# open .
exit 0