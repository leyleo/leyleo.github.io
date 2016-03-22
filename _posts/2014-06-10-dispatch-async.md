---
layout: post
title: "dispatch_async"
description: "dispatch_async"
category: 技术
tags: [iOS]
excerpt: "前后台切换"

---
{% include JB/setup %}

前后台切换

```
//  后台执行：
 dispatch_async(dispatch_get_global_queue(0, 0), ^{
      // something
 });
 // 主线程执行：
 dispatch_async(dispatch_get_main_queue(), ^{
      // something
 });

 // 一次性执行：
 static dispatch_once_t onceToken;
 dispatch_once(&onceToken, ^{
     // code to be executed once
 });

 // 延迟2秒执行：
 double delayInSeconds = 2.0;
 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
     // code to be executed on the main queue after delay
 });

// 线程组
dispatch_group_t group = dispatch_group_create();
 dispatch_group_async(group, dispatch_get_global_queue(0,0), ^{
      // 并行执行的线程一
 });
 dispatch_group_async(group, dispatch_get_global_queue(0,0), ^{
      // 并行执行的线程二
 });
 dispatch_group_notify(group, dispatch_get_global_queue(0,0), ^{
      // 汇总结果
 });
```

----

参考文章：

[唐巧的技术博客：使用GCD](http://blog.devtang.com/blog/2012/02/22/use-gcd/)
