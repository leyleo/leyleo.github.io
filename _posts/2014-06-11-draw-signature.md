---
layout: post
title: "签名绘制算法"
description: "使用Bezier曲线绘制签名"
category: 技术
tags: [Bezier, 算法]
excerpt: "以前在绘制曲线的时候只是用Bezier或者Curve把所有的点平滑起来，并没有对笔触感有任何思考，直到看到在iOS上捕捉签这篇文章，译自Capture a Signature on iOS."

---
{% include JB/setup %}

以前在绘制曲线的时候只是用Bezier或者Curve把所有的点平滑起来，并没有对笔触感有任何思考，直到看到[在iOS上捕捉签名](https://github.com/nixzhu/dev-blog/blob/master/2014-05-27-capture-a-signature-on-ios.md)这篇文章，译自[Capture a Signature on iOS](https://www.altamiracorp.com/blog/employee-posts/capture-a-signature-on-ios)。另外还有两篇Square工程师关于在Android平台上绘制签名的文章[Smooth Signature](http://corner.squareup.com/2010/07/smooth-signatures.html)和[Smoother Signatures](http://corner.squareup.com/2012/07/smoother-signatures.html)值得推荐阅读。看完上面几篇，基本上就明白签名绘制的所有门道了。

这里略去bezier曲线等相关的介绍，主要总结下自然笔触模拟的逻辑。算法原理就是根据笔触的位移速度来控制该段曲线的线宽。速度越快，线越细。上面提到的两篇文章对可变线宽Bezier曲线的具体实现有所不同。

[Smoother Signatures](http://corner.squareup.com/2012/07/smoother-signatures.html)通过分段绘制不同线宽的Bezier曲线来得到最终的完整签名图像：

```
/** Draws a variable-width Bezier curve. */
public void draw(Canvas canvas, Paint paint, float startWidth, float endWidth) {
  float originalWidth = paint.getStrokeWidth();
  float widthDelta = endWidth - startWidth;

  for (int i = 0; i < drawSteps; i++) {
    // Calculate the Bezier (x, y) coordinate for this step.
    float t = ((float) i) / drawSteps;
    float tt = t * t;
    float ttt = tt * t;
    float u = 1 - t;
    float uu = u * u;
    float uuu = uu * u;

    float x = uuu * startPoint.x;
    x += 3 * uu * t * control1.x;
    x += 3 * u * tt * control2.x;
    x += ttt * endPoint.x;

    float y = uuu * startPoint.y;
    y += 3 * uu * t * control1.y;
    y += 3 * u * tt * control2.y;
    y += ttt * endPoint.y;

    // Set the incremental stroke width and draw.
    paint.setStrokeWidth(startWidth + ttt * widthDelta);
    canvas.drawPoint(x, y, paint);
  }

  paint.setStrokeWidth(originalWidth);
}
```

而[Capture a Signature on iOS](https://www.altamiracorp.com/blog/employee-posts/capture-a-signature-on-ios)通过用OpenGL ES的两个三角面片来得到每段的曲线（更新：该链接已经失效）。代码见Github: [PPSSignatureView](https://github.com/jharwig/PPSSignatureView).
