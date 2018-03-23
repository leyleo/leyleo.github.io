---
layout: post
title: "RN分包之Bundle改造"
description: ""
category: 技术
tags: [metro, react-native]
excerpt: "RN打包使用的 react-native bundle 命令来自 react-native/local-cli 目录，而实际的打包过程，则是在 metro 模块实现的。这个模块是从0.46版本开始，从RN项目中剥离出来的。我们可以 Fork Github Metro 来改造这个打包模块。"

---
{% include JB/setup %}

RN打包使用的`react-native bundle`命令来自`react-native/local-cli`目录，而实际的打包过程，则是在`metro`模块实现的。这个模块是从0.46版本开始，从RN项目中剥离出来的。我们可以 Fork [Github Metro](https://github.com/facebook/metro)来改造这个打包模块。

### Bundle 分析

首先我们先分析下标准打包的生成文件`JSBundle`。

<img src='{{BASE_PATH}}/assets/images/201803/full_jsb.png'/>

* 头部**polyfills**，为js解释器注入了一些关键字和功能： 最早执行的一些`function`，声明es语法新增的接口，定义模块声明方法`__d`等。

具体参考`metro/src/lib/polyfills/require.js`，如下。

```javascript
global.require = require;
global.__d = define;
// define 的实现
function define(
  factory: FactoryFn,
  moduleId: number,
  dependencyMap?: DependencyMap,
)
    ```

* 模块声明**module definitations(__d)**，都是以`__d`开头，每一行代表一个JS模块的定义。根据上面的`define`定义我们可以知道，每个`__d`有两个重要参数：`方法声明factory`、`模块索引modlueId`。

```
__d(function(t,s,c,e,i){'use strict';c.exports=s(i[0])},12,[13]);
```

其中这个`moduleId`是在打包过程中，根据入口文件进行深度遍历依赖分析，不断递增生成的，具体实现是在`metro/src/lib/createModuleIdFactory.js`文件中：

```javascript
// metro/src/lib/createModuleIdFactory.js
let id = fileToIdMap.get(path);
if (typeof id !== 'number') {
  id = nextId++;
  fileToIdMap.set(path, id);
}
```

* 模块调用**require calls**，位于模块的最后部分：执行`InitializeCore`和入口文件。

```
require(55);
require(11);
```

#### 打包过程分析

我们来看下打包的命令：

```
react-native bundle --entry-file index.js --bundle-output 'dist/main.jsbundle' --platform ios --dev false --assets-dest dist
```

* entry-file：入口文件，打包时从这个文件开始，深度遍历依赖关系，生成模块声明；
* dev：根据bundle的使用环境，判断是否对代码进行压缩；
* bundle-output：打包好的文件输出地址；
* assets-dist：bundle中使用到的静态资源文件存放地址，资源文件的根目录是`assets`。

具体的JSBundle生成流程如下：

<img src='https://ws1.sinaimg.cn/large/c4b5f11bly1flhfzog8brj20ft0dn74s.jpg'/>

> 【注】上图来自：[RN打包那些事儿](https://blog.ymfe.org/RN%E6%89%93%E5%8C%85%E9%82%A3%E4%BA%9B%E4%BA%8B%E5%84%BF/)

### 打包模块的选择和改造

随着项目中RN模块逐渐增多，出于模块隔离、加载优化等多方面考虑，我们对项目的RN环境进行了`Bundle 拆分`+`多 Bridge`的改造。如下图所示：

<img src='{{BASE_PATH}}/assets/images/201803/load_rn.png'/>

> 【注】上图为：Bundle 拆分后加载示意图

首先将一个Bridge的代码加载拆分成两个 Bundle，基础部分的 Bundle 进行多 Bridge 复用，业务部分 Bundle 由 Bridge 动态加载。

<img src='{{BASE_PATH}}/assets/images/201803/multi_bridge.png'/>

> 【注】上图为：多 Bridge 情况下各 Bundle 结构

如果是基于一个JSBundle的项目，`metro-bundler`打包是没有任何问题的。但是按照上面模式来的话，就有问题了：

1. bundle 的拆分。我们需要将`react`和`react-native`等与业务无关的公共基础部分放到基础包中，将独立业务模块中抽离基础包后的部分放到业务包中，以便Bridge动态加载执行。
2. `moduleId`的生成。因为 metro 打包时，会以递增的方式给每个模块分配一个ID，在文件调用时直接调用对应的ID号。在拆分 bundle 后，如果我们的基础包有依赖模块的变动，整个模块调用的ID都会错位。所以要采用更加稳定健壮的ID生成方式。
3. 静态资源的生成。因为打包生成的静态资源根目录是固定的`assets`，为了方便灵活组织资源内容，我们添加对自定义静态资源根目录的功能支持。

	```javascript
	// 结构1，多 bundle 资源最终会合并到一个目录下去，
	// 好处在于资源文件只存在一份拷贝，
	// 缺点在于需要保持多个 bundle 对依赖模块版本保持一致（避免资源修改造成的异常）。
	|- assets/
		|- node_modules/
		|- bundle1_resource/
		|- bundle2_resource/

	// 结构2，能够做到每个 bundle 所依赖内容的独立存在。
	// 举个例子，如果某个 bundle 模块进行优先改版，对依赖模块进行调整，这时候不会影响其他模块使用先前版本。
	|- bundle1/
		|- node_modules/
		|- resource/
	|- bundle2/
		|- node_modules/
		|- resource/
	```

在参考了一些文章后，我们选择基于 [metro-bundler-cli](https://github.com/tsyeyuanfeng/metro-bundler-cli) 和[@tsyeyuanfeng/metro-bundler](https://github.com/tsyeyuanfeng/metro-bundler)来改造打包工具。因为它解决了我们上面提到的第1、2个问题。

#### 解决问题2

针对问题2，它提供了一个`--use-stable-id`参数，支持对文件路径和资源进行MD5，最后生成一个固定不变的ID。

```javascript
if (!fileToIdMap.has(module.path)) {
  fileToIdMap.set(
    module.path,
    crypto.createHash('md5')
          .update(module.localPath)
          .update(module._readSourceCode())
          .digest('hex')
  );
}
```

最终的效果如下：

```javascript
// 采用唯一ID
__d(function(b,e,t,a){var c='object'==typeof b&&b&&b.Object===Object&&b;t.exports=c},"9b4b81fe5a5a9294b480bab022a2852b");
```

#### 解决问题1

对于问题1，它提供了`--manifest-output`和`--exclude`两个参数：

* `--manifest-output`：将生成的 bundle 中每个模块的文件路径及固定ID存到 manifest json 文件中；
* `--exclude`：通过指定 manifest json 文件，在生成 bundle 过程中过滤掉 json 文件中提到的模块。

#### 解决问题3

对于问题3，我们添加了一个`--assetPath`参数，可以指定 bundle 资源文件的根目录名称。

### 命令的使用

至此，打包工具能够满足我们这一期的需求了。改造后的`metro-bundler`可以在[【Github】metro-bundler](https://github.com/BaiShunMobi/metro-bundler)上`baishun`分支找到。

对`metro-bundler-cli`的调整也很简单：

```javascript
// bundleCommandLineArgs.js 在最后添加一条命令即可
{
	command: '--assetPath [string]',
	description: 'start path for asset',
}

// buildBundle.js
const requestOpts: RequestOptions = {
	...
	platform: args.platform,
	useStableId: args.useStableId,
	assetPath: args.assetPath, // 添加这一条
	exclude: args.exclude,
};
```

在项目的工程中添加对`metro-bundler-cli`的依赖，并使用我们的打包模块进行打包即可。

```javascript
"scripts": {
	"start": "node node_modules/metro-bundler-cli/local-cli/cli.js start",
	"bundle": "node node_modules/metro-bundler-cli/local-cli/cli.js bundle",
	"base": "npm run bundle -- --entry-file base.js --bundle-output dist/base.jsbundle --manifest-output dist/base.manifest.json  --platform ios --dev false --use-stable-id true",
	"business": "npm run bundle -- --entry-file index.ios.js --bundle-output dist/business.jsbundle --manifest-output dist/business.manifest.json --assets-dest dist --exclude dist/base.manifest.json --platform ios --dev false --use-stable-id true --assetPath business"
}
```

----
> 参考文章：

* [RN打包那些事儿](https://blog.ymfe.org/RN%E6%89%93%E5%8C%85%E9%82%A3%E4%BA%9B%E4%BA%8B%E5%84%BF/)
* [react-native bundle 解释与拆解](https://4ndroidev.github.io/2017/09/06/react-native-bundle/)
* [【Github】metro-bundler-cli](https://github.com/tsyeyuanfeng/metro-bundler-cli)
* [【Github】@tsyeyuanfeng/metro-bundler](https://github.com/tsyeyuanfeng/metro-bundler)
* [【Github】metro-bundler](https://github.com/BaiShunMobi/metro-bundler) 分支：baishun
