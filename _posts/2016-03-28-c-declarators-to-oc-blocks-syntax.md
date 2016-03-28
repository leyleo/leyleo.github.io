---
layout: post
title: "一分钟搞懂block声明"
description: "一分钟搞懂block声明"
category: 技术
tags: [iOS]
excerpt: "刚开始接触block时，对它的声明总是一知半解搞不明白，直到看到\"From C Declarators to Objective-C Blocks Syntax\"，终于豁然开朗了。"

---
{% include JB/setup %}

刚开始接触 **block** 时，对它的声明总是一知半解搞不明白，直到看到[From C Declarators to Objective-C Blocks Syntax](http://nilsou.com/blog/2013/08/21/objective-c-blocks-syntax/)，终于豁然开朗了。

变量声明：

```c
int a; 			// a 是一个int类型的变量
```

添加修饰符：

`*`和`^`是左向修饰符，总是处于被修饰变量的左侧；`[]`和`()`是右向修饰符，处于被修饰变量的右侧。

```c
// a is a pointer to an int
int *a; 		// a 是一个指向int值的指针

// a is an array of ints
int a[]; 		// a 是一个int数组

// f is a function that returns an int
int f(); 		// f 是一个返回int值的函数

// b is a block pointer to a function that returns an int
int (^b)(); 	// b 是一个块指针，指向一个返回int值的函数
```

> 说明：`^`闭包修饰符（block/closure pointer modifer）只能用来修饰方法。

修饰符的组合：

因为`[]`和`()`的优先级比`*`和`^`的优先级高，所以我们可以使用英文顺序读变量描述：**从变量名开始尽量向右读**，直到变量结束，然后再读左侧修饰符。

```c
// a is an array of pointers to an int.
int *a[]; 		// a 是一个指针类型的数组，数组中的每个元素都是一个指向int值的指针
int *(a[]); 	// 同上

// a is a pointer to an array of ints.
int (*a)[]; 	// a 是一个指向int数组的指针，数组中的每个元素都是int类型

// f is a function that takes an array of 10 ints as an argument and return an int.
int f(int [10]); 		// f 是一个返回int值的函数，该函数带参，参数为一个int数组

// f is a function that returns a pointer to an int.
int *f();				// f 是一个返回int类型指针的函数
int *(f()); 			// 同上

// f is pointer to a function that returns an int.
int (*f)();			// f 是一个指向函数的指针，该函数返回值为int类型
```

抽象声明：

有时候我们可以省略变量名，使用抽象声明，如：

```c
malloc(sizeof(long *));
int f(long *);
- (long **)methodWithArgument:(int *)a;
int (^)(long);
```

了解了这些规则，妈妈再也不担心我写错block声明了。

> 参考文章：

[From C Declarators to Objective-C Blocks Syntax](http://nilsou.com/blog/2013/08/21/objective-c-blocks-syntax/)

[从C语言的变量声明到Objective-C中的Block语法](http://www.cocoachina.com/ios/20160328/15789.html)
