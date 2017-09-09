---
layout: post
title: "Swift之函数式编程"
description: "Swift之函数式编程"
category: 技术
tags: [swift, 函数式编程, Optional, map, flatMap]
excerpt: "最近学习 Swift 的函数式编程，觉得甚是蒙圈，幸好碰到唐巧的一系列烧脑文章，干货满满。这里记一些重点笔记和个人理解。"

---
{% include JB/setup %}

最近学习 Swift 的函数式编程，觉得甚是蒙圈，幸好碰到[唐巧](http://www.infoq.com/cn/profile/唐巧)的一系列烧脑文章，干货满满。这里分五部分记一些重点笔记和个人理解：

### 铺垫一：Optional 可选

在OC中，向一个 `nil` 的对象发消息是默认不产生任何效果的行为，但是对于强类型语言 Swift ，需要在编译期做更多的检查，故而引入类型推断，而避免空指针调用是安全的类型推断基本需求之一，于是 Optional 应运而生。

Optional 在 Swift 中实际上是一个枚举类型：

```
public enum Optional<Wrapped> : ExpressibleByNilLiteral
{
    case none
    case some(Wrapped)

    public init(nilLiteral: ()) { self = .none } // var i: Index? = nil
    public init(_ some: Wrapped) { self = .some(some) } // var i: Int? = Int('42')
}
```

Optional 类型的变量可以理解为一个薛定谔的包裹，在使用时需要解包，解出来的可能是变量的值，也可能是 `nil`，也可能是另一个包裹（就像套娃）。

通常我们使用`if let`方式解包，但是这种方式在套娃模式下就会出现问题。例如：

```
let a: Int? = nil
let b: Int?? = a
let c: Int?? = nil

if let _ = a {
    print("a is not nil")
}
if let _ = b {
    print("b is not nil")
}
if let _ = c {
    print("c is not nil")
}
```

运行结果就是：

```
b is not nil
```

`What???` 说好的 `if let` 判空怎么不按理出牌了？

使用`fr v -R a`查看`a`变量的内存结构。

```
(Swift.Optional<Swift.Int>) a = none {
  some = {
    _value = 0
  }
}
(Swift.Optional<Swift.Optional<Swift.Int>>) b = some {
  some = none {
    some = {
      _value = 0
    }
  }
}
(Swift.Optional<Swift.Optional<Swift.Int>>) c = none {
  some = some {
    some = {
      _value = 0
    }
  }
}
```

这个内存结构类似二叉树：

![](http://cdn2.infoqstatic.com/statics_s2_20170905-0254/resource/articles/swift-brain-gym-optional/zh/resources/687474703a2f2f77773.jpg)

* 对于一层可选`a`，它可以是一个`.none`，也可以是一个`Int`的数值；
* 对于二层可选`b`，它可以是`.none`，也可以是一个`Optional<Int>`，这就导致`b`初始化时传入一个`Optional<Int>`型的`a`，它就成为了`.some`类型，不能被`if let`判空。
* 对于二层可选`c`，它传入了一个`nil`，就被初始化成了`.none`类型。

### 铺垫二：函数

先来看看匿名函数（闭包）的瘦身历程。

**闭包表达式的完整形式：**

```
{ (参数) -> 返回值类型 in
    代码
}
```

以下为例：

```
func tailingClosures(num: Int, handler: (_ a: Int, _ b: Int) -> Int){
    handler(num * 2, num + 2)
}
```
普通调用方法👇：

```
tailingClosures(num: 3, handler: { (a:Int, b:Int) -> Int in
    return a + b
})
```

当最后一个参数为闭包时，可以使用尾随闭包👇：将闭包置于函数后，并省去参数。

```
tailingClosures(num: 3) { (a:Int, b:Int) -> Int in
    return a + b
}
```

如果一个函数的返回类型和参数类型可以推导出来，则返回类型和参数类型可以省略。👇

```
tailingClosures(num: 3) { (a:Int, b:Int) in
    return a + b
}

tailingClosures(num: 3) { (a, b) in
    return a + b
}
```

如果参数的个数可以推导出来，可以不写参数。使用$0，$1，$2... 这样的方式引用参数。👇

```
tailingClosures(num: 3) {
    return $0 + $1
}
```

如果函数体只有一行，可以把`return`省略掉。👇

```
tailingClosures(num: 3) {
    $0 + $1
}
```

看完了瘦身后的函数表达式，并不意味着结束，看看这个无聊的需求：通过一个构造工厂函数，传入两个函数返回一个新的函数。

```
func funcBuild(f: @escaping (Int) -> Int, g: @escaping (Int) -> Int)
    -> (Int) -> Int
{
    return { f(g($0)) }
}

let f1 = funcBuild(f: {$0 + 2}, g: {$0 + 3})
f1(0) // 结果为5
let f2 = funcBuild(f: {$0 * 2}, g: {$0 * 5})
f2(1) // 结果为10
```

这里有一个关键字`@escaping`，它表示这个闭包是可以“逃出”这个函数的。什么意思呢？当一个闭包作为参数传到一个函数中，但是这个闭包在函数返回之后才被执行，这个闭包被称为逃逸闭包。通常会用在异步操作的情况。将一个闭包标记为`@escaping`意味着必须在逃逸闭包中显示地引用`self`。

另外，上面的`->`用多了之后就有点儿眼花缭乱了，写了一遍又一遍还不容易扩展，还记得`typealias`嘛？它能使代码清晰很多。

```
typealias IntFunction = (Int) -> Int

func funcBuild(f: @escaping IntFunction, g: @escaping IntFunction)
    -> IntFunction
{
    return { f(g($0)) }
}
```

还有一种更宽泛的写法，那就是使用泛型：

```
func funcBuild<T, U, V>(f: @escaping (T) -> U, g: @escaping (V) -> T) -> (V) -> U
{
    return { f(g($0)) }
}

let f1 = funcBuild(f: {$0 + 2}, g: {$0 + 3})
let f2 = funcBuild(f: {"NO.\($0)"}, g: {$0 * 10})
f2(2)
```

### 高阶函数

先说两个概念型的名词：

高阶函数（high order func），指可以将其他函数作为参数或者返回结果的函数。

一级函数（first class func），指可以出现在任何其他构件（比如变量）地方的函数。

**`map`**

```
map { (Element) -> Element in
    对 element 进行处理
}
```
一般用在集合类型，对集合里的元素进行遍历，函数体里实现对每一个元素的操作。

```
var arr = [1,3,2,4]
let mapres = arr.map {
    "NO." + String($0)
}
// 运行结果：["NO.1", "NO.3", "NO.2", "NO.4"]
```

**`reduce`**

```
reduce(Result) { (Result, Element) -> Result in
    基于 Result 对当前的 Element 进行操作，并返回新的 Result
}
```

一般用在集合类型，对集合里的元素进行叠加处理，函数体里传两个参数，第一个是之前的叠加结果，第二个是当前元素，返回值是对当前元素叠加后的结果。

```
// 对数组里的元素：奇数相加，偶数相乘
var arr = [1,3,2,4]
let reduceRes = arr.reduce((0,1)) { (a:(Int,Int), t:Int) -> (Int,Int) in
    if t % 2 == 1 {
        return (a.0 + t, a.1)
    } else {
        return (a.0, a.1 * t)
    }
}
// 运行结果：(4,8)
```

**`filter`**

```
filter { (Element) -> Bool
    对元素的筛选条件，返回 Bool
}
```

一般用在集合类型，对集合里的元素进行筛选。函数体里实现筛选条件，返回 `true` 的元素通过筛选。

```
var arr = [1,3,2,4]
let filterRes = arr.filter {
    $0 % 2 == 0
}
// 运行结果：[2,4]
```

### flatMap

首先先看下 Swift 源码里对集合数组的`map`和`flatmap`的实现：

```
// Sequence.swift
extension Sequence {
    public func map<T>(_ transform: (Element) -> T) -> [T] {}
}

// SequenceAlgorithms.swift.gyb
extension Sequence {
    public func flatMap<T>(_ transform: (Element) -> T?) -> [T] {}
    public func flatMap<S : Sequence>(_ transform: (Element) -> S) -> [S.Element] {}
}
```

前面我们已经知道，`map`是一种遍历，而上面的代码又显示出来，`flatmap`有两种重载的函数：

* 其中一种与`map`非常相似，差别只在闭包里的返回值变成了可选类型。
* 另一种稍微有点不同，闭包传入的是数组，最后返回的是数组的元素组成的集合。

```
// map
let arr = [1,2,nil,4,nil,5]
let arrRes = arr.map { $0 } // 结果为：[Optional(1), Optional(2), nil, Optional(4), nil, Optional(5)]

// flatmap
let brr = [1,2,nil,4,nil,5]
let brrRes = brr.flatmap { $0 } // 结果为：[1, 2, 4, 5]

let crr = [[1,2,4],[5,3,2]]
let ccRes = crr.flatmap { $0 } // 结果为：[1, 2, 4, 5, 3, 2]
let cdRes = crr.flatmap { c in
    c.map { $0 * $0 }
} // 结果为[1, 4, 16, 25, 9, 4]

// 使用 map 实现的上面平铺功能
let ceRes = Array(crr.map{ $0 }.joined()) // 同 ccRes
let cfRes = Array(crr.map{ $0 }.joined()).map{ $0 * $0 } // 同 cdRes
```

简单理解为，`flatMap`可以将多维数组平铺，也还以过滤掉一维数组中的`nil`元素。

`map`和`flatMap`不只在数组中可以使用，对于 Optional 类型也是可以进行操作的。先看下面这个例子：

```
let a: Date? = Date()
let formatter = DateFormatter()
formatter.dateStyle = .medium

let c = a.map(formatter.string(from:))
let d = a == nil ? nil : formatter.string(from: a!)
```

c 和 d 是两种不同的写法，c 写法是不是更优雅一些?

下面我们看一下 Swift 源码中对 Optional 的 `map`和`flatmap`实现:

```
public func map<U>(_ transform: (Wrapped) throws -> U) rethrows -> U? {
    switch self {
    case .some(let y):
      return .some(try transform(y))
    case .none:
      return .none
    }
}

public func flatMap<U>(_ transform: (Wrapped) throws -> U?) rethrows -> U? {
    switch self {
    case .some(let y):
      return try transform(y)
    case .none:
      return .none
    }
}
```

二者的区别在于闭包里对 Optional 的处理时机：`map`在拿到解包后的元素后进行操作，操作完之后对元素再次封包，并作为未封包的结果返回;而`flatMap`会直接拿着处理后的元素作为封包后的结果返回，也就意味着`flatMap`认为在`transform(y)`过程中已经进行了封包操作。

具体是什么意思呢？看👇例子的情况：

```
let s: String? = "abc"
let v = s.flatMap { Int($0) }
let u = s.map { Int($0) }

if let _=v {
    print("v")
}

if let _=u {
    print("u")
}
```
还记的铺垫一里的多层可选`if let`判断么？

先说结论，结果会输出`u`，因为：

```
v: Int?
u: Int??
```

具体使用`fr v -R`查看一下。

```
(Swift.Optional<Swift.Int>) v = none {
  some = {
    _value = 0
  }
}
(Swift.Optional<Swift.Optional<Swift.Int>>) u = some {
  some = none {
    some = {
      _value = 0
    }
  }
}
```

再看下面这个`flatMap`的例子吧：

```
var arr = [1, 2, 4]
let res = arr.first.flatMap {
    arr.reduce($0, combine: max)
}
```

它的功能就是计算数组的元素最大值，而且考虑了数组为空的情况。

在实际使用中呢，如果闭包的返回值必然不为`nil`，可以使用`map`的方式自动封装，但是如果闭包里面的处理结果有可能是`nil`，那么还是使用`flatMap`来避免产生多层可选的问题吧。

### 烧脑消食

看看巧哥的这几个问答：

* 数组的 `map` 函数和 Optinal 的 `map` 函数的实现差别巨大？但是为什么都叫 `map` 这个名字？

因为它们都是`Functor`。可以理解为：把一个函数应用于一个“封装过的值”上，得到一个新的“封装过的值”，但是函数的定义是从“未封装的值”到 **“未封装的值”** 。

* 数组的 `flatMap` 函数和 Optinal 的 `flatMap` 函数的实现差别巨大？但是为什么都叫 `flatMap` 这个名字？
* 数组的 `flatMap` 有两个重载的函数，两个重载的函数差别巨大，但是为什么都叫 `flatMap` 这个名字？

因为它们都是`Monad`。可以理解为：把一个函数应用于一个“封装过的值”上，得到一个新的“封装过的值”，但是函数的定义是从“未封装的值”到 **“封装后的值”**。

什么是`Functor`？什么是`Monad`呢？我看了一些文章之后，觉得下面这张图最能有效说明：

![](http://note.youdao.com/yws/api/personal/file/WEB1f9d8f5a7b84f8f44e3d88f055b6d3e3?method=download&shareKey=c8d74cba19ef218a80584162bb0f0785)

* `Functor`：应用一个函数到封装后的值，如`map`
* `Applicative`：应用一个封装后的函数到封装后的值
* `Monad`：应用一个返回封装后的值的函数到一个封装后的值，如`flatMap`

> 阅读：

* [Swift 烧脑体操（一）](http://www.infoq.com/cn/articles/swift-brain-gym-optional)
* [多重 OPTIONAL](http://swifter.tips/multiple-optional/)
* [Swift 烧脑体操（二） - 函数的参数](http://www.infoq.com/cn/articles/swift-brain-gym-arguments)
* [Swift 烧脑体操（三） - 高阶函数](http://www.infoq.com/cn/articles/swift-brain-gym-high-order-function)
* [Swift 烧脑体操（四） - map 和 flatMap](http://www.infoq.com/cn/articles/swift-brain-gym-map-and-flatmap)
* [Swift 烧脑体操（五）- Monad](http://www.infoq.com/cn/articles/swift-brain-gym-monad)
* [Functor, Applicative, 以及 Monad 的图片阐释](http://jiyinyiyong.github.io/monads-in-pictures/)
