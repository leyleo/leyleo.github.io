---
layout: post
title: "Core Data Overview"
description: "objc.io issue-4 Core Data Overview"
category: 技术
tags: [iOS, Core Data, 译文]
excerpt: "这篇文章介绍了Core Data的工作逻辑原理。<br/>希望对你能有所帮助。"

---
{% include JB/setup %}

写在前面：文章来自[objc.io](http://www.objc.io/) [Core Data Overview](http://www.objc.io/issue-4/core-data-overview.html)。作者：[Daniel Eggert](http://twitter.com/danielboedewadt)

翻译的目的是为了自己加深理解，水平有限，欢迎指正。(左侧是原文，右侧是译文)

----

Source | 译文 
------ | --- 
Core Data is probably one of the most misunderstood Frameworks on OS X and iOS. To help with that, we’ll quickly go through Core Data to give you an overview of what it is all about, as understanding Core Data concepts is essential to using Core Data the right way. Just about all frustrations with Core Data originate in misunderstanding what it does and how it works. Let’s dive in… | Core Data 大概是OS X和iOS系统上最被误解的框架之一。为了便于理解上述说法，我们将快速带你了解一下Core Data到底是什么。当然了，理解Core Data的基本概念对于正确使用它也是至关重要的。所有关于Core Data的消极看法都源自于对它的功能和工作原理的错误认识。下面就切入正题。

## What is Core Data?

Source | 译文
------ | ----
More than eight years ago, in April 2005, Apple released OS X version 10.4, which was the first to sport the Core Data framework. That was back when YouTube launched. | 八年前，也就是2005年的四月，苹果发布了OS X 10.4版本，这是Core Data框架的首次面世，也就是YouTube推出的时候。
Core Data is a model layer technology. Core Data helps you build the model layer that represents the state of your app. Core Data is also a persistent technology, in that it can persist the state of the model objects to disk. But the important takeaway is that Core Data is much more than just a framework to load and save data. It’s also about working with the data while it’s in memory. | Core Data是一种数据模型层的技术。Core Data能帮你建立表示你应用状态的数据模型。Core Data也是一种持久化技术，它能够将数据模型对象的状态持久化到硬盘上。但另外非常值得注意的是，Core Data不仅仅是一个用来加载/存储数据的框架。在内存中，它仍然能够处理数据。
If you’ve worked with [Object-relational mapping (O/RM)](https://en.wikipedia.org/wiki/Object-relational_mapping) before: Core Data is not an O/RM. It’s much more. If you’ve been working with SQL wrappers before: Core Data is not an [SQL](https://en.wikipedia.org/wiki/Sql) wrapper. It does by default use SQL, but again, it’s a way higher level of abstraction. If you want an O/RM or SQL wrapper, Core Data is not for you. | 如果你以前用过[ORM](https://en.wikipedia.org/wiki/Object-relational_mapping)：Core Data不只是一种ORM，它有更多内容。如果你以前在用SQL封包：Core Data不是一种[SQL](https://en.wikipedia.org/wiki/Sql)封包。它默认使用SQL实现，但它是一种更高层次上的抽象。如果你想要的是ORM或者SQL封包，Core Data不适合你。
One of the very powerful things that Core Data provides is its object graph management. This is one of the pieces of Core Data you need to understand and learn in order to bring the powers of Core Data into play. | Core Data牛掰之一就是它的数据对象图表管理。这是你能将Core Data学以致用所需要掌握的一个点。
On a side note: Core Data is entirely independent from any UI-level frameworks. It’s, by design, purely a model layer framework. And on OS X it may make a lot of sense to use it even in background daemons and the like. | 注释：Core Data完全独立于任何UI层级的框架。它在架构设计上属于纯粹的数据模型层框架。而且，在OS X系统上它被更多地使用，甚至用在后台守护进程或类似的地方。

## The Stack

Source | 译文
------ | ----
There are quite a few components to Core Data. It’s a very flexible technology. For most uses cases, the setup will be relatively simple. | Core Data有很多组件，它是一项非常灵活的技术。对大多数用例来说，它的设置相对简单。
When all components are tied together, we refer to them as the **_Core Data Stack_**. There are two main parts to this stack. One part is about object graph management, and this should be the part that you know well, and know how to work with. The second part is about persistence, i.e. saving the state of your model objects and retrieving the state again. | 将Core Data各部分组件合在一起统称**_Core Data堆栈_**。主要有两部分组成：一部分关于数据对象图表管理，这部分是需要你深入掌握的，知道它的工作原理。另一部分关于持久化，例如，存储你的数据模型对象状态，及重新恢复该状态等。
In between the two parts, in the middle of the stack, sits the Persistent Store Coordinator (PSC), also known to friends as the **_central scrutinizer_**. It ties together the object graph management part with the persistence part. When one of the two needs to talk to the other, this is coordinated by the PSC. | 在堆栈的两部分之间，是持久化存储协调器（Persistent Store Coordinator - PSC），俗称**_监管中心_**。它将数据对象图表管理和持久化处理两部分联系在一起。PSC负责协调两部分间的通信对话。

![Core Data Stack complex](http://leyleo.github.io/assets/images/201309/stack-complex.png)

Source | 译文 
------ | ----
The object graph management is where your application’s model layer logic will live. Model layer objects live inside a context. In most setups, there’s one context and all objects live in that context. Core Data supports multiple contexts, though, for more advanced use cases. Note that contexts are distinct from one another, as we’ll see in a bit. The important thing to remember is that objects are tied to their context. Each managed object knows which context it’s in, and each context known which objects it is managing. | 你应用里的数据模型逻辑应该放在数据对象图表管理那部分。数据模型层的对象存在于一个context(上下文)中。在大多数的设置里，都有一个上下文，而且所有的对象都存在于这个上下文中。对于更高级的用例，Core Data也支持多上下文。需要注意的是，多个上下文相互独立，这点我们稍后再说。有一点非常重要：对象都是与它所在的上下文相关的。每个被管理的对象都知道它属于哪个上下文，每一个上下文也明白它管理哪些对象。
The other part of the stack is where persistency happens, i.e. where Core Data reads and writes from / to the file system. In just about all cases, the persistent store coordinator (PSC) has one so-called persistent store attached to it, and this store interacts with a SQLite database in the file system. For more advanced setups, Core Data supports using multiple stores that are attached to the same persistent store coordinator, and there are a few store types than just SQL to choose from. | 堆栈的另一部分是处理持久化的，例如，Core Data对文件系统的读写操作就是在这部分完成的。绝大多数情况下，PSC都有一个所谓的持久化存储仓与之相连，而这个存储仓与文件系统中的一个SQLite数据库进行交互。对于更多需求的高级设置，Core Data支持单PSC使用多存储仓，而且除SQL以外有更多的存储类型可使用。
The most common scenario, however, looks like this: | 最常见的使用情况简化如下：

![Core Data Stack simple](http://leyleo.github.io/assets/images/201309/stack-simple.png)

## How the Components Play Together

Source | 译文
------ | ----
Let’s quickly walk through an example to illustrate how these components play together. In our article about a full application using Core Data, we have exactly one **_entity_**, i.e. one kind of object: We have an **_Item_** entity that holds on to a title. Each item can have sub-items, hence we have a **_parent_** and a **_child_** relationship. | 咱们举个栗子来说明一下这几个组件是怎么一起运转的。在文章[创建一个完整Core Data应用]()中，我们恰好有一个**_entity_**（实体），也就是这么一种对象：我们有一个与title相连的**_Item_**实体，每个item项都可以有几个子项，因此就产生了**_parent-child_**这样的父子关系。
This is our data model. As we mention in the article about Data Models and Model Objects, a particular kind of object is called an Entity in Core Data. In this case we have just one entity: an **_Item_** entity. And likewise, we have a subclass of **NSManagedObject** which is called **Item**. The **_Item_** entity maps to the **Item** class. The data models article goes into more detail about this. | 这就是我们的数据模型。在[数据模型与数据模型对象]()一文中我们提到，在Core Data中，我们将一类特定的对象(object)称之为实体(Entity)。在上面这个例子中，我们只有一个实体：**_Item_**. 而且，我们有一个被命名为**Item**的**NSManagedObject**类型子类。实体**_Item_**映射到**Item**类。关于这些更详细的介绍请看[数据模型与数据模型对象]()。
Our app has a single root item. There’s nothing magical to it. It’s simply an item we use to show the bottom of the item hierarchy. It’s an item that we’ll never set a parent on.| 我们的应用只有一个根部节点项。这里没啥复杂的玩意。这个根节点就是表示它处于层级关系的最低端，节点之上不会再存在任何父类节点。
When the app launches, we set up our stack as depicted above, with one store, one managed object context, and a persistent store coordinator to tie the two together. | 当应用载入，Core Data堆栈上便有了一个存储仓，一个托管对象上下文(managed object context - MOC)，以及用来连接两部分的PSC。
On first launch, we don’t have any items. The first thing we need to do is to create the root item. You add managed objects by inserting them into the context.| 应用首次载入时，不存在任何节点项。首先，我们要做的就是创建一个根节点。通过插入托管对象到上下文中来添加对应的节点。

### Creating Objects

Source | 译文
------ | ----
It may seem cumbersome. The way to insert objects is with the method on **NSEntityDescription**: |  看起来很麻烦，添加数据对象要调用 **NSEntityDescription** 的方法：

	+ (id)insertNewObjectForEntityForName:(NSString *)entityName inManagedObjectContext:(NSManagedObjectContext *)context
	
Source | 译文
------ | ----
We suggest that you add two convenience methods to your model class: | 我们建议你在你的模型类中添加两个方法，以便操作：

	+ (NSString *)entityName
	{
	   return @“Item”;
	}
	
	+ (instancetype)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)moc
	{
	   return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] 
	                                        inManagedObjectContext:moc];
	}
Source | 译文
------ | ----
Now, we can insert our root object like so: | 现在我们可以这样来插入根对象了：

	Item *rootItem = [Item insertNewObjectInManagedObjectContext:managedObjectContext];

Source | 译文
------ | ---
Now there’s a single item in our managed object context (MOC). The context knows about this newly inserted managed object and the managed object **rootItem** knows about the context (it has a `-managedObjectContext` method). | 现在，在托管对象上下文(MOC)中存在一个对象实例了，上下文知晓这个新添加的托管对象，而且这个托管对象**rootItem**也知晓所对应的上下文（托管对象有个方法叫 `-managedObjectContext`）。

### Saving Changes

Source | 译文
------ | ---
At this point, though, we have not touched the persistent store coordinator or the persistent store, yet. The new model object, **rootItem**, is just in memory. If we want to save the state of our model objects (in this case just that one object), we need to save the context:| 到此为止，我们还没有接触过PSC和持久化存储仓。新建的托管对象**rootItem**还只存在于内存中。如果希望将数据模型对象的状态存储起来（在这个例子中只有那一个托管对象），我们需要保存对应的上下文(context):

	NSError *error = nil;
	if (! [managedObjectContext save:&error]) {
		// Uh, oh. An error happened. :(
	}

Source | 译文
------ | ---
At this point, a lot is going to happen. First, the managed object context figures out what has changed. It is the context’s responsibility to track any and all changes you make to any managed objects inside that context. In our case, the only change we’ve made thus far is inserting one object, our **rootItem**. | 现在开始有很多事被触发。首先，MOC判断哪些数据发生了修改。对应的上下文负责跟踪所有属于该上下文内的托管对象的任何修改。在我们的例子中，我们到目前为止唯一做的修改就是插入一个**rootItem**对象。
The managed object context then passes these changes on to the persistent store coordinator and asks it to propagate the changes through to the store. The persistent store coordinator coordinates with the store (in our case, an SQL store) to write our inserted object into the SQL database on disk. The **NSPersistentStore** class manages the actual interaction with SQLite and generates the SQL code that needs to be executed. The persistent store coordinator’s role is to simply coordinate the interaction between the store and the context. In our case, that role is relatively simple, but complex setups can have multiple stores and multiple contexts. | MOC将这些修改传给PSC，并让PSC传给存储仓。PSC配合存储仓（在我们的例子中，是SQL存储仓）将我们插入的对象写入硬盘的SQL数据库中。**NSPersistentStore** 类管理与SQLite的实际交互，并生成需要被执行的SQL代码。PSC的角色就是简单协调存储仓和上下文之间的交互。本例中，PSC工作相当少，但是通过复杂的配置可以协调多个存储仓和多个上下文。

### Updating Relationships

Source | 译文
------ | ---
The power of Core Data is managing relationships. Let’s look at the simple case of adding our second item and making it a child item of the **rootItem**: | Core Data的强大之处在于管理数据关系。我们来看一个简单的例子，将第二个数据项添加进来，并将其作为**rootItem**的子项：

	Item *item = [Item insertNewObjectInManagedObjectContext:managedObjectContext];
	item.parent = rootItem;
	item.title = @"foo";
	
Source | 译文
------ | ---
That’s it. Again, these changes are only inside the managed object context. Once we save the context, however, the managed object context will tell the persistent store coordinator to add that newly created object to the database file just like for our first object. But it will also update the relationship from our second item to the first and the other way around, from the first object to the second. Remember how the **_Item_** entity has a parent and a children relationship. These are reverse relationships of one another. Because we set the first item to be the parent of the second, the second will be a child of the first. The managed object context tracks these relationships and the persistent store coordinator and the store persist (i.e. save) these relationships to disk. | 搞定。同样的，这次的修改仅仅是插入数据到MOC。一旦我们保存了context，MOC就会告诉PSC将新建的数据对象添加到数据库文件去，就像第一个对象的操作那样。不过它还会更新从第二个数据项到第一个数据项的数据关系，及从第一个到第二个数据项的数据关系。记得搞清**_Item_**实体的父子关系，另一个实体要逆向。因为我们将第一项设置为第二项的父节点，第二项就是第一项的子节点。MOC跟踪这些数据关系，PSC和存储仓将这些数据关系持久化（例如，save）到硬盘上。

### Getting to Objects

Source | 译文
------ | ---
Let’s say we’ve been using our app for a while and have added a few sub-items to the root item, and even sub-items to the sub-items. Then we launch our app again. Core Data has saved the relationships of the items in the database file. The object graph is persisted. We now need to get to our root item, so we can show the bottom-level list of items. There are two ways for us to do that. We’ll look at the simpler one first. | 假设我们用了我们的应用一阵子，并添加了一些子数据项到根数据项上，甚至在子项的里面添加了一些子项。然后重新加载我们的应用。Core Data把这些数据项的数据关系在数据库文件里存的好好的。对象图表也存的妥妥的。现在我们需要取出根节点的内容，因此我们先列出来位于最底层级的元素。我们有两种方法来实现，先看第一种比较简单的。
When we created our **rootItem** object, and once we’ve saved it, we can ask it for its **NSManagedObjectID**. This is an opaque object that uniquely represents that object. We can store this into e.g. **NSUserDefaults**, like this: | 当我们创建了**rootItem**对象，而且保存了它，我们就可以通过它的**NSManagedObjectID**查找到。这是用以代表该实体对象唯一性的对象类。我们能将其存储到诸如**NSUserDefaults**之类的地方，如下：

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setURL:rootItem.managedObjectID.URIRepresentation forKey:@"rootItem"];

