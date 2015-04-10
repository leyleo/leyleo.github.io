---
layout: post
title: "深入学习滚动视图"
description: "objc.io issue-3 深入学习滚动视图"
category: 技术
tags: [iOS, Views, 译文, objc.io]
excerpt: "这篇文章从UIView的绘制原理，讲到UIScrollView之所以能滚动的原因。深入浅出地讲述了 bounds, frame, content size, content offset, content inset 等多个属性值的意义。<br/>希望对你能有所帮助。"

---
{% include JB/setup %}

写在前面：这一系列文章来自[objc.io](http://www.objc.io/) [Understanding Scroll Views](http://www.objc.io/issue-3/scroll-view.html)。作者：[Joe Conway](http://stablekernel.com/)

翻译的目的是为了自己加深理解，水平有限，欢迎指正。(左侧是原文，右侧是译文)

----
Source | 译文
------ | ---
It may be hard to believe, but a UIScrollView isn’t much different than a standard UIView. Sure, the scroll view has a few more methods, but those methods are really just facades of existing UIView properties. Thus, most of the understanding of how a UIScrollView works comes from understanding UIView - specifically, the details of the two-step view rendering process. | 令人难以置信，**[UIScrollView](http://developer.apple.com/library/ios/#documentation/uikit/reference/UIScrollView_Class/Reference/UIScrollView.html)**并不比**[UIView](http://developer.apple.com/library/ios/#documentation/UIKit/Reference/UIView_Class/)**复杂多少。当然，滚动视图的确多了一些方法，但那些方法不过是对**UIView**类已有属性进行的包装。因此，对**UIScrollView**运行原理的理解要从对**UIView**的剖析开始，尤其是，两步法视图渲染处理的细节。
<!--more-->
##Rasterization & Composition
Source | 译文
------ | ---
The first part of the rendering process is known as rasterization. Rasterization simply means to take a set of drawing instructions and produce an image. UIButtons, for example, draw an image with a rounded rectangle and a title in the center. These images aren’t drawn to the screen; instead, they are held onto by their view to be used during the next step. | 渲染处理的第一步就是**_光栅化（rasterization）_**。光栅化简单来说就是执行一系列绘制指令，生成一副图像（image）。举个栗子，**UIButton**就是绘制一个标题居中显示的圆角矩形的图像。这些图像并不直接绘制到屏幕上，而是被它们的视图所保存，用以在下一步处理中使用。
Once each view has its rasterized image, these images are drawn on top of each other to produce one screen-sized image in a step called composition. The view hierarchy plays a big role in how composition occurs: a view’s image is composited on top of its superview’s image. Then, that composited image is composited on top of the super-superview’s image, and so on. The view at the top of the hierarchy is the window and its composited image (which is a composite of every image in the view hierarchy) is what the user sees. | 一旦每个视图都有了自己的栅格化图像，这些图像就会被绘制到其他视图的顶层，以生成一个屏幕大小的图像，这一步被称为**_合成(composition)_**。视图的层级决定了如何来进行合成：一个视图的图像被合成到其父视图（superview）的顶层。然后，那个合成后的图像被合成到上上级父视图（super-superview）中，以此类推。处于视图顶层逻辑的是窗口（window），窗口合成的图像（也就是视图层级中每一图像所最终合成的那张图像）就是我们用户所能看到的。
Conceptually, this idea of layering independent images on top of each other to produce a final, flat image should make sense, especially if you have used a tool like Photoshop before. We also have another article in this issue explaining in detail how pixels get onto the screen. | 理论上讲，这种分层绘制生成最终平面的思想不难理解，尤其是如果你以前使用过类似Phtotshop等工具的话。我们的另一篇文章[how pixels get onto the screen](http://www.objc.io/issue-3/moving-pixels-onto-the-screen.html)对这个问题有更深入的分析。
Now, recall that every view has a bounds and frame rectangle. When laying out an interface, we deal with the frame rectangle of a view. This allows us to position and size the view. The frame and bounds of a view will always have the same size, but their origin will differ. Understanding how these two rectangles work is the key to understanding how UIScrollView works. | 现在，回到这个话题上来：每个视图都有[bounds](http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/instp/UIView/bounds)和[frame](http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/instp/UIView/frame)两个矩形。在布局界面时，我们用到的是视图的**frame**属性，这个参数能用来规定视图的位置和大小。视图的**frame**和**bounds**应该总是保持大小一致，但它们的原点（origin）是不同的。理解了这两个矩形的原理就理解了**UIScrollView**的原理。
During the rasterization step, a view doesn’t care about what is going to happen in the upcoming composition step. That is to say, it doesn’t care about its frame (which will be used to position the view’s image) or its place in the view hierarchy (which will determine the order in which it is composited). The only thing a view cares about at this time is drawing its own content. This drawing occurs in each view’s drawRect: method. | 在光栅化那步中，视图并不关心在接下来的合成中会发生什么事情。也就是说，视图并不关心在视图层级(视图层级决定了合成的顺序)中它的**frame**(被用来规定视图图像的位置)，或者它被放在哪里。在这一步中，视图所唯一关心的是绘制它的内容。这个绘制发生在每个视图的[`drawRect:`](http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/instm/UIView/drawRect:)方法中。
Before drawRect: is called, a blank image is created for the view to draw its content in. This image’s coordinate system is the bounds rectangle of the view. For nearly every view, the bounds rectangle’s origin is {0, 0}. Thus, to draw something in the top-left corner of the rasterized image, you would draw at the origin of the bounds, the point {x:0, y:0}. To draw something in the bottom right corner of an image, you would draw at point {x:width, y:height}. If you draw outside of a view’s bounds, that drawing is not part of the rasterized image and is discarded. | 在`drawRect:`被调用之前，视图会创建一个空白的图像用于绘制内容。这个空白图像的坐标系就是视图的**bounds**。几乎每一个视图，**bounds**矩形的原点都是`{0，0}`。因此，为了在栅格化图像的左上角绘制内容，你要在**bounds**的原点进行绘制，该点的值为`{x:0,y:0}`。要想在栅格化图像的右下角绘制内容，你的绘制点要设置为`{x:width,y:height}`。如果你在一个视图的**bounds**以外进行绘制，那么所绘制的内容不属于栅格化图像，会被丢弃不处理。

![scroll view 2](http://leyleo.github.io/assets/images/201308/scroll-view-2.png)

Source | 译文
------ | ---
During the composition step, each view composites its rasterized image on top of its superview’s image (and so on). A view’s frame rectangle determines where the view’s image is drawn on its superview’s image - the origin of the frame indicates the offset between the top-left corner of the view’s image and its superview’s image. So, a frame origin of {x:20, y:15} will create a composited image where the view’s image is drawn on top of its superview’s image, shifted to the right 20 points and down 15 points. Because the frame and bounds rectangle of a view are always the same size, the image is composited pixel for pixel to its superview’s image. This ensures there is no stretching or shrinking of the rasterized image. | 在合成那步中，每个视图将自身的栅格化图像合成到父视图图像的顶层。一个视图的**frame**矩形决定了自身图像会被绘制到父视图图像的哪里——**frame**的**origin**决定了自身图像的左上角在父视图图像中的偏移量。frame origin为`{x:20,y:15}`意味着这个视图的图像将被合成到父视图图像上原点右偏20，下移15的位置。因为一个视图的**frame**矩形和**bounds**矩形大小总是一致的，所以视图的图像每一像素都被映射到父视图图像上。这保证了栅格化图像不会拉伸变形。

![scroll view 1](http://leyleo.github.io/assets/images/201308/scroll-view-1.png)

Source | 译文
------ | ---
Remember, we’re talking about just one composite operation between a view and its superview. Once those two views are composited together, the resulting composite image is composited with the super-superview’s image and so on: a snowball effect.| 要注意，我们现在讨论的只是一个视图和它父视图间的一种合成操作。一旦两个视图被合成到一起，所得到的合成图像将被上上个视图的图像组合在一起，以此类推，这像滚雪球一样。
Think about the math behind compositing an image onto another. The top-left corner of a view’s image is offset by its frame’s origin and then drawn onto its superview’s image: | 思考下一个图像合成到另一个图像上的数学算法。一个视图的图像左上角加上自身**frame**的原点偏移量，然后被绘制在父视图的图像上：

	CompositedPosition.x = View.frame.origin.x - Superview.bounds.origin.x;
	CompositedPosition.y = View.frame.origin.y - Superview.bounds.origin.y;
	
Now, as we have said before, the origin of a view’s bounds rectangle is typically just {0, 0}. Thus, when doing the math, we just drop out one of the values and we get:

如上所述，视图的**bounds**矩形的原点显然是`{0,0}`。因此，在进行数学运算时，我们去掉这一项的值，于是得到：

	CompositedPosition.x = View.frame.origin.x;
	CompositedPosition.y = View.frame.origin.y;

So, we can look at a few different frames and see how they would look:

我们来看几种不通的**frame**，看效果如何：

![scroll view 3](http://leyleo.github.io/assets/images/201308/scroll-view-3.png)

Source | 译文
------ | ---
And this should make sense. We change the frame’s origin of the button, and it changes its position relative to its lovely purple superview. Notice that if we move the button so that parts of it are outside of the bounds of the purple superview, those parts are clipped in the same way drawing during rasterization would be clipped. However, technically, because of how iOS handles compositing under the hood, you can have a subview render outside of its superview’s bounds, but drawing during rasterization cannot occur outside of a view’s bounds. | 应该很好理解。我们改变按钮**frame**的原点，它在粉色父视图上的位置就跟着变了。注意，当我们将按钮移到部分在粉色父视图外面时，那部分就随着光栅化所绘制图像的裁剪而被裁剪掉了。不过，从技术上将，根据iOS处理合成的底层原理，你可以让一个子视图渲染父视图**bounds**以外的图像，不过在视图**bounds**以外的部分不会存在光栅化处理中的绘制行为。
##Scroll View's Content Offset
Source | 译文
------ | ---
Now, what does all of this have to do with UIScrollView? Everything. Think about a way we could accomplish scrolling: we could have a view whose frame we change when we drag it. It accomplishes the same thing, right? If I drag my finger to the right, I increase the origin.x of the view I’m dragging and voila, scroll view! | 讲了这么多，跟**UIScrollView**有啥关系呢？万事万物皆有联系。思考一个可以实现滚动的方案：我们能做一个拖拽它就能改变它frame的视图。这不就结啦？如果我向右拖拽视图，我就增大它的`origin.x`，看，滚动视图成了。
The problem with that, of course, is that there are typically many views in a scroll view. To implement this panning feature, you would have to change the frames of every view every time the user moved his or her finger. But we’re missing something. Remember that equation that we came up with to determine where a view composited its image onto its superview? | 当然，那个方案有个问题，就是一个滚动视图中会有很多个视图。为了扩展这个功能，你不得不在用户每次移动他/她的手指时，改变每一个视图的**frame**。我们好像忘了什么事情。记得么，我们得出来的，用来计算一个视图会把自身的图像合成到父视图图像哪里的那个公式：

	CompositedPosition.x = View.frame.origin.x - Superview.bounds.origin.x;
	CompositedPosition.y = View.frame.origin.y - Superview.bounds.origin.y;

Source | 译文
------ | ---
We dropped the Superview.bounds.origin values because they were always 0. But what if they weren’t? What if, say, we used the same frames from the previous diagram, but we changed the purple view’s bounds origin to something like {-30, -30}. We’d get this: | 我们消掉了`Superview.bounds.origin` 那项，因为它总是为0，但如果它不为0呢？也就是说，如果我们还用上面那张图为例，只不过将粉色视图的**bounds**原点变成其他的，譬如`{-30,-30}`，我们这下得到：

![scroll view 4](http://leyleo.github.io/assets/images/201308/scroll-view-4.png)

Source | 译文
------ | ---
Now, the beauty of this is that every single subview of this purple view is shifted by the change to its bounds. This is, in fact, exactly how a scroll view works when you set its contentOffset property: it changes the origin of the scroll view’s bounds. In fact, contentOffset isn’t even real! Its code probably looks like this: | 神奇的事情发生了：仅仅改变了粉色视图的**bounds**值，它的每个子视图却都发生了移动。实际上，这就是当你设置了滚动视图的`contentOffset`值时，滚动视图的移动原理：它改变的是滚动视图**bounds**的原点。实际上`contentOffset`根本不存在，它的代码大概如下：

	- (void)setContentOffset:(CGPoint)offset
	{
		CGRect bounds = [self bounds];
		bounds.origin = offset;
		[self setBounds:bounds];
	}
	
Source | 译文
------ | ---
Notice that in the previous diagram, changing the bounds’ origin enough moved the button outside of the composited image produced by the purple view and the button. This is just what happens when you scroll a scroll view enough so that a view disappears! | 上图中需要注意一点，将粉色视图的**bounds**原点改变足够大，就能将按钮移出粉色视图和按钮所要合成的图像之外。这就是为什么你滚动一个scroll view足够多，上面的一个视图就会消失不见。
##A Window into the World: Content Size
Source | 译文
------ | ---
Now that the hard part is out of the way, let’s look at another property of UIScrollView, contentSize. | 最难的部分已经讲完了，现在我们来看**UIScrollView**的另一个属性，**[contentSize](http://developer.apple.com/library/ios/documentation/uikit/reference/UIScrollView_Class/Reference/UIScrollView.html#//apple_ref/occ/instp/UIScrollView/contentSize)**。
The content size of a scroll view doesn’t change anything about the bounds of a scroll view and therefore does not impact how a scroll view composites its subviews. Instead, the content size defines the scrollable area. By default, a scroll view’s content size is a big, fat {w:0, h:0}. Since there is no scrollable area, the user can’t scroll, but the scroll view will still display all of the subviews that fit inside the scroll view’s bounds. | 一个滚动视图的内容尺寸（content size）不会对视图的**bounds**产生任何影响，因此也不会影响视图对其子视图的合成。content size定义了滚动视图的可移动区域(scrollable area)。默认情况下，滚动视图的content size是`{w:0,h:0}`，也就是没有可移动区域，用户无法滚动视图，不过滚动视图会显示**bounds**内所有子视图内容。
When the content size is set to be larger than the bounds of the scroll view, the user is allowed to scroll. You can think of the bounds of a scroll view as a window into the scrollable area defined by the content size: | 当滚动视图的content size设置为比**bounds**大的区域时，用户就能滚动视图了。你可以看作是通过滚动视图的**bounds**大小的窗口去操作由content size设定的可滚动区域：

![scroll view 5](http://leyleo.github.io/assets/images/201308/scroll-view-5.png)

Source | 译文
------ | ---
When the content offset is {x:0, y:0}, the viewing window’s top-left corner is in the top-left corner of the scrollable area. This is also the minimum value of the content offset; the user can’t scroll to the left or above the scrollable area. There’s nothing there! | 当内容偏移量(content offset)为`{x:0,y:0}`时，视图窗口的左上角在可移动区域的左上角，这也是内容偏移量的最小值；用户无法再向左或者向上移动视图了，那什么也没有了。
The maximum value for the content offset is the difference between the content size and the scroll view’s bounds’ size. This makes sense; scrolling all the way to the bottom right, the user is stopped so that the bottom-right edge of the scrolling area is flush with the bottom-right edge of the scroll view’s bounds. You could write the maximum content offset like this: | 内容偏移量的最大值是content size和滚动视图的**bounds** size的差值。这很好理解，将视图一直滚动到右下角，直至滚动区域的右下角边界与滚动视图**bounds**的右下角边界齐平。如下可得出最大偏移量：

	contentOffset.x = contentSize.width - bounds.size.width;
	contentOffset.y = contentSize.height - bounds.size.height;

##Tweaking the Window with Content Insets
Source | 译文
------ | ---
The property [contentInset](http://developer.apple.com/library/ios/documentation/uikit/reference/UIScrollView_Class/Reference/UIScrollView.html#//apple_ref/occ/instp/UIScrollView/contentInset) can change the maximum and minimum values of the content offset to allow scrolling outside of the scrollable area. Its type is [UIEdgeInsets](http://developer.apple.com/library/ios/#documentation/uikit/reference/UIKitDataTypesReference/Reference/reference.html#//apple_ref/doc/c_ref/UIEdgeInsets), which consists of 4 numbers: {top, left, bottom, right}. When you introduce an inset, you change the range of the content offset. For example, setting the content inset to have a value of 10 for its top value allows the content offset’s y value to reach -10. This introduces padding around the scrollable area. | 属性值**[contentInset](http://developer.apple.com/library/ios/documentation/uikit/reference/UIScrollView_Class/Reference/UIScrollView.html#//apple_ref/occ/instp/UIScrollView/contentInset)**能改变滚动视图可移动区域的最大和最小内容偏移量，以便用户能移动到可移动区域之外。这个属性是**[UIEdgeInsets](http://developer.apple.com/library/ios/#documentation/uikit/reference/UIKitDataTypesReference/Reference/reference.html#//apple_ref/doc/c_ref/UIEdgeInsets)**类型的，有四个数值：`{top, left, bottom ,right}`。 使用content inset就能改变内容偏移量的范围。例如，将content inset的 top 值设置为10， 那么content offset的 y 值最小能到-10. 也就是在可移动区域周围设置了内边距（padding）值。

![scroll view 6](http://leyleo.github.io/assets/images/201308/scroll-view-6.png)

Source | 译文
------ | ---
This may not seem very useful at first. In fact, why not just increase the content size? Well, you should avoid changing the content size of a scroll view unless you have to. To understand why, consider a table view (UITableView is a subclass of UIScrollView, so it has all of the same properties). The table view’s scrollable area has been carefully calculated to fit each one of its cells snugly. When you scroll past the boundaries of the table view’s first or last cells, the table view snaps the content offset back into place, so that the cells once again fit snugly in the scroll view’s bounds. | 一眼看上去这个值没啥用处。事实上，为什么不直接加大content size呢？是这样的，不到万不得已，你最好避免改变滚动视图的content size。想知道为什么嘛？思考一下列表视图（table view）( **UITableView** 是 **UIScrollView** 的子类，它有上述所有的参数)吧。为了让列表视图的每一个cell都显示正常，列表视图的可移动区域需要经过精心的计算。当你将列表视图拉到第一个cell上面，或者最后一个cell下面时，视图会回弹，使得cells最终能在滚动视图的边界内正常显示。
Now, what happens when you want to implement pull to refresh using a UIRefreshControl? You can’t put the UIRefreshControl within the scrollable area of the table view, otherwise, the table view would allow the user to stop scrolling halfway through the refresh control, and the top would snap to the top of the refresh control. Thus, you must put refresh control just above the scrollable area. This allows the content offset to snap back to the first row, not the refresh control. | 如果你想用 **[UIRefreshControl](http://developer.apple.com/library/ios/#documentation/uikit/reference/UIRefreshControl_class/Reference/Reference.html)** 实现下拉刷新会怎样？你不能将 **UIRefreshControl** 放到列表视图的可移动区域内，否则列表视图会因为刷新操作让用户的滚动操作半路失效，而且顶部与刷新控件的顶端齐平。因此，你必须将刷新控件放到可移动区域的上面，这样才能保证content offset偏移后能够回弹到列表的第一行，而不是跑到刷新控件那。
But wait, if you initiate the pull-to-refresh mechanism by scrolling far enough, the table view does allow the content offset to snap refresh control into the scrollable area, and this is because of the table view’s content inset. When the refresh action is initiated, the content inset is adjusted so that the minimum content offset includes the entirety of the refresh control. When the refresh completes, the content inset is returned to normalcy, the content offset follows suit, and none of the math required for determining the content size needs to be re-computed. | 不过，如果你滚动到触发了下拉刷新，列表视图就会偏移到可移动区域上刷新控件的位置，这个偏移操作倚赖于content inset值。当刷新事件被触发，content inset值就会被调整到能包含整个刷新控件的最小值。当刷新完成，content inset值会被复原，content offset也会跟着改变，而且不需要重新计算content size等。
How can you use the content inset in your own code? Well, there is one great use for the it: when the keyboard is on the screen. Typically, you try to design a user interface that fits the screen snugly. When the keyboard appears on the screen, you lose a few hundred pixels of that space. All of the stuff underneath the keyboard is obscured. | 那么，怎么在你自己的代码中使用content inset呢？有一个场景非常有用：屏幕中出现键盘的时候。尤其是你想让用户界面看起来很贴合屏幕大小时。当键盘出现在屏幕上时，你本来视图的可见区域就少了很多，所有键盘下的内容被遮挡不可见了。
Now, the scroll view’s bounds haven’t changed, and neither has its content size (nor should it). But the user can’t scroll the scroll view. Think about the equation from earlier: the maximum content offset is the difference between the content size and the bounds’ size. If they are equal, which they are in your snug interface that now has a keyboard messing up your day, the maximum content offset is {x:0, y:0}. | 现在滚动视图的**bounds**并没有改变，它的content size也没有变化。但是用户却不能滚动这个视图。回想一下前面讲到的公式：内容偏移量的最大值是content size和滚动视图的bounds size的差值。如果在键盘出现前后的界面中content size和 bounds 值都是一致的，那么content offset最大值就是`{x:0, y:0}`。
The trick, then, is to put the interface in a scroll view. The content size of the scroll view remains fixed at the same size as the scroll view’s bounds. When the keyboard appears on the screen, you set the bottom of the content inset equal to the height of the keyboard. | 解决方法就是将界面放到一个滚动视图中去。这个滚动视图的content size仍然是跟bounds大小一致。当键盘被唤起时，将content inset的bottom值设置为键盘高度。

![scroll view 7](http://leyleo.github.io/assets/images/201308/scroll-view-7.png)

Source | 译文
------ | ---
This allows the maximum value of the content offset to show the area beyond the scrollable area. The top of the visible area is outside the bounds of the scroll view, and is therefore clipped (although it is also off the screen itself, so that doesn’t matter too much). | 这个值决定了视图滚动到可移动区域外的content offset的最大值。可视区域的顶部在滚动视图的边界之外因而被裁剪不见（它已经不在屏幕内，无关紧要了）。
Hopefully, this gives you some insight into the inner workings of scroll views. Are you wondering about zooming? Well, we won’t talk about it today, but here’s a fun tip: check the transform property of the view you return from viewForZoomingInScrollView:. Once again, you’ll find that a scroll view is just cleverly using already-existing properties of UIView. | 希望本文能为你理解滚动视图的内在原理带来帮助。你想了解缩放（zooming）相关的内容嘛？我们今天不讨论那个话题，不过奉送个有趣的小贴士：判断 `viewForZoomingInScrollView:` 返回值view的 **transform** 属性值。你会再次发现滚动视图(scroll view)不过是非常聪明地使用了**UIView**已有的属性。

----
本话题更多文章请见：

* [Editorial 导论](http://leyleo.github.io/%E6%8A%80%E6%9C%AF/2013/08/10/views/)
* [Getting Pixels onto the Screen](http://www.objc.io/issue-3/moving-pixels-onto-the-screen.html) 待译
* [Custom Collection View Layouts](http://www.objc.io/issue-3/collection-view-layouts.html) 待译
* [Custom Controls](http://www.objc.io/issue-3/custom-controls.html) 待译
* [Advanced Auto Layout Toolbox](http://www.objc.io/issue-3/advanced-auto-layout-toolbox.html) 待译