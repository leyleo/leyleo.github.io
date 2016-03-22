---
layout: post
title: "去掉git中不需要的部分"
description: "去掉git中不需要的部分"
category: 技术
tags: [git]
excerpt: "在xcode的项目工程中，不小心多提交了些无用的文件，处理方法："

---
{% include JB/setup %}

在xcode的项目工程中，不小心多提交了些无用的文件，处理方法：

```
# remove cuser-stuff from the repository (but not locally)
$ git rm --cached $(find . -name "*.xcuserstate" -or -name "*.xcuserdata")
# commit the file removal
$ git commit $(find . -name "*.xcuserstate" -or -name "*.xcuserdata") -m "don't track cuser stuff"
# prevent the cuser-stuff from accidentally adding it
$ echo "*.cuserdata" > .gitignore
$ echo "*.cuserstate" > .gitignore
$ git add .gitignore
$ git commit .gitignore -m "don't track user-specific data"
```

原文链接：

[http://stackoverflow.com/questions/16147433/commit-or-discard-the-changes-and-try-again](http://stackoverflow.com/questions/16147433/commit-or-discard-the-changes-and-try-again)
