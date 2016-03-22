---
layout: post
title: "iOS8中UITableView设置分割线边界"
description: "iOS8中UITableView设置分割线边界"
category: 技术
tags: [iOS]
excerpt: "在iOS7中，我们可以使用setSeparatorInset:来设置分割线。而在iOS8中，可以在程序载入后使用下面代码进行兼容性设置："

---
{% include JB/setup %}

在iOS7中，我们可以使用`setSeparatorInset:`来设置分割线。

```
if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
}
```

而在iOS8中，可以在程序载入后使用下面代码进行兼容性设置：

```
if ([UITableViewCell instancesRespondToSelector:@selector(setLayoutMargins:)]) {
    [[UITableViewCell appearance]setLayoutMargins:UIEdgeInsetsZero];
}
if ([UITableView instancesRespondToSelector:@selector(setLayoutMargins:)]) {
    [[UITableView appearance] setLayoutMargins:UIEdgeInsetsZero];
}
```

----

参考来源：

[https://stackoverflow.com/questions/18365049/is-there-a-way-to-make-uitableview-cells-in-ios-7-not-have-a-line-break-in-the-s/18749172#18749172](https://stackoverflow.com/questions/18365049/is-there-a-way-to-make-uitableview-cells-in-ios-7-not-have-a-line-break-in-the-s/18749172#18749172)
