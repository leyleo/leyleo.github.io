---
layout: post
title: "使用SAE开发简易微信墙Demo"
description: "使用SAE开发简易微信墙Demo"
category: 技术
tags: [微信公众号, PHP, SAE]
excerpt: "微信墙是现在线下运营的常见方式之一。线下用户在关注了运营方的微信公众号之后，微信墙可以通过大屏幕同步显示现场观众发送的微信文字或图片信息。既能增加现场观众的互动性参与感，也能为运营方快速增粉。这里我们选择使用新浪云SAE进行微信墙Demo的开发。原因很简单，SAE是国内老字号的PaaS平台，它按需收费，免运维的特点非常适合托管运营类的项目。"

---
{% include JB/setup %}

微信墙是现在线下运营的常见方式之一。线下用户在关注了运营方的微信公众号之后，微信墙可以通过大屏幕同步显示现场观众发送的微信文字或图片信息。既能增加现场观众的互动性参与感，也能为运营方快速增粉。

这里我们选择使用新浪云SAE进行微信墙Demo的开发。原因很简单，SAE是国内老字号的PaaS平台，它按需收费，免运维的特点非常适合托管运营类的项目。

【前提】：

1. 已经有[微信公众平台](https://mp.weixin.qq.com)账号。
2. 已经有[新浪云SAE](http://sae.sina.com.cn)账号。

【章节说明】：

1. 微信公众平台的开发服务器配置及校验
2. 管理订阅用户的信息
3. 处理文字和图片消息
4. 开发上墙前端接口

#### 1. 微信公众平台的开发服务器配置及校验
微信公众平台的后台管理界面能够满足运营童鞋日常发布文章，管理用户及素材等基本需求，但是微信墙的功能需要我们自己进行开发，编写代码。

首先登录微信公众平台官网[http://mp.weixin.qq.com/](http://mp.weixin.qq.com/)，进入公众平台的后台管理界面-》开发基本配置，如下图1-1。

<!-- ![图1]({{BASE_PATH}}/assets/images/201602/docImg/1-1.png =200x200)（图1-1） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/1-1.png" alt="图1" style="width: 200px;"/>（图1-1）

可以看到如图1-2所示界面，点击右侧的“修改配置”。

<!-- ![图2]({{BASE_PATH}}/assets/images/201602/docImg/1-2.png =600x)（图1-2） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/1-2.png" alt="图2" style="width: 600px;"/>（图1-2）

这时候会看到如图1-3的界面，用来配置服务器相关设置。

<!-- ![图3]({{BASE _PATH}}/assets/images/201602/docImg/1-3.png =600x)（图1-3） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/1-3.png" alt="图3" style="width: 600px;"/>（图1-3）

其中的URL(服务器地址)是我们用来接收微信消息和时间的接口URL，Token(令牌)我们可以随意填写，用来生成签名，验证安全性。

参考微信公众平台开发者文档中的[接入指南](http://mp.weixin.qq.com/wiki/8/f9a0b8382e0b77d87b3bcc1ce6fbc104.html#)我们得知，在提交配置信息后，微信的服务器会给我们设置的接口URL发送Token验证，来验证服务器地址的有效性。

所以接下来，我们要在SAE中开发接口URL。

首先登录[http://sinacloud.com](http://sinacloud.com/) -》进入[云应用SAE控制台](http://sae.sina.com.cn/?m=dashboard) -》点击“创建新应用”，如下图1-4。

<!-- ![图4]({{BASE_PATH}}/assets/images/201602/docImg/1-4.png =600x)（图1-4） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/1-4.png" alt="图4" style="width: 600px;"/>（图1-4）

在创建应用的页面输入新应用的二级域名，应用名称及验证码，并选择开发语言为`PHP5.6`的空白模板，点击“创建应用”，如下图1-5，这里我设置的二级域名为“silencecat”。

擅长使用`Python`或者`Java`的童鞋还可以选择对应的开发语言及配置。

<!-- ![图5]({{BASE_PATH}}/assets/images/201602/docImg/1-5.png =600x)（图1-5） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/1-5.png" alt="图5" style="width: 600px;"/>（图1-5）

创建成功后，会自动跳转到SAE控制台的首页，这时候应用列表里就能看到我们创建的这一个应用，如下图1-6。点击应用名称，进入“silencecat”应用的管理界面。

<!-- ![图6]({{BASE_PATH}}/assets/images/201602/docImg/1-6.png =600x)（图1-6） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/1-6.png" alt="图6" style="width: 600px;"/>（图1-6）

总览界面如下图1-7，在这个界面我们可以绑定已有的独立域名，可以看到该应用各种服务的实时分析，请求状况分析和数据分析等。通过成员管理，我们可以邀请小伙伴一起进行协同开发。现在，点击“代码管理”，准备进入写代码的阶段。

<!-- ![图7]({{BASE _PATH}}/assets/images/201602/docImg/1-7.png =600x)（图1-7） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/1-7.png" alt="图7" style="width: 600px;"/>（图1-7）

SAE有两种代码管理工具，Git和SVN。各位童鞋可以根据喜好选择代码工具，具体的使用文档可以参考[代码部署手册](http://www.sinacloud.com/doc/sae/tutorial/code-deploy.html)，不过要注意，一旦选定就不能再更改了。这里我选择SVN，如下图1-8。问我为什么选择SVN？因为SAE提供有SVN的在线代码编辑器，可以直接在浏览器里编辑代码；而且有版本控制功能，我们可以直接在线切换线上版本。😄

<!-- ![图8]({{BASE _PATH}}/assets/images/201602/docImg/1-8.png =600x)（图1-8） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/1-8.png" alt="图8" style="width: 600px;"/>（图1-8）

选定代码管理工具后，就可以开始部署代码了。前面已经提到，SVN有在线编辑器，所以我们有两种方式编辑代码，如下图1-9所示。

<!-- ![图9]({{BASE _PATH}}/assets/images/201602/docImg/1-9.png =600x)（图1-9） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/1-9.png" alt="图9" style="width: 600px;"/>（图1-9）

方法1：直接点击“创建版本”-》输入版本号“1”，版本1创建成功后会如下图1-10所示。这时候版本1默认会有config.yaml和index.php两个示例文件。应用可以通过版本根目录下的config.yaml文件来对Apache服务器做一些配置，详见文档[应用配置](http://www.sinacloud.com/doc/sae/php/runtime.html#ying-yong-pei-zhi)。

通过点击操作栏中的“编辑代码”，就会进入当前应用的在线代码编辑器中。也可以点击“上传代码包”，将本地已有的代码上传到SVN的版本1中，代码会自动解压最外层压缩包。

<!-- ![图10]({{BASE _PATH}}/assets/images/201602/docImg/1-10.png =600x)（图1-10） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/1-10.png" alt="图10" style="width: 600px;"/>（图1-10）

方法2：在本地使用SVN客户端或者命令终端`checkout`出对应应用二级域名的SVN仓库。我的这个应用对应checkout命令为：

```
svn checkout https://svn.sinacloud.com/silencecat
```

这里需要注意的一点是，被设置为**默认版本**的代码，可以直接通过`$应用二级域名.applinzi.com`来访问，而非默认版本的代码，则需要带上版本号，形如`$版本号.$应用二级域名.applinzi.com`来进行访问。

接下来，终于开始写代码了。在版本1的根目录新建一个`wechat`的目录，然后在`wechat/enter.php`文件中添加下面代码：

```
<?php
/*微信公众平台SilenceCat接口*/

define("TOKEN", "silencecat"); // 设置Token(令牌)，与微信公众平台服务器配置处的设置保持一致。

$wechatObj = new WechatCallbackAPI();

/*
当Get请求中包括echostr字段，表示这个请求是为了验证服务器地址的有效性。接口详见 http://mp.weixin.qq.com/wiki/8/f9a0b8382e0b77d87b3bcc1ce6fbc104.html 中的第二步：验证服务器地址的有效性。
*/
if(isset($_GET['echostr'])){
    $wechatObj->valid();
} else {

}

class WechatCallbackAPI
{
    public function valid()
    {
        $echoStr = $_GET["echostr"];

        // valid signature , option
        if($this->checkSignature()){
            echo $echoStr;
            exit;
        }
    }

    /*微信验证签名*/
    private function checkSignature()
    {
        if (!defined("TOKEN")) {
            throw new Exception('TOKEN is not defined!');
        }

        $signature = $_GET["signature"];
        $timestamp = $_GET["timestamp"];
        $nonce = $_GET["nonce"];

        $token = TOKEN;
        $tmpArr = array($token, $timestamp, $nonce);
        // use SORT_STRING rule
        sort($tmpArr, SORT_STRING);
        $tmpStr = implode( $tmpArr );
        $tmpStr = sha1( $tmpStr );

        if( $tmpStr == $signature ){
            return true;
        }else{
            return false;
        }
    }
}
?>
```

将上面代码提交到SVN仓库里，搞定。记得将`TOKEN`换成自己微信公众平台服务器配置中对应的Token串。

接下来返回微信公众平台后台管理页面的开发基本配置-》服务器配置页面，把刚才写好代码的接口地址填入对应的位置，如下图1-11所示。

<!-- ![图11]({{BASE _PATH}}/assets/images/201602/docImg/1-11.png =600x)（图1-11） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/1-11.png" alt="图11" style="width: 600px;"/>（图1-11）

点击“提交”按钮后，如果一切验证正常，会提示“验证成功”，并返回基本配置页面，如下图1-12所示。如果提示“token验证失败”，请检查代码是否有异常，或者URL/token等填写是否正确。

<!-- ![图12]({{BASE _PATH}}/assets/images/201602/docImg/1-12.png =600x)（图1-12） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/1-12.png" alt="图12" style="width: 600px;"/>（图1-12）

这时候服务器配置已经验证成功，但是还没有启用该配置。点击“启用”后，用户发给该公众号的普通消息及事件推送等会被微信服务器转发到刚才设置的接口URL中。如图1-13所示。

<!-- ![图13]({{BASE _PATH}}/assets/images/201602/docImg/1-13.png =600x)（图1-13） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/1-13.png" alt="图13" style="width: 600px;"/>（图1-13）

自此，微信公众平台的开发服务器配置及接口校验模块完成了。

#### 2. 管理订阅用户的信息
上文已经提到，现在用户发给公众号的普通消息还有事件消息是会推送给咱们设置好的URL接口的。这里我们利用用户关注公众号时的**subscribe**事件，将订阅用户的基本信息存入我们微信墙的用户数据表中；当用户取消关注公众号触发了**unsubscribe**事件，将该用户的基本信息从用户数据表中删除。

首先，根据文档[接收事件推送](http://mp.weixin.qq.com/wiki/7/9f89d962eba4c5924ed95b513ba69d9b.html)，查看我们能获取哪些相关参数。

**关注/取消关注事件**的消息参数说明如下：

| 参数 | 描述 |
|-----|------|
|ToUserName|开发者微信号|
|FromUserName|发送方帐号（一个OpenID）|
|CreateTime|	消息创建时间 （整型）|
|MsgType	|消息类型，event|
|Event	|事件类型，subscribe(订阅)、unsubscribe(取消订阅)|

唯一我们能获取的用户相关的信息，就是**FromUserName**参数带来的发送方的账号OpenID，这个ID每个用户在同一个公众号内是固定不变的，我们将使用这个ID来标示每个不同的用户。那么，如何根据用户的OpenID获取基本信息呢？这就用到了另外一个接口：[获取用户基本信息](http://mp.weixin.qq.com/wiki/1/8a5ce6257f1d3b2afb20f83e72b72ce9.html)。

接下来，我们一起看看这个[获取用户基本信息](http://mp.weixin.qq.com/wiki/1/8a5ce6257f1d3b2afb20f83e72b72ce9.html)的接口该怎么使用。

请求方式：

```
http GET
https://api.weixin.qq.com/cgi-bin/user/info?access_token=ACCESS_TOKEN&openid=OPENID&lang=zh_CN
```
调用参数说明：

|参数|是否必须|说明|
|----|-----|----|
|access_token|是|调用接口凭证|
|openid|是|普通用户的标识，对当前公众号唯一|
|lang|否	|返回国家地区语言版本，zh_CN 简体，zh_TW 繁体，en 英语|

返回参数说明：

|参数|说明|
|---|---|
|subscribe|用户是否订阅该公众号标识，值为0时，代表此用户没有关注该公众号，拉取不到其余信息。|
|openid|用户的标识，对当前公众号唯一|
|nickname|用户的昵称|
|headimgurl|用户头像，最后一个数值代表正方形头像大小（有0、46、64、96、132数值可选，0代表640*640正方形头像），用户没有头像时该项为空。若用户更换头像，原有头像URL将失效。|
|...|...|

微信墙上需要的用户信息来源找到了，但另一个问题冒出来了：这个请求时必须的`access_token`是个什么鬼？

文档[获取接口调用凭据](http://mp.weixin.qq.com/wiki/14/9f9c82c1af308e3b14ba9b973f99a8ba.html)里详细介绍了access_token的使用说明和获取方法：
> access_token是公众号的全局唯一票据，公众号调用各接口时都需使用access_token。开发者需要进行妥善保存。access_token的存储至少要保留512个字符空间。access_token的有效期目前为2个小时，需定时刷新，重复获取将导致上次获取的access_token失效。

请求方法：

```
http请求方式: GET
https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=APPID&secret=APPSECRET
```

好了，到现在为止，跟用户信息相关的接口都找到了。让我们重新捋一捋：

首先，要获取到accessToken。由于它的有效期目前为2小时，需要定时刷新，我决定把它存到Memcache中，设置cron每两小时更新一次。

然后，在用户订阅公众号的时候，拿着获取到的用户OpenID，去请求用户基本信息，然后把得到的有效信息，写入到MySQL的用户信息表中。

恩，归置清楚了，下面我们就开始写代码了。打开[SAE控制台](http://sae.sina.com.cn/)，进入先前创建的应用`silencecat`管理界面。

##### Step1. 初始化MC

Memcache是SAE为开发者提供的分布式内存缓存服务，用来以共享的方式缓存用户的小数据，非常适合accessToken的使用场景。具体可以参考[MC文档](http://www.sinacloud.com/doc/sae/php/memcache.html)。从左边**存储与CDN服务**一栏下面找到**Memcache**，进入MC的管理页面，点击“初始化Memcache”。如图2-1所示。

<!-- ![图2-1]({{BASE _PATH}}/assets/images/201602/docImg/2-1.png =600x)（图2-1） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/2-1.png" alt="图2-1" style="width: 600px;"/>（图2-1）

这时候会弹出来一个对话框，用来初始设置MC容量大小，如图2-2所示。我们选择最小的16MB就够用了。设置成功后还可以随时调整容量大小。

<!-- ![图2-2]({{BASE _PATH}}/assets/images/201602/docImg/2-2.png =400x)（图2-2） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/2-2.png" alt="图2-2" style="width: 400px;"/>（图2-2）

##### Step2. 获取Access Token并存储

在应用代码的`wechat`目录下新建一个`updateToken.php`文件，首先添加请求逻辑，如下：

```
$url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=$APPID&secret=$APPSecret";

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$output = curl_exec($ch);
curl_close($ch);
$jsoninfo = json_decode($output, true);
$access_token = $jsoninfo["access_token"];
$errcode = $jsoninfo["errcode"];

if ($errcode) {
	// 出错了
	echo $output;
} else if ($access_token) {
	// 获得token了，存入MC中
	$expiresIn = intval($jsoninfo["expires_in"]);
	updateTokenToMC($access_token,$expiresIn);
} else {
	echo "curl error";
}
```

其中的`$APPID`和`$APPSECRET`来自于微信公众平台后台管理-》开发基本配置，如图2-3所示。

<!-- ![图2-3]({{BASE _PATH}}/assets/images/201602/docImg/2-3.png =500x)（图2-3） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/2-3.png" alt="图2-3" style="width: 500px;"/>（图2-3）

当获取access token成功，则将获得的access token及过期时间写入到MC中。

```
function updateTokenToMC($token, $expiresIn) {
	$mmc = new Memcache; // 初始化MC

	$ret = $mmc->connect(); // 连接当前应用的MC服务器
	if ($ret == false) {
	    echo "mc init failed\n";
	} else {
	    $result = $mmc->set("accessToken", $token, 0, $expiresIn); // 存储accessToken到MC，写入MC的有效期为$expiresIn
	    $resultStr = $result==true ?" success":" failed";
	    echo "set: ".$mmc->get("accessToken").$resultStr;
	}
}
```

将代码提交到SVN，这时候直接在浏览器中访问`http://silencecat.applinzi.com/wechat/updateToken.php`，会显示出：

```
set: sHIoheYQvvwStTa5f7NkrKwn79LwKNQXvl3RFXiACwh3Pk5UN9E6PeqeYoYmGfnvtWbVomRWmTpKs8wn5Ese2XXxgze53lfyp3p3c21b-nEKDSdAAAPIX success
```

打开代码文件`wechat/enter.php`，在`WechatCallbackAPI`类中添加方法`getAccessToken`，为接下来各个需要access token的微信接口服务。

```
/*获取当前的access token*/
private function getAccessToken()
{
    $mmc = new Memcache;

    $ret = $mmc->connect();
    if ($ret == false) {
        return NULL;
    } else {
        $result = $mmc->get("accessToken");
        return $result;
    }
}
```

##### Step3. 添加cron定时更新token
Cron服务是SAE为开发者提供的分布式计划任务服务，用来定时触发开发者的特定动作，它的执行是以HTTP方式触发的，触发后真正执行的是用户在应用的HTTP回调函数。详细文档参考[Cron](http://www.sinacloud.com/doc/sae/php/cron.html#cron)。

介绍完毕，回到咱们的代码上来。编辑**版本1**根目录下的`config.yaml`文件，没有的话新建一个，增加Cron字段，如下：

```
name: silencecat
version: 1
cron:
	- description: update token
	  url: /wechat/updateToken.php
	  schedule: every 110 mins
```

**url** 为咱们要定时更新token的`updateToken.php`;

**schedule** 这里我设定每隔110分钟执行一次这个cron任务，也就是每隔110分钟更新一次微信的access token.

将代码提交到SVN仓库后，进入SAE控制台`silencecat`管理界面，从左边**应用程序服务**一栏下面找到**Cron**服务菜单，点击进入，会看到刚才设置的Cron已经添加到Cron列表中，如下图2-4。

<!-- ![图2-4]({{BASE _PATH}}/assets/images/201602/docImg/2-4.png =600x)（图2-4） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/2-4.png" alt="图2-4" style="width: 600px;"/>（图2-4）

如果Cron任务有执行，会在此处看到上次的执行时间及执行状态，如图2-5。

<!-- ![图2-5]({{BASE _PATH}}/assets/images/201602/docImg/2-5.png =600x)（图2-5） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/2-5.png" alt="图2-5" style="width: 600px;"/>（图2-5）

##### Step4. 处理订阅/取消订阅事件
打开代码目录`wechat/enter.php`文件，在`WechatCallbackAPI`类中添加对消息进行处理的模块`responseMsg`。其中`$fromUsername`记录了微信用户的OpenID，而当`$originMsgType`为`event`时，表示当前为事件消息，这时候用`$event`记录下事件的具体类型，并调用方法`processEvent`进行处理。

```
/*对收到的消息进行处理*/
public function responseMsg()
{
    $postStr = $GLOBALS["HTTP_RAW_POST_DATA"];
    if (!empty($postStr)){
        libxml_disable_entity_loader(true);
        $postObj = simplexml_load_string($postStr, 'SimpleXMLElement', LIBXML_NOCDATA);
        $fromUsername = $postObj->FromUserName; // 发送方账号OpenID
        $toUsername = $postObj->ToUserName; // 开发者微信号
        $originMsgType = $postObj->MsgType; // 消息类型
        $originTime = $postObj->CreateTime; // 消息创建时间
        if ( $originMsgType == 'event' ){ // 消息类型为event(事件)
            $event = $postObj->Event; // subscribe和unsubscribe
            $this->processEvent($fromUsername, $toUsername, $originTime, $event);
        }
    } else {
        echo "empty post string";
        exit;
    }
}
```

在`processEvent`方法中，我们将**subscribe**事件的用户基本信息存入数据库，将**unsubscribe**事件的用户信息从数据库中删除。

```
/*处理事件*/
public function processEvent($fromUsername, $toUsername, $originTime, $event)
{
    if ($event == 'subscribe') {
        // 订阅，获取用户基本信息，写入数据库
        $this->saveProfileToSQL($fromUsername, $originTime);
        // TODO: 向用户发送订阅成功的欢迎语
    } else if ($event == 'unsubscribe') {
        // 取消订阅，将用户信息从数据库中删除
        $this->removeProfileFromSQL($fromUsername);
    }
}
```

记得不要忘了添加对`responseMsg`的入口。

```
if(isset($_GET['echostr'])){
    $wechatObj->valid();
} else {
    $wechatObj->responseMsg(); // 对收到的消息进行处理
}

```

##### Step5. 初始设置MySQL

为了存储用户信息，我们首先使用MySQL服务创建一张用户信息表。

SAE有两种MySQL类型数据库服务：独享型MySQL([详见文档](http://www.sinacloud.com/doc/sae/php/rds.html))和共享型MySQL([详见文档](http://www.sinacloud.com/doc/sae/php/mysql.html))。独享型MySQL是采用了Container技术对用户进行隔离，保证用户之间的业务不互相影响，功能丰富，使用方便，为保证最优性能，MySQL专门对InnoDB引擎进行了优化。共享型MySQL使用RDC（Relational Database Cluster）进行用户隔离，RDC对不同等级的用户有一个配额，从而保证用户之间的业务不互相影响，共享型MySQL性价比高，支持主从分离，且支持MyISAM和InnoDB两种引擎。这里我选择性价比高的共享型MySQL。

进入SAE控制台`silencecat`管理界面，从左边**数据库服务**一栏下面找到**共享型MySQL**服务菜单，点击进入，初始化MySQL，如图2-6。

<!-- ![图2-6]({{BASE _PATH}}/assets/images/201602/docImg/2-6.png =600x)（图2-6） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/2-6.png" alt="图2-6" style="width: 600px;"/>（图2-6）

初始化完成后，就进入了MySQL的操作界面，如图2-7。点击“管理MySQL”，进入到PHPMyAdmin后台页面。

<!-- ![图2-7]({{BASE _PATH}}/assets/images/201602/docImg/2-7.png =600x)（图2-7） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/2-7.png" alt="图2-7" style="width: 600px;"/>（图2-7）

创建如下一张表，用来存储我们的用户信息，如下图2-8所示。`userId`用来存储用户的**OpenID**，`nickName`存储用户的昵称，`headimgurl`存储用户的头像URL，`subscribe_time`存储用户订阅微信号的时间。

<!-- ![图2-8]({{BASE _PATH}}/assets/images/201602/docImg/2-8.png =600x)（图2-8） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/2-8.png" alt="图2-8" style="width: 600px;"/>（图2-8）

##### Step6. 将用户信息保存到数据库中

回到代码目录，继续编辑`wechat/enter.php`。

在方法`saveProfileToSQL`中，我们首先获取access token。然后带着`userId`去请求用户接口，获得用户基本信息，这里我们只需要用户昵称，头像及订阅时间。最后把这些信息存入到数据库的`userInfo`表中。

```
/*将个人资料保存到SQL中*/
private function saveProfileToSQL($userId)
{
    // 1. 获取access token
    $accessToken = $this->getAccessToken();
    if (!$accessToken) {
        return "no access token";
    }

    // 2. 请求用户接口，获取$userId对应用户信息
    $url = "https://api.weixin.qq.com/cgi-bin/user/info?access_token=$accessToken&openid=$userId&lang=zh_CN";

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    $output = curl_exec($ch);
    curl_close($ch);
    $userInfoJson = json_decode($output, true);

    $nickName = $userInfoJson["nickname"]; //
    $headimgurl = $userInfoJson['headimgurl'];
    $subtime = $userInfoJson['subscribe_time'];
    $subscribe_time = date("Y-m-d H:i:s", intval($subtime));

    // 3. 存入数据库
    $mySQL = new SaeMysql(); // 初始化MySQL
    $sql = "INSERT IGNORE INTO `userInfo`( `userId`,`nickName`,`headimgurl`,`subscribe_time`)
    VALUES ('$userId','$nickName','$headimgurl','$subscribe_time') ";
    $mySQL->runSql($sql); // 执行SQL语句
    if($mySQL->errno()!=0)
    {
       $content = "error: ".$mySQL->errmsg();
    }
    $mySQL->closeDb();
    return $content;
}
```

相应地，我们还需要添加删除用户信息的操作。

```
/*将个人资料从SQL中删除*/
private function removeProfileFromSQL($userId)
{
    $mySQL = new SaeMysql();
    $sql = "DELETE FROM `userInfo` WHERE `userId`='$userId' ";
    $mySQL->runSql($sql);
    if($mySQL->errno()!=0)
    {
       $content = "error: ".$mySQL->errmsg();
    }
    $mySQL->closeDb();
    return $content;
}
```

#### 3. 处理文字和图片消息
接下来就该处理用户发送来的文字和图片了。我们先在MySQL数据库中创建一张微信消息的表。查看微信公众平台的文档[接收普通消息](http://mp.weixin.qq.com/wiki/17/f298879f8fb29ab98b2f2971d42552fd.html)，文本消息的参数如下，`MsgType`为**text**，`Content`为文本消息内容：

|参数|描述|
|--|--|
|ToUserName|开发者微信号|
|FromUserName|发送方帐号（一个OpenID）|
|CreateTime|消息创建时间 （整型）|
|MsgType|text|
|Content|文本消息内容|
|MsgId|消息id，64位整型|

图片消息的参数类似，`MsgType`为**image**，`PicUrl`为图片在微信服务器上的URL地址，`MediaId`为媒体资源在微信服务器的ID：

|参数|描述|
|--|--|
|MsgType|image|
|PicUrl|图片链接|
|MediaId|图片消息媒体id，可以调用多媒体文件下载接口拉取数据。|

所以，再次进入SAE控制台silencecat管理界面，进入PHPMyAdmin后台页面，创建`userMessage`表，来存储公众号收到的微信文字和图片消息，如图3-1。`userId`用来存储发送者的OpenId，`createTime`存储消息发送时间，`messageType`存储消息的类型，当消息类型为**text**文本时，`content`存储文本消息的内容，当消息类型为**image**图片时，`mediaId`存储图片资源的媒体ID。

<!-- ![图3-1]({{BASE _PATH}}/assets/images/201602/docImg/3-1.png =600x)（图3-1） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/3-1.png" alt="图3-1" style="width: 600px;"/>（图3-1）

##### 处理文字消息

回到代码目录，继续编辑`wechat/enter.php`文件。首先在`responseMsg`方法中添加对**text**消息的处理，具体实现跳转到`processTextContent`方法。

```
/*对收到的消息进行处理*/
public function responseMsg()
{
    $postStr = $GLOBALS["HTTP_RAW_POST_DATA"];
    if (!empty($postStr)){
        ...
        $postObj = simplexml_load_string($postStr, 'SimpleXMLElement', LIBXML_NOCDATA);
        $fromUsername = $postObj->FromUserName; // 发送方账号OpenID
        $toUsername = $postObj->ToUserName; // 开发者微信号
        $originMsgType = $postObj->MsgType; // 消息类型
        $originTime = $postObj->CreateTime; // 消息创建时间
        if ( $originMsgType == 'event' ){ // 事件消息
            ...
        } else if ( $originMsgType == 'text' ){ // 文字消息
            $content = trim($postObj->Content);
            $this->processTextContent($fromUsername, $toUsername, $originMsgType, $content, $originTime);
        }
    } else {
        ...
    }
}
```

在`processTextContent`方法中，我们先将文本消息的内容保存到MySQL的`userMessage`表中，然后给用户反馈是否上墙成功。

```
/*处理文字信息*/
public function processTextContent($fromUsername, $toUsername, $originMsgType, $content, $originTime)
{
    $result = $this->putIntoSQL($fromUsername, $originMsgType, $content, $originTime, NULL); // 将文本消息的内容保存到数据库
    $returnText = $this->processSQLResult($result); // 处理反馈文案
    $this->responseForType($fromUsername, $toUsername, $returnText, $originTime); // 给用户发送反馈信息
}

/*将下列信息存入MySQL数据库中。如果写入失败，则返回错误信息。写入成功，返回NULL*/
public function putIntoSQL($fromUsername, $originMsgType, $content, $originTime, $mediaId)
{
    ... // 略
}

/*处理数据写入SQL后的结果*/
private function processSQLResult($result)
{
    $returnText = "消息发送成功，正在努力爬墙...";
    if($result != NULL){
        $returnText = $result;
    }
    return $returnText;
}
```

对于成功写入数据库的信息，我们准备给用户返回“消息发送成功，正在努力爬墙...”的提示，如果写入失败，显示错误信息。那么如何给微信用户回复消息呢？查看微信文档[被动回复用户消息](http://mp.weixin.qq.com/wiki/1/6239b44c206cab9145b1d52c67e6c551.html)知道，我们可以在收到用户发给公众号的消息5秒钟内，给用户返回固定格式的XML结构作为响应。其中我们需要的**回复文本消息**的格式为：

```
<xml>
<ToUserName><![CDATA[接收用户的OpenId]]></ToUserName>
<FromUserName><![CDATA[发送公众号的Id]]></FromUserName>
<CreateTime>消息创建时间（整型）</CreateTime>
<MsgType><![CDATA[text]]></MsgType>
<Content><![CDATA[回复的文本内容]]></Content>
</xml>
```

所以，我们在`responseForType`方法中，将要回复的相关信息拼接起来。

```
/*回复收到的消息*/
public function responseForType($fromUsername, $toUsername, $content, $originTime)
{
    $textTpl = "<xml>
                <ToUserName><![CDATA[%s]]></ToUserName>
                <FromUserName><![CDATA[%s]]></FromUserName>
                <CreateTime>%s</CreateTime>
                <MsgType><![CDATA[text]]></MsgType>
                <Content><![CDATA[%s]]></Content>
                </xml>";
    if(!empty( $content ))
    {
        $msgType = "text";
        $time = time();
        $contentStr = $content;
        $resultStr = sprintf($textTpl, $fromUsername, $toUsername, $time, $contentStr);
        echo $resultStr;
    }else{
        echo "暂时无法处理";
    }
}
```

将代码提交到SVN，然后给公众号发送信息，就能收到正确的响应了。如下图3-2所示。

<!-- ![图3-2]({{BASE _PATH}}/assets/images/201602/docImg/3-2.png =300x)（图3-2） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/3-2.png" alt="图3-2" style="width: 300px;"/>（图3-2）

##### 处理图片消息
与处理文字信息类似，首先在`responseMsg`方法中添加对**image**消息的处理，具体实现跳转到`processImageContent`方法。

```
/*对收到的消息进行处理*/
public function responseMsg()
{
    ...
    if (!empty($postStr)){
        ...
        if ( $originMsgType == 'event' ){ // 消息类型为event(事件)
            ...
        } else if ( $originMsgType == 'text' ){ // 文字消息
            ...
        } else if ( $originMsgType == 'image' ){ // 图片信息
            $mediaId = $postObj->MediaId;
            $this->processImageContent($fromUsername, $toUsername, $originMsgType, $mediaId, $originTime);
        }
    } else {
        ...
    }
}
```

由于微信用户发送到公众号的媒体资源属于临时素材，微信服务器会在3天后自动删除，我们想要长时间使用或者在自己的网站中使用这些资源，需要通过[获取临时素材](http://mp.weixin.qq.com/wiki/9/677a85e3f3849af35de54bb5516c2521.html)接口将它保存到本地来。

**获取临时素材**的请求接口需要带两个参数，即`access_token`和`media_id`：

```
http请求方式: GET,https调用
https://api.weixin.qq.com/cgi-bin/media/get?access_token=ACCESS_TOKEN&media_id=MEDIA_ID
```

这里需要注意的是，从微信公众平台后台管理的**开发接口权限**页面可以查看到当前的公众号是否有使用**获取临时素材**接口的权限，如图3-3。[获取临时素材](http://mp.weixin.qq.com/wiki/9/677a85e3f3849af35de54bb5516c2521.html)接口的调用需要**通过微信认证**才行，否则没有使用权限。

<!-- ![图3-3]({{BASE _PATH}}/assets/images/201602/docImg/3-3.png =600x)（图3-3） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/3-3.png" alt="图3-3" style="width: 600px;"/>（图3-3）

【备注说明】：接下来对图片消息的处理，是基于**已通过微信认证**来讲的。如果没有进行认证或者无法进行认证，但是又希望能跟着本教程继续学习的，可以通过微信公众平台后台管理的**开发者工具**页面，进入**公众平台测试账号**页面进行设置，如下图3-4所示。通过测试账号可以体验到微信公众平台的所有高级接口，具体设置略过。

<!-- ![图3-4]({{BASE _PATH}}/assets/images/201602/docImg/3-4.png =600x)（图3-4） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/3-4.png" alt="图3-4" style="width: 600px;"/>（图3-4）

现在回到咱们的代码上来。根据上面的介绍，我们在处理图片信息时，需要将图片资源存储到服务器上去。

```
/*处理图片信息*/
public function processImageContent($fromUsername, $toUsername, $originMsgType, $mediaId, $originTime)
{
    $result = $this->putIntoSQL($fromUsername, $originMsgType, NULL, $originTime, $mediaId); // 将图片消息的内容保存到数据库
    $returnText = $this->processSQLResult($result); // 处理反馈文案
    $saveToStor = $this->storeMediaToServer($mediaId); // 将媒体文件存到服务器中
    $this->responseForType($fromUsername, $toUsername, $returnText, $originTime); // 给用户发送反馈信息
}
```

我们接下来使用SAE的[Storage服务](http://www.sinacloud.com/doc/sae/php/storage.html#storage)来保存上述微信图片资源。它是SAE为开发者提供的分布式对象存储服务，可以支持文本、多媒体、二进制等任何类型数据的存储。另外，我们还可以使用[新浪云存储SCS](http://www.sinacloud.com/doc/scs/guide)来存储Object资源，作为专业的云存储服务，它在权限控制、安全和灵活性，及资源优化、CDN分发等方面比**Storage**有更大优势。

进入SAE控制台silencecat管理界面，从左边**存储与CDN服务**一栏下面找到**Storage**服务，在服务首页点击“新建Bucket”，如下图3-5所示。**Bucket**是一个容器，可以看做是一个应用内全局唯一的命名空间。我们上传的任何数据都需要隶属于某个Bucket。

<!-- ![图3-5]({{BASE _PATH}}/assets/images/201602/docImg/3-5.png =600x)（图3-5） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/3-5.png" alt="图3-5" style="width: 600px;"/>（图3-5）

在**创建Bucket**页面，如下图3-6，我们设置buckt名称为“wechat”，并设置10小时的缓期过期时间。如果有防止盗链的需求，可以开启**防盗链**功能，并添加允许访问的域名白名单。

<!-- ![图3-6]({{BASE _PATH}}/assets/images/201602/docImg/3-6.png =400x)（图3-6） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/3-6.png" alt="图3-6" style="width: 400px;"/>（图3-6）

创建成功后，进入**Bucket管理**选项卡页面，我们就能看到新创建的“wechat”Bucket及其状态。

<!-- ![图3-7]({{BASE _PATH}}/assets/images/201602/docImg/3-7.png =600x)（图3-7） -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/3-7.png" alt="图3-7" style="width: 600px;"/>（图3-7）

继续编辑`wechat/enter.php`，在`WechatCallbackAPI`类中实现方法`storeMediaToServer`，完成从[获取临时素材](http://mp.weixin.qq.com/wiki/9/677a85e3f3849af35de54bb5516c2521.html)接口将对应图片资源存入[SAE Storage](http://www.sinacloud.com/doc/sae/php/storage.html#storage)的功能。

这里使用到了Storage的`putObject`方法。Storage的PHP API文档详见[Class Storage](http://apidoc.sinaapp.com/class-sinacloud.sae.Storage.html).

```
/*
$input: Input data
$bucket: Bucket name
$uri: Object URI
$metaHeaders: x-sws-object-meta-* header数组
$requestHeaders: Array of request headers or content type as a string
*/
public static boolean putObject( mixed $input, string $bucket, string $uri, array $metaHeaders = array(), array $requestHeaders = array() )
```

`storeMediaToServer`方法的具体实现如下，资源文件以`$mediaId`为文件名存入Storage中，并保留资源原有的文件类型：

```
/*将媒体资源保存到storage中*/
private function storeMediaToServer($mediaId)
{
    // 获取当前的access token
    $accessToken = $this->getAccessToken();
    if (!$accessToken) {
        return "无法保存图片：no access token";
    }

    // 下载临时素材$mediaId
    $url = "https://api.weixin.qq.com/cgi-bin/media/get?access_token=$accessToken&media_id=$mediaId";
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    $output = curl_exec($ch);
    $info = curl_getinfo($ch);
    curl_close($ch);

    // 将资源存储到Storage中
    $stor = new \sinacloud\sae\Storage();
    $result = $stor->putObject($output, "wechat", $mediaId, array(), array('Content-Type' => $info['content_type']));

    if ($result == true) {
        return NULL;
    } else {
        return "无法保存图片";
    }
}
```
到此处，咱们的微信图片信息已经能保存下来了。

#### 4. 开发上墙前端接口
我们简单实现一个获取最新若干条微信上墙信息的后端接口，用于前端页面定时刷新使用。

首先新建一个`wechat/getList.php`文件，从`userMessage`表中取出最新的`$count`条，并取出对应的用户基本信息。

```
function getLatestList($count)
{
	$mySQL = new SaeMysql();
    $sql = "SELECT m.* , u.nickName, u.headimgurl FROM userMessage m, userInfo u WHERE m.userId = u.userId ORDER BY m.msgId DESC LIMIT $count";
    $result = $mySQL->getData($sql);
    $mySQL->closeDb();
    return $result;
}
```

将获得的数组转换成JSON串，输出后发现一个问题，咱们的资源文件只有一个`$mediaId`，怎么知道文件在Storage中的URL呢？逻辑如下：
> 如果应用名为`myapp`的应用创建了一个`mybucket`的**bucket**，**bucket**里存了一个名为`path/to/my/file.txt`的对象文件，这可以通过以下路径来访问这个资源：

> http://`myapp`-`mybucket`.stor.sinaapp.com`/path/to/my/file.txt`

所以，我们的图片URL可以拼接为：

```
http://silencecat-wechat.stor.sinaapp.com/图片的mediaId
```

于是我们将微信上墙消息进一步处理为：如果消息的`messageType`为`image`，那么返回的`content`字段显示为图片的URL地址，如果消息的`messageType`为`text`，则保持不变。

```
function processedResult($result){
	foreach ($result as &$item) {
		if ($item['messageType'] == 'image') {
			$item['content'] = 'http://silencecat-wechat.stor.sinaapp.com/'.$item['mediaId'];
		}
	}
	return $result;
}
```

最后，将接口包装一下：

```
$listCount = $_GET['count'];
if (!$listCount) {
	$listCount = 10;
}

$result = getLatestList($listCount);
header("content-type:application/json");
header("charset=utf-8");

if ($result == false) {
	echo "{error:10001, message:'sql error'}";
} else {
	$json = json_encode(processedResult($result));
	echo $json;
}
```

这时候访问http://silencecat.applinzi.com/wechat/getList.php就能获取最新的10条消息了。如图4-1所示。

<!-- ![图4-1]({{BASE _PATH}}/assets/images/201602/docImg/4-1.png =500x) -->
<img src="{{BASE_PATH}}/assets/images/201602/docImg/4-1.png" alt="图4-1" style="width: 500px;"/>（图4-1）

接下来自然是做一个酷炫的前端上墙页面了，这里略过。

到此，如何使用SAE开发一个简易的微信上墙应用就介绍完了。希望能对不太了解SAE开发或者不太了解微信公众平台开发的童鞋有所帮助。
