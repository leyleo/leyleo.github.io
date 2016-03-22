---
layout: post
title: "Swift单例模式"
description: "Swift单例模式"
category: 技术
tags: [swift]
excerpt: "介绍了三个方法："

---
{% include JB/setup %}

来源：[https://github.com/hpique/SwiftSingleton](https://github.com/hpique/SwiftSingleton)

方法一：

```
let _SingletonASharedInstance = SingletonA()
class SingletonA  {
    class var sharedInstance : SingletonA {
        return _SingletonASharedInstance
    }
}
```

方法二：

```
class SingletonB {
    class var sharedInstance : SingletonB {
        struct Static {
            static let instance : SingletonB = SingletonB()
        }
        return Static.instance
    }
}
```

方法三：

```
class SingletonC {
    class var sharedInstance : SingletonC {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : SingletonC? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = SingletonC()
        }
        return Static.instance!
    }
}
```
