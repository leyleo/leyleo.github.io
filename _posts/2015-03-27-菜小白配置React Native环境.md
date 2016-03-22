---
layout: post
title: "菜小白配置React Native环境"
description: "Mac环境配置React Native开发环境"
category: 技术
tags: [shell, react-native]
excerpt: "Step1. 安装node.js; Step2. 安装autoconf; Step3. 安装automake; Step4. 安装watchman; Step5. 安装react-native-cli; Step6. 创建项目."

---
{% include JB/setup %}

Step1. 安装node.js

略

Step2. 安装autoconf:

```
curl -O http://mirrors.kernel.org/gnu/autoconf/autoconf-2.69.tar.gz
tar xzvf autoconf-2.69.tar.gz
cd autoconf-2.69
./configure -prefix=/usr/local
make
sudo make install
```

Step3. 安装automake:

```
curl -O http://mirrors.kernel.org/gnu/automake/automake-1.15.tar.gz
tar xzvf automake-1.15.tar.gz
cd automake-1.15
./configure --prefix=/usr/local
make
sudo make install
```

Step4. 安装watchman:

```
git clone https://github.com/facebook/watchman.git
cd watchman
./autogen.sh
./configure --prefix=/usr/local
make
sudo make install
```

Step5. 安装react-native-cli:

```
npm install -g react-native-cli
```

Step6. 创建项目:

```
react-native init myProject
```
