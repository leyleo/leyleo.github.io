---
layout: post
title: "Swift的运算符"
description: "Swift的运算符"
category: 技术
tags: [swift, 运算符]
excerpt: "这里介绍了几个比较新鲜的运算符，及如何在代码中重载运算符和自定义运算符。"

---
{% include JB/setup %}

这里介绍了几个比较新鲜的运算符，及如何在代码中重载运算符和自定义运算符。

### 运算符

#### 1. 比较元组

比较运算符`== != > < >= <=`除了能够比较两个值以外，还能够比较元组。比较元组的方法就是**从左往右**依次比较元组中的每个值，遇到不同的值停止比较。当然，前提是元组中的值类型都要是可以进行比较的。需要注意的是，`Bool`类型的值无法比较。比如，类型为`(Int, String)`的元组是可以进行比较的。

```swift
(1, "zw") < (2, "ab")  // 结果为true，因为 1<2。
(3, "happy") < (3, "sad") // 结果为true，因为 3==3，而 happy<sad
(4, "dog") == (4, "dog") // 结果为true，因为 4==4，且 dog==dog
```

> 注：Swift标准库所支持的比较元组最多不超过7个元素。

#### 2. `??`

`a ?? b`表示如果optional a非空，则返回unwrap后的值，如果为nil，则返回默认的b值。`a ?? b`等同于`a != nil ? a! : b`。举例说明一下：

```swift
let defaultColorName = "red"
var userDefinedColorName: String?
var colorNameToUse = userDefinedColorName ?? defaultColorName
```

#### 3. `...`和`..<`

`a...b`表示从a到b的闭区间，数学上的表示为[a, b]，区间包含b；`a..<b`表示从a到b的半开区间，数学上的表示是[a, b)，区间不包含b。

#### 4. `&+`和`&-`和`&*`

在使用算术运算符时，Swift标准库默认这些操作是没有溢出的，也就是说，假如我们定义了一个`Int8`型的参数`a=127`，执行`+ 1`运算操作后a超过了`Int8`的范围限制[-128,127]，系统将会抛出错误。而使用`&+ 1`进行加运算后，能够自动处理位运算。

```swift
var a = Int8.max // a的值为127
a = a + 1 // error
a = a &+ 1 // a的值为-128
```

### 运算符的重载

我们可以在自定义的`class`或者`structure`中重载已有的运算符或者自定义运算符。运算符有三种：

前缀（prefix）运算符：例如 -a，++b 等

中缀（infix）运算符：一般用作连接两个变量，例如 a + b，c == d 等

后缀（postfix）运算符：例如 a--，b++等

下面通过一个结构体**Vector3D**来说明一下运算符的重载。

```swift
struct Vector3D {
    var x = 0.0, y = 0.0, z = 0.0
}

extension Vector3D {
    static func + (left: Vector3D, right: Vector3D) -> Vector3D {
        return Vector3D(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
    }

    static func - (left: Vector3D, right: Vector3D) -> Vector3D {
        return Vector3D(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
    }

    static prefix func - (vector: Vector3D) -> Vector3D {
        return Vector3D(x: -vector.x, y: -vector.y, z: -vector.z)
    }

    static func += (left: inout Vector3D, right: Vector3D) {
        left = right + left
    }

    static func -= (left: inout Vector3D, right: Vector3D) {
        left = left - right
    }

    static prefix func -- (vector: inout Vector3D) -> Vector3D{
        vector -= Vector3D(x: 1.0, y: 1.0, z: 1.0)
        return vector
    }

    static postfix func -- (vector: inout Vector3D) -> Vector3D {
        let old = vector
        vector -= Vector3D(x: 1.0, y: 1.0, z: 1.0)
        return old
    }

    static func == (left: Vector3D, right: Vector3D) -> Bool {
        return (left.x == right.x) && (left.y == right.y) && (left.z == right.z)
    }

    static func != (left: Vector3D, right: Vector3D) -> Bool {
        return !(left == right)
    }
}
```

> 需要注意的是，`inout`关键字表示在方法内该变量会发生改变。

在实现自定义运算符之前，需要用关键字`operator`对运算符进行声明，并标识为`prefix`，`infix`或者`postfix`。

```swift
infix operator ++-
prefix operator +++

extension Vector3D {
    static func ++- (left: Vector3D, right: Vector3D) -> Vector3D {
        return Vector3D(x: left.x + right.x, y: left.y + right.y, z: left.z - right.z)
    }

    static prefix func +++ ( vector: inout Vector3D) -> Vector3D {
        vector += vector
        return vector
    }
}

var v1 = vector1 ++- vector2
let v2 = +++v1
```
-----

> 参考文章：

[Basic Operators](https://developer.apple.com/library/prerelease/content/documentation/Swift/Conceptual/Swift_Programming_Language/BasicOperators.html)

[Advanced Operators](https://developer.apple.com/library/prerelease/content/documentation/Swift/Conceptual/Swift_Programming_Language/AdvancedOperators.html)

[Swift Standard Library Operators](https://developer.apple.com/reference/swift/1851035-swift_standard_library_operators)