Now when the app is relaunched, we can get back to the object like so:

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSURL *uri = [defaults URLForKey:@"rootItem"];
	NSManagedObjectID *moid = [managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
	NSError *error = nil;
	Item *rootItem = (id) [managedObjectContext existingObjectWithID:moid error:&error];

Source | 译文
------ | ----
Obviously, in a real app, we’d have to check if **NSUserDefaults** actually returns a valid value. | 显而易见的是，在实际的应用里，我们最好确认**NSUserDefaults**返回的是有效值。
What just happened is that the managed object context asked the persistent store coordinator to get that particular object from the database. The root object is now back inside the context. However, all the other items are not in memory, yet. | 刚才那段讲的是MOC向PSC请求从数据库中取出那个指定的数据对象。那个根数据对象便恢复到context上下文中。不过其他的数据项并没有在内存中。
The **rootItem** has a relationship called children. But there’s nothing there, yet. We want to display the sub-items of our **rootItem**, and hence we’ll call: | **rootItem**有一个指向子项的数据关系。不过到现在为止还没有载入，我们希望显示**rootItem**的所有子项，因此我们调用：

	NSOrderedSet *children = rootItem.children;

Source | 译文
------ | ----
What happens now, is that the context notes that the relationship children from that **rootItem** is a so-called fault. Core Data has marked the relationship as something it still has to resolve. And since we’re accessing it at this point, the context will now automatically coordinate with the persistent store coordinator to bring those child items into the context. | 这时context上下文发现从**rootItem**到子项的数据关系还是个所谓的假象，Core Data所标识的数据关系需要被进一步处理。在我们调用了这个getter后，context上下文开始自动地由PSC协同处理将那些子项载入到该context中。
This may sound very trivial, but there’s actually a lot going on at this point. If any of the child objects happen to already be in memory, Core Data guarantees that it will reuse those objects. That’s what is called **_uniquing_**. Inside the context, there’s never going to be more than a single object representing a given item. | 看起来很小的一点儿操作，其实执行了很多操作。如果那些子对象中的一个或几个碰巧已经在内存中了，Core Data就重用已在内存中的对象。这种做法被称作**_uniquing_**。在context中，不会出现多个对象表示一个已存在项的情况。
Secondly, the persistent store coordinator has its own internal cache of object values. If the context needs a particular object (e.g. a child item), and the persistent store coordinator already has the needed values in its cache, the object (i.e. the item) can be added to the context without talking to the store. That’s important, because accessing the store means running SQL code, which is much slower than using values already in memory. | 另外一点，PSC在其内部对数据对象的值进行了缓存（cache）。如果context上下文需要取某个对象（例如，一个子项），而这个对象的值已经在PSC的缓存中，那么该对象（即上面的子项）将直接被添加到context上下文中，不需要再向存储仓发起请求。这点非常重要，因为请求存储仓意味着要运行SQL语句，这与直接使用内存中的值相比要花费更长的时间。
As we continue to traverse from item to sub-item to sub-item, we’re slowly bringing the entire object graph into the managed object context. Once it’s all in memory, operating on objects and traversing the relationships is super fast, since we’re just working inside the managed object context. We don’t need to talk to the persistent store coordinator at all. Accessing the **title**, **parent**, and **children** properties on our **Item** objects is super fast and efficient at this point. | 我们从一个数据项访问到它的子项，接着到子项的子项，就这样逐渐地将整个对象图表加载到MOC中。一旦全都加载到内存中，对对象的操作和对数据关系的遍历就变得特别快速，因为我们只需要在MOC内部操作，而不需要对PSC进行通信。这样一来，对**Item**那些**title**,**parent**,**children**等属性的读取就变得非常快，效率也提高了很多。
It’s important to understand how data is fetched in these cases, since it affects performance. In our particular case, it doesn’t matter too much, since we’re not touching a lot of data. But as soon as you do, you’ll need to understand what goes on under the hood. | 了解数据读取的原理是非常重要的，因为它影响到应用的性能。在我们的这个例子里，由于并没有接触大量的数据，所以影响不大。但是你要尽早理解它的内部原理。
When you traverse a relationship (such as parent or children in our case) one of three things can happen: (1) the object is already in the context and traversing is basically for free. (2) The object is not in the context, but the persistent store coordinator has its values cached, because you’ve recently retrieved the object from the store. This is reasonably cheap (some locking has to occur, though). The expensive case is (3) when the object is accessed for the first time by both the context and the persistent store coordinator, such that is has to be retrieved by store from the SQLite database. This last case is much more expensive than (1) and (2). | 当你遍历一个数据关系时（像咱们例子里的父子关系），会发生下面三种情况中的一种：(1) 待遍历的对象已经在context上下文中，可以轻松自由地遍历。（2）待遍历的对象不在context中，但是PSC已经将它的值缓存进来了，这通常发生在你刚才已经在数据仓中检索过这个对象的时候，这种情况对性能的影响还算可以（不过，还是会有些卡顿）。造价最高的情况是（3）待遍历的对象是第一次被context上下文和PSC检索，这时候必不可少地从数据仓中将SQLite数据库里的内容取出。第三种情况比（1）和（2）更耗费资源。
If you know you have to fetch objects from the store (because you don’t have them), it makes a huge difference when you can limit the number of fetches by getting multiple objects at once. In our example, we might want to fetch all child items in one go instead of one-by-one. This can be done by crafting a special **NSFetchRequest**. But we must take care to only to run a fetch request when we need to, because a fetch request will also cause option (3) to happen; it will always access the SQLite database. Hence, when performance matters, it makes sense to check if objects are already around. You can use `-[NSManagedObjectContext objectRegisteredForID:]` for that.| 如果你预先知道你要从数据仓里读取很多数据对象出来（因为他们一开始不会在内存中），那么通过一次读取多个数据来降低读取的次数，可以提升很多性能。在我们的例子里，我们如果想读取所有的子项出来，一次读取所有要比一次取一项要好。这种操作可以通过执行特定的**NSFetchRequest**来完成。不过我们必须要小心在必要的时候只使用一条读取请求（fetch request），因为一条读取请求也会引发上面的情况（3）发生；它总是会请求SQLite数据库。因此，当有性能问题时，需要格外注意所用的对象是不是已经在内存中了。你可以通过 `-[NSManagedObjectContext objectRegisteredForID:]` 来判断。

### Changing Object Values

Source | 译文
------ | ----
Now, let’s say we are changing the **title** of one of our **Item** objects: | 现在，我们来改变一个**Item**数据对象的**title**值：

	item.title = @"New title";
	
Source | 译文
------ | ----
When we do this, the items **title** changes. But additionally, the managed object context marks the specific managed object (item) as changed, such that it will be saved through the persistent store coordinator and attached store when we call -save: on the context. One of the key responsibilities of the context is **_change tracking_**. | 我们执行了上面操作后，这项数据的**title**值发生了改变。另外，MOC将这个托管数据对象（item）标示为已修改（changed），这样当我们在context上下文中执行`-save:`时，所做的修改将通过PSC被保存到相关联的数据仓中。context上下文的一个关键任务就是**_状态跟踪_**（change tracking）。
The context knows which objects have been inserted, changed, and deleted since the last save. You can get to those with the `-insertedObjects`, `-updatedObjects`, and `-deletedObjects` methods. Likewise, you can ask a managed object which of its values have changed by using the -changedValues method. You will probably never have to. But this is what Core Data uses to be able to push changes you make to the backing database. | context上下文知道从上次保存以来都有哪些数据对象被插入，修改，和删除。你可以通过`-insertedObjects`, `-updatedObjects`, `-deletedObjects`方法分别得到对应的数据项。类似，你可以通过`-changedValues`方法得到托管数据对象中有哪些参数值发生了改变。或许这些方法你永远也用不着。不过这就是Core Data用来向后端的数据库所发送的修改信息。
When we inserted new **Item** objects above, this is how Core Data knew it had to push those to the store. And now, when we changed the **title**, the same thing happened. | 当我们在上面讲到插入新的**Item**数据对象时，知道了Core Data是怎么知道它得向数据仓推送数据的。当我们修改了**title**时，逻辑类似。
Saving values needs to coordinate with both the persistent store coordinator and the persistent store, which, in turn, accesses the SQLite database. As when retrieving objects and values, accessing the store and database is relatively expensive when compared to simply operating on objects in memory. There’s a fixed cost for a save, regardless of how many changes you’re saving. And there’s a per-change cost. This is simply how SQLite works. When you’re changing a lot of things, you should therefore try to batch changes into reasonably sized batches. If you save for each change, you’d pay a high price, because you have to save very often. If you save to rarely, you’d have a huge batch of changes that SQLite would have to process. | 保存数据值需要PSC和持久化的数据仓相配合来访问SQLite数据库。从数据仓（store）和数据库(database)中检索数据对象和参数值要比在内存中检索耗费更多的性能。执行一次保存所消费的性能是固定的，跟你要保存多少项修改无关。另外有一种消费的性能是不定的，跟SQLite的执行能力相关。当你要修改很多数据时，最好尝试将一批修改分割为适当固定大小的批块。如果每次修改都分别进行保存，将会耗费你大量的性能，因为你要经常执行保存操作。如果你存储间隔太长，到最后SQLite需要处理大批量的修改。
It is also important to note that saves are atomic. They’re transactional. Either all changes will be committed to the store / SQLite database or none of the changes will be saved. This is important to keep in mind when implementing custom **NSIncrementalStore** subclasses. You have to either guarantee that a save will never fail (e.g. due to conflicts), or your store subclass has to revert all changes when the save fails. Otherwise, the object graph in memory will end up being inconsistent with the one in the store. | 另外需要注意的是，每次保存都是原子性(atomic)的，不可分割的，每次提交到存储仓/SQLite数据库中的修改要么全都被保存了，要么就一个也没存上。如果你要自己扩展**NSIncrementalStore**的子类时尤其需要注意这点。你要保证一次的保存中，所有的修改都没出错（譬如由于冲突导致的错误），或者你的子类在遇到保存失败时，需要将这次的所有修改恢复到保存前的状态。不然的话，在内存中的数据对象图表和数据仓里的图表就不一致了。
Saves will normally never fail if you use a simple setup. But Core Data allows multiple contexts per persistent store coordinator, so you can run into conflicts at the persistent store coordinator level. Changes are per-context, and another context may have introduced conflicting changes. And Core Data even allows for completely separate stacks both accessing the same SQLite database file on disk. That can obviously also lead to conflicts (i.e. one context trying to update a value on an object that was deleted by another context). Another reason why a save can fail is validation. Core Data supports complex validation policies for objects. It’s an advanced topic. A simple validation rule could be that the **title** of an **Item** must not be longer than 300 characters. But Core Data also supports complex validation policies across properties. | 如果你设置简单的话，保存的操作通常不会失败。但是Core Data允许单PSC有多context上下文，所以在PSC阶段会存在数据冲突现象。修改是在每一个context中进行的，一个context中的修改可能会跟另一处的修改发生冲突。而且Core Data甚至允许两个独立的数据堆栈（stack）都对硬盘上的同一个SQLite数据库进行读取。显然也会引起数据冲突（例如，一个context试图更新某个数据对象，而另一个context已经将该数据对象删除了）。另外一个会导致保存失败的原因是数据有效性。暂且不表。Core Data支持数据对象的复杂有效性检查。一个简单的有效性规则应该是**Item**对象的**title**不能超过300字符，不过Core Data也支持跨属性间的复杂有效性检查。

## Final Words

Source | 译文
------ | ---
If Core Data seems daunting, that’s most likely because its flexibility allows you to use it in very complex ways. As always: try to keep things as simple as possible. It will make development easier and save you and your user from trouble. Only use the more complex things such as background contexts if you’re certain they will actually help. | 如果说Core Data令人怯步，那很有可能是因为它的灵活性让你能操作各种复杂的情况。一如既往地是：让事情尽可能地保持简单。它能使开发变得更轻松，让你和你的用户避免麻烦。在你确信使用诸如后台上下文（background context）等复杂设置的确对你有用时，再使用这些。
When you’re using a simple Core Data stack, and you use managed objects the way we’ve tried to outline in this issue, you’ll quickly learn to appreciate what Core Data can do for you, and how it speeds up your development cycle. | 如果你使用简化的Core Data堆栈方式，并按照本文中所讲述的方法使用托管对象（managed object）时，你很快就会感谢Core Data所为你提供的一切，感谢它为你缩短了不少的开发周期。

----
该系列更多文章，请见：

- [Editorial](http://leyleo.github.io/%E6%8A%80%E6%9C%AF/2013/09/10/core-data/)
- [A Complete Core Data Application](http://www.objc.io/issue-4/full-core-data-application.html) 待译
- [On Using SQLite and FMDB Instead of Core Data](http://www.objc.io/issue-4/SQLite-instead-of-core-data.html) 待译
- [Data Models and Model Objects](http://www.objc.io/issue-4/core-data-models-and-model-objects.html) 待译
- [Importing Large Data Sets](http://www.objc.io/issue-4/importing-large-data-sets-into-core-data.html) 待译
- [Fetch Requests](http://www.objc.io/issue-4/core-data-fetch-requests.html) 待译
- [Custom Core Data migrations](http://www.objc.io/issue-4/core-data-migration.html) 待译