---
layout: post
title: "swift的Error Handle"
description: "swift的Error Handle"
category: 技术
tags: [swift, throws, try]
excerpt: "之前我们在OC里，经常会遇到带有NSError指针类型参数的API，当有错误发生时，就会有错误信息被保存在这个NSError类型的对象里。"

---
{% include JB/setup %}

> 注：本文代码基于Swift3.0实现

之前我们在OC里，经常会遇到带有`NSError`指针类型参数的API，当有错误发生时，就会有错误信息被保存在这个`NSError`类型的对象里。例如：

```objective-c
- (BOOL)removeItemAtURL:(NSURL *)URL
                  error:(NSError **)error;
```

使用时，需要传递这个`NSError`的对象指针过去：

```objective-c
NSError *error;
BOOL success = [manager removeItemAtURL: url error: &error];
if (error != nil) {
  // 有错误发生
}
```

而从Swift 2.0开始，这类API改为使用`throws`关键字描述，如下：

```swift
func removeItem(at: URL) throws
```

具体该怎么使用呢？最通常的使用方式如下：

```swift
do {
  try manager.removeItem(at: url)
} catch let error as NSError {
  // 获得NSError类型的错误
}
```

当知道具体的错误类型时，可以分类进行处理：

``` swift
do {
  try manager.removeItem(at: url)
} catch NSCocoaError.fileNoSuchFileError {
} catch NSCocoaError.fileReadInvalidFileNameError {
}
```

当然，如果你想简单省略，可以使用`try?`忽略对异常的处理，它返回一个Optional值，如果运行正常，结果会包含语句的返回值，如果运行出错，结果为nil。但是这样一来不利于后续的问题调试，不推荐使用。

``` swift
try? manager.removeItem(at: url)
```

如果使用`try!`来执行上面操作：

```swift
try! manager.removeItem(at: url)
```

遇到异常时，会直接抛出异常：

```sh
fatal error: 'try!' expression unexpectedly raised an error: Error Domain=NSCocoaErrorDomain Code=4 "“copyed.txt” couldn’t be removed." UserInfo={NSFilePath=/var/folders/.../Documents/copyed.txt, NSUserStringVariant=(
    Remove
), NSUnderlyingError=0x7fb461719b90 {Error Domain=NSPOSIXErrorDomain Code=2 "No such file or directory"}}: file /Library/Caches/com.apple.xbs/Sources/swiftlang/swiftlang-800.0.30/src/swift/stdlib/public/core/ErrorType.swift, line 149
```

#### 代码示例一

```swift
enum ScoreError: Error {
    case Invalid(String)
    case Overflow
}

func getLevel(score: Int) throws -> String {
    if score < 0 {
        throw ScoreError.Invalid("input score is: \(score)")
    } else if score < 60 {
        return "D"
    } else if score < 75 {
        return "C"
    } else if score < 85 {
        return "B"
    } else if score <= 100 {
        return "A"
    } else {
        throw ScoreError.Overflow
    }
}

do {
    let level = try getLevel(score: -100)
    print("level: \(level)")
} catch ScoreError.Overflow {
    print("score overflow")
} catch ScoreError.Invalid(let string) {
    print("Invalid [ \(string) ]")
} catch let error as NSError{
    print("other error")
}
```

#### 代码示例二

```swift
struct ScoreError: Error {
    enum ErrorKind {
        case invalid
        case overflow
    }

    let score: Int
    let description: String
    let kind: ErrorKind
}

func getLevel(_ score: Int) throws -> String {
    if score < 0 {
        throw ScoreError(score: score, description: "negative score", kind: .invalid)
    } else if score < 60 {
        return "D"
    } else if score < 75 {
        return "C"
    } else if score < 85 {
        return "B"
    } else if score <= 100 {
        return "A"
    } else {
        throw ScoreError(score: score, description: "score is overflow", kind: .overflow)
    }
}

do {
    let level = try getLevel(-100)
    print("level: \(level)")
} catch let serror as ScoreError {
    print("error: \(serror.kind) [\(serror.score) : \(serror.description)]")
} catch {
    print("other error: \(error)")
}
```

> 参考：

[错误和异常处理](http://swifter.tips/error-handle/)

[Error Handle](https://developer.apple.com/library/prerelease/content/documentation/Swift/Conceptual/BuildingCocoaApps/AdoptingCocoaDesignPatterns.html)

[Error Handling](https://developer.apple.com/library/prerelease/content/documentation/Swift/Conceptual/Swift_Programming_Language/ErrorHandling.html#//apple_ref/doc/uid/TP40014097-CH42-ID508)
