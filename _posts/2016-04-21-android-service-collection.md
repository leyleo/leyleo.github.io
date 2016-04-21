---
layout: post
title: "一篇就能看明白Android Service"
description: "一篇就能看明白Android Service"
category: 技术
tags: [Android, Service]
excerpt: ""

---
{% include JB/setup %}

### 什么是Service？

**Service** 主要提供两大功能：

* A facility for the application to tell the system about something it wants to be **doing in the background (even when the user is not directly interacting with the application)**. This corresponds to calls to`Context.startService()`, which ask the system to schedule work for the service, to be run until the service or someone else explicitly stop it.

* A facility for an application to **expose some of its functionality to other applications**. This corresponds to calls to`Context.bindService()`, which allows a long-standing connection to be made to the service in order to interact with it.

一种是通过`startService`启动服务，一旦启动，服务即可在后台无限期运行，即使启动服务的组件已被销毁也不受影响。 已启动的服务通常是执行单一操作，而且不会将结果返回给调用方。需要实现`onStartCommand()`回调方法（允许组件启动服务），当另一个组件（如 Activity）通过调用`startService()`请求启动服务时，系统将调用此方法。一旦执行此方法，服务即会启动并可在后台无限期运行。如果实现此方法，则在服务工作完成后，需要由我们通过调用`stopSelf()`或`stopService()`来停止服务。（如果只想提供绑定，则无需实现此方法。）

另一种是通过`bindService`与`Activity`进行绑定，绑定服务提供了一个客户端-服务器接口，允许组件与服务进行交互、发送请求、获取结果，甚至是利用进程间通信 (IPC) 跨进程执行这些操作。 仅当与另一个应用组件绑定时，绑定服务才会运行。 多个组件可以同时绑定到该服务，但全部取消绑定后，该服务即会被销毁。需要实现`onBind()`回调方法（允许绑定服务），当另一个组件想通过调用`bindService()`与服务绑定（例如执行 RPC）时，系统将调用此方法。在此方法的实现中，需要返回`IBinder`，供客户端用来与服务进行通信。请务必实现此方法，但如果并不希望允许绑定，则应返回`null`。在客户端实现`bindService`时，必须创建一个`ServiceConnection`实例，通过它的回调方法`onServiceConnected`返回`IBinder`，来接收来自服务端的`IBinder`。

> **注意：**
`Service.onBind`如果返回null，则调用`bindService`会启动 Service，但不会连接上 Service，因此`ServiceConnection.onServiceConnected`不会被调用，但我们仍然需要使用`unbindService`函数断开它，这样 Service 才会停止。

#### 生命周期

两种形式可以共存，但是生命周期会有所不同。

* **启动服务：**该服务在其他组件调用`startService()`时创建，然后无限期运行，且必须通过调用`stopSelf()`来自行停止运行。此外，其他组件也可以通过调用`stopService()`来停止服务。服务停止后，系统会将其销毁。
* **绑定服务：**该服务在另一个组件（客户端）调用`bindService()`时创建。然后，客户端通过`IBinder`接口与服务进行通信。客户端可以通过调用`unbindService()`关闭连接。多个客户端可以绑定到相同服务，而且当所有绑定全部取消后，系统即会销毁该服务。服务不必自行停止运行。

![http://developer.android.com/images/service_lifecycle.png]({{BASE_PATH}}/assets/images/201604/service_lifecycle.png)

如果使用`startService`的同时也使用`bindService`，那么停止服务就应该同时使用`stopService`和`unbindService`。此外，如果服务已启动并接受绑定，则当系统调用`onUnbind()`方法时，如果想在客户端下一次绑定到服务时接收`onRebind()`调用（而不是接收`onBind()`调用），则可选择返回`true`。`onRebind()`返回空值，但客户端仍在其`onServiceConnected()`回调中接收`IBinder`。

![http://developer.android.com/images/fundamentals/service_binding_tree_lifecycle.png]({{BASE_PATH}}/assets/images/201604/service_binding_tree_lifecycle.png)

#### 简单的服务Demo

```java
public class LocalService extends Service {
    private NotificationManager mNM;

    // Unique Identification Number for the Notification.
    // We use it on Notification start, and to cancel it.
    private int NOTIFICATION = R.string.local_service_started;

    /**
     * Class for clients to access.  Because we know this service always
     * runs in the same process as its clients, we don't need to deal with
     * IPC.
     */
    public class LocalBinder extends Binder {
        LocalService getService() {
            return LocalService.this;
        }
    }

    @Override
    public void onCreate() {
        mNM = (NotificationManager)getSystemService(NOTIFICATION_SERVICE);

        // Display a notification about us starting.  We put an icon in the status bar.
        showNotification();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.i("LocalService", "Received start id " + startId + ": " + intent);
        return START_NOT_STICKY;
    }

    @Override
    public void onDestroy() {
        // Cancel the persistent notification.
        mNM.cancel(NOTIFICATION);

        // Tell the user we stopped.
        Toast.makeText(this, R.string.local_service_stopped, Toast.LENGTH_SHORT).show();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    // This is the object that receives interactions from clients.  See
    // RemoteService for a more complete example.
    private final IBinder mBinder = new LocalBinder();

    /**
     * Show a notification while this service is running.
     */
    private void showNotification() {
        // In this sample, we'll use the same text for the ticker and the expanded notification
        CharSequence text = getText(R.string.local_service_started);

        // The PendingIntent to launch our activity if the user selects this notification
        PendingIntent contentIntent = PendingIntent.getActivity(this, 0,
                new Intent(this, LocalServiceActivities.Controller.class), 0);

        // Set the info for the views that show in the notification panel.
        Notification notification = new Notification.Builder(this)
                .setSmallIcon(R.drawable.stat_sample)  // the status icon
                .setTicker(text)  // the status text
                .setWhen(System.currentTimeMillis())  // the time stamp
                .setContentTitle(getText(R.string.local_service_label))  // the label of the entry
                .setContentText(text)  // the contents of the entry
                .setContentIntent(contentIntent)  // The intent to send when the entry is clicked
                .build();

        // Send the notification.
        mNM.notify(NOTIFICATION, notification);
    }
}
```
```java
// 在Activity中的表现
private LocalService mBoundService;

private ServiceConnection mConnection = new ServiceConnection() {
    public void onServiceConnected(ComponentName className, IBinder service) {
        // This is called when the connection with the service has been
        // established, giving us the service object we can use to
        // interact with the service.  Because we have bound to a explicit
        // service that we know is running in our own process, we can
        // cast its IBinder to a concrete class and directly access it.
        mBoundService = ((LocalService.LocalBinder)service).getService();

        // Tell the user about this for our demo.
        Toast.makeText(Binding.this, R.string.local_service_connected,
                Toast.LENGTH_SHORT).show();
    }

    public void onServiceDisconnected(ComponentName className) {
        // This is called when the connection with the service has been
        // unexpectedly disconnected -- that is, its process crashed.
        // Because it is running in our same process, we should never
        // see this happen.
        mBoundService = null;
        Toast.makeText(Binding.this, R.string.local_service_disconnected,
                Toast.LENGTH_SHORT).show();
    }
};

void doBindService() {
    // Establish a connection with the service.  We use an explicit
    // class name because we want a specific service implementation that
    // we know will be running in our own process (and thus won't be
    // supporting component replacement by other applications).
    bindService(new Intent(Binding.this,
            LocalService.class), mConnection, Context.BIND_AUTO_CREATE);
    mIsBound = true;
}

void doUnbindService() {
    if (mIsBound) {
        // Detach our existing connection.
        unbindService(mConnection);
        mIsBound = false;
    }
}

@Override
protected void onDestroy() {
    super.onDestroy();
    doUnbindService();
}
```
```xml
<manifest ... >
  ...
  <application ... >
      <service android:name=".LocalService"
               android:exported=false /> <!--exported设置为false，表示只能在应用内部启动服务-->
      ...
  </application>
</manifest>
```

> **注意：**
服务在其托管进程的主线程中运行，它既不创建自己的线程，也不在单独的进程中运行（除非另行指定）。 这意味着，如果服务将执行任何 CPU 密集型工作或阻止性操作（例如 MP3 播放或联网），则应在服务内创建新线程来完成这项工作。通过使用单独的线程，可以降低发生“应用无响应”(ANR) 错误的风险，而应用的主线程仍可继续专注于运行用户与`Activity`之间的交互。

### IntentService

我们可以使用继承自`Service`的子类`IntentService`来轻松使用线程来处理请求。它简化了启动服务的实现，如果不要求服务同时处理多个请求，这个子类是最好的选择。我们只需要实现`onHandleIntent()`方法即可，该方法会接收每个启动请求的`Intent`。如果还需要重写其他回调方法，要确保调用父类的实现，以便`IntentService`能够妥善处理工作线程的声明周期，如`onCreate()`、`onStartCommand()`或`onDestroy()`。除`onHandleIntent()`之外，唯一无需调用父类方法的就是`onBind()`。

```java
public class HelloIntentService extends IntentService {

  /**
   * A constructor is required, and must call the super IntentService(String)
   * constructor with a name for the worker thread.
   */
  public HelloIntentService() {
      super("HelloIntentService");
  }

  /**
   * The IntentService calls this method from the default worker thread with
   * the intent that started the service. When this method returns, IntentService
   * stops the service, as appropriate.
   */
  @Override
  protected void onHandleIntent(Intent intent) {
      // Normally we would do some work here, like download a file.
      // For our sample, we just sleep for 5 seconds.
      long endTime = System.currentTimeMillis() + 5*1000;
      while (System.currentTimeMillis() < endTime) {
          synchronized (this) {
              try {
                  wait(endTime - System.currentTimeMillis());
              } catch (Exception e) {
              }
          }
      }
  }
}
```
如果要求服务执行多线程，那么可以通过直接扩展`Service`来处理每个`Intent`。具体实现，如下所示：

```java
public class HelloService extends Service {
  private Looper mServiceLooper;
  private ServiceHandler mServiceHandler;

  // Handler that receives messages from the thread
  private final class ServiceHandler extends Handler {
      public ServiceHandler(Looper looper) {
          super(looper);
      }
      @Override
      public void handleMessage(Message msg) {
          // Normally we would do some work here, like download a file.
          // For our sample, we just sleep for 5 seconds.
          long endTime = System.currentTimeMillis() + 5*1000;
          while (System.currentTimeMillis() < endTime) {
              synchronized (this) {
                  try {
                      wait(endTime - System.currentTimeMillis());
                  } catch (Exception e) {
                  }
              }
          }
          // Stop the service using the startId, so that we don't stop
          // the service in the middle of handling another job
          stopSelf(msg.arg1);
      }
  }

  @Override
  public void onCreate() {
    // Start up the thread running the service.  Note that we create a
    // separate thread because the service normally runs in the process's
    // main thread, which we don't want to block.  We also make it
    // background priority so CPU-intensive work will not disrupt our UI.
    HandlerThread thread = new HandlerThread("ServiceStartArguments",
            Process.THREAD_PRIORITY_BACKGROUND);
    thread.start();

    // Get the HandlerThread's Looper and use it for our Handler
    mServiceLooper = thread.getLooper();
    mServiceHandler = new ServiceHandler(mServiceLooper);
  }

  @Override
  public int onStartCommand(Intent intent, int flags, int startId) {
      Toast.makeText(this, "service starting", Toast.LENGTH_SHORT).show();

      // For each start request, send a message to start a job and deliver the
      // start ID so we know which request we're stopping when we finish the job
      Message msg = mServiceHandler.obtainMessage();
      msg.arg1 = startId;
      mServiceHandler.sendMessage(msg);

      // If we get killed, after returning from here, restart
      return START_STICKY;
  }

  @Override
  public IBinder onBind(Intent intent) {
      // We don't provide binding, so return null
      return null;
  }

  @Override
  public void onDestroy() {
    Toast.makeText(this, "service done", Toast.LENGTH_SHORT).show();
  }
}
```

### 前台服务

从运行类型上来讲，上面介绍的都是后台服务，还有一种会在通知栏显示`ONGOING`状态的前台服务，通常见到的有音乐播放服务，或者文件下载等，当服务被终止的时候，通知栏的`Notification`也会消失。

如果要让服务运行于前台，需要调用`startForeground()`：

```java
Notification notification = new Notification(R.drawable.icon, getText(R.string.ticker_text),
        System.currentTimeMillis());
Intent notificationIntent = new Intent(this, ExampleActivity.class);
PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, 0);
notification.setLatestEventInfo(this, getText(R.string.notification_title),
        getText(R.string.notification_message), pendingIntent);
startForeground(ONGOING_NOTIFICATION_ID, notification);
```

如果要从前台删除服务，需要调用`stopForeground()`。此方法取一个布尔值，指示是否也删除状态栏通知。 此方法绝对不会停止服务。 但是，如果您在服务正在前台运行时将其停止，则通知也会被删除。

### 远程服务

从运行地点来讲，前面介绍的`Service`属于本地服务，这种服务是依附在主进程上的，但是当主进程被Kill之后，服务就会终止。另外我们可以创建远程服务（Remote Service），它有独立的进程，进程名为：**服务所在包名 +`android:process`字符串**。这种服务由于是独立的进程，所以当主进程被Kill后，服务能继续运行。但是由于需要跨进程通信，使用起来会麻烦一些，可以使用`Messenger`或者`AIDL`。

下面是使用`Messenger`作为进程通信方式的远程服务Demo：

```java
public class MessengerService extends Service {
    /** For showing and hiding our notification. */
    NotificationManager mNM;
    /** Keeps track of all current registered clients. */
    ArrayList<Messenger> mClients = new ArrayList<Messenger>();
    /** Holds last value set by a client. */
    int mValue = 0;

    /**
     * Command to the service to register a client, receiving callbacks
     * from the service.  The Message's replyTo field must be a Messenger of
     * the client where callbacks should be sent.
     */
    static final int MSG_REGISTER_CLIENT = 1;

    /**
     * Command to the service to unregister a client, ot stop receiving callbacks
     * from the service.  The Message's replyTo field must be a Messenger of
     * the client as previously given with MSG_REGISTER_CLIENT.
     */
    static final int MSG_UNREGISTER_CLIENT = 2;

    /**
     * Command to service to set a new value.  This can be sent to the
     * service to supply a new value, and will be sent by the service to
     * any registered clients with the new value.
     */
    static final int MSG_SET_VALUE = 3;

    /**
     * Handler of incoming messages from clients.
     */
    class IncomingHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case MSG_REGISTER_CLIENT:
                    mClients.add(msg.replyTo);
                    break;
                case MSG_UNREGISTER_CLIENT:
                    mClients.remove(msg.replyTo);
                    break;
                case MSG_SET_VALUE:
                    mValue = msg.arg1;
                    for (int i=mClients.size()-1; i>=0; i--) {
                        try {
                            mClients.get(i).send(Message.obtain(null,
                                    MSG_SET_VALUE, mValue, 0));
                        } catch (RemoteException e) {
                            // The client is dead.  Remove it from the list;
                            // we are going through the list from back to front
                            // so this is safe to do inside the loop.
                            mClients.remove(i);
                        }
                    }
                    break;
                default:
                    super.handleMessage(msg);
            }
        }
    }

    /**
     * Target we publish for clients to send messages to IncomingHandler.
     */
    final Messenger mMessenger = new Messenger(new IncomingHandler());

    @Override
    public void onCreate() {
        mNM = (NotificationManager)getSystemService(NOTIFICATION_SERVICE);

        // Display a notification about us starting.
        showNotification();
    }

    @Override
    public void onDestroy() {
        // Cancel the persistent notification.
        mNM.cancel(R.string.remote_service_started);

        // Tell the user we stopped.
        Toast.makeText(this, R.string.remote_service_stopped, Toast.LENGTH_SHORT).show();
    }

    /**
     * When binding to the service, we return an interface to our messenger
     * for sending messages to the service.
     */
    @Override
    public IBinder onBind(Intent intent) {
        return mMessenger.getBinder();
    }

    /**
     * Show a notification while this service is running.
     */
    private void showNotification() {
        // In this sample, we'll use the same text for the ticker and the expanded notification
        CharSequence text = getText(R.string.remote_service_started);

        // The PendingIntent to launch our activity if the user selects this notification
        PendingIntent contentIntent = PendingIntent.getActivity(this, 0,
                new Intent(this, Controller.class), 0);

        // Set the info for the views that show in the notification panel.
        Notification notification = new Notification.Builder(this)
                .setSmallIcon(R.drawable.stat_sample)  // the status icon
                .setTicker(text)  // the status text
                .setWhen(System.currentTimeMillis())  // the time stamp
                .setContentTitle(getText(R.string.local_service_label))  // the label of the entry
                .setContentText(text)  // the contents of the entry
                .setContentIntent(contentIntent)  // The intent to send when the entry is clicked
                .build();

        // Send the notification.
        // We use a string id because it is a unique number.  We use it later to cancel.
        mNM.notify(R.string.remote_service_started, notification);
    }
}
```

将`MessengerService`服务声明为独立进程：

```xml
<service android:name=".app.MessengerService"
        android:process=":remote" />
```
```java
/** Messenger for communicating with service. */
Messenger mService = null;
/** Flag indicating whether we have called bind on the service. */
boolean mIsBound;
/** Some text view we are using to show state information. */
TextView mCallbackText;

/**
 * Handler of incoming messages from service.
 */
class IncomingHandler extends Handler {
    @Override
    public void handleMessage(Message msg) {
        switch (msg.what) {
            case MessengerService.MSG_SET_VALUE:
                mCallbackText.setText("Received from service: " + msg.arg1);
                break;
            default:
                super.handleMessage(msg);
        }
    }
}

/**
 * Target we publish for clients to send messages to IncomingHandler.
 */
final Messenger mMessenger = new Messenger(new IncomingHandler());

/**
 * Class for interacting with the main interface of the service.
 */
private ServiceConnection mConnection = new ServiceConnection() {
    public void onServiceConnected(ComponentName className,
            IBinder service) {
        // This is called when the connection with the service has been
        // established, giving us the service object we can use to
        // interact with the service.  We are communicating with our
        // service through an IDL interface, so get a client-side
        // representation of that from the raw service object.
        mService = new Messenger(service);
        mCallbackText.setText("Attached.");

        // We want to monitor the service for as long as we are
        // connected to it.
        try {
            Message msg = Message.obtain(null,
                    MessengerService.MSG_REGISTER_CLIENT);
            msg.replyTo = mMessenger;
            mService.send(msg);

            // Give it some value as an example.
            msg = Message.obtain(null,
                    MessengerService.MSG_SET_VALUE, this.hashCode(), 0);
            mService.send(msg);
        } catch (RemoteException e) {
            // In this case the service has crashed before we could even
            // do anything with it; we can count on soon being
            // disconnected (and then reconnected if it can be restarted)
            // so there is no need to do anything here.
        }

        // As part of the sample, tell the user what happened.
        Toast.makeText(Binding.this, R.string.remote_service_connected,
                Toast.LENGTH_SHORT).show();
    }

    public void onServiceDisconnected(ComponentName className) {
        // This is called when the connection with the service has been
        // unexpectedly disconnected -- that is, its process crashed.
        mService = null;
        mCallbackText.setText("Disconnected.");

        // As part of the sample, tell the user what happened.
        Toast.makeText(Binding.this, R.string.remote_service_disconnected,
                Toast.LENGTH_SHORT).show();
    }
};

void doBindService() {
    // Establish a connection with the service.  We use an explicit
    // class name because there is no reason to be able to let other
    // applications replace our component.
    bindService(new Intent(Binding.this,
            MessengerService.class), mConnection, Context.BIND_AUTO_CREATE);
    mIsBound = true;
    mCallbackText.setText("Binding.");
}

void doUnbindService() {
    if (mIsBound) {
        // If we have received the service, and hence registered with
        // it, then now is the time to unregister.
        if (mService != null) {
            try {
                Message msg = Message.obtain(null,
                        MessengerService.MSG_UNREGISTER_CLIENT);
                msg.replyTo = mMessenger;
                mService.send(msg);
            } catch (RemoteException e) {
                // There is nothing special we need to do if the service
                // has crashed.
            }
        }

        // Detach our existing connection.
        unbindService(mConnection);
        mIsBound = false;
        mCallbackText.setText("Unbinding.");
    }
}
```

### 绑定服务

前面提到，通过`bindService()`，应用可以与服务进行通信交互。

这里先回顾一下绑定的主要流程：`Service`要提供绑定，必须要实现`onBind()`回调方法。该方法返回的`IBinder`对象定义了客户端用来跟服务进行交互的编程接口。客户端可通过调用`bindService()`绑定到服务，调用时，必须提供`ServiceConnection`的实现，来监控与服务的连接。当系统创建客户端与服务之间的连接时，会调用`ServiceConnection`上的`onServiceConnected()`，向客户端传递用来与服务通信的`IBinder`。

其中，最重要的环节是定义我们的`onBind()`回调方法返回的接口。我们可以通过三种不同的方法定义该接口。

#### 1. 扩展Binder类

如果服务是为我们自己的应用服务，且与客户端在同一个进程中，也就是我们一开始介绍的本地服务，那么比较适合该种方法：通过扩展`Binder`类并从`onBind()`返回它的实例来创建接口。客户端收到`Binder`后，可利用它直接访问`Binder`或者对应`Service`中可用的Public方法。

以下是具体的设置方法：

1). 在服务中，创建一个可满足下列任一要求的`Binder`实例：

  * 包含客户端可调用的公共方法
  * 返回当前`Service`实例，其中包含客户端可调用的公共方法
  * 或返回由服务承载的其他类的实例，其中包含客户端可调用的公共方法

2). 从`onBind()`回调方法返回此`Binder`实例。

3). 在客户端中，从`onServiceConnected()`回调方法接收`Binder`，并使用提供的方法调用绑定服务。

> 代码参考：[简单的Demo](#demo)

#### 2. 使用Messenger

如需让接口跨不同的进程工作，则可使用`Messenger`为服务创建接口。服务可以这种方式定义对应于不同类型`Message`对象的`Handler`。此`Handler`是`Messenger`的基础，后者随后可与客户端分享一个`IBinder`，从而让客户端能利用`Message`对象向服务发送命令。此外，客户端还可定义自有`Messenger`，以便服务回传消息。

这是执行进程间通信(IPC)的最简单方法，因为`Messenger`会在单一线程中创建包含所有请求的队列，这样我们就不必对服务进行线程安全设计。

以下是`Messenger`的使用方法摘要：

* 服务实现一个`Handler`，由其接收来自客户端的每个调用的回调
*`Handler`用于创建`Messenger`对象（对`Handler`的引用）
*`Messenger`创建一个`IBinder`，服务通过`onBind()`使其返回客户端
* 客户端使用`IBinder`将`Messenger`（引用服务的`Handler`）实例化，然后使用后者将`Message`对象发送给服务
* 服务在其`Handler`中（具体地讲，是在`handleMessage()`方法中）接收每个`Message`

这样，客户端并没有调用服务的“方法”。而客户端传递的“消息”（`Message`对象）是服务在其`Handler`中接收的。

> 代码参考：[远程服务](#section-2)

#### 3. 使用AIDL

AIDL（Android 接口定义语言）执行所有将对象分解成原语的工作，操作系统可以识别这些原语并将它们编组到各进程中，以执行IPC。如需直接使用AIDL，我们必须创建一个定义编程接口的`.aidl`文件。Android SDK工具利用该文件生成一个实现接口并处理IPC的抽象类，我们随后可在服务内对其进行扩展。上面提到的采用`Messenger`的方法实际上是以AIDL作为其底层结构。我们已知，`Messenger`会在单一线程中创建包含所有客户端请求的队列，以便服务一次接收一个请求。所以，如果想让服务同时处理多个请求，我们可直接使用AIDL。不过，在此情况下，我们的服务必须具备多线程处理能力，并采用线程安全式设计。

具体实现方法，不记录了。具体可以查看文档：[Android Interface Definition Language](http://developer.android.com/intl/zh-cn/guide/components/aidl.html)

-----

> 参考文章：

[服务](http://developer.android.com/intl/zh-cn/guide/components/services.html)

[Service](http://developer.android.com/intl/zh-cn/reference/android/app/Service.html)

[绑定服务](http://developer.android.com/intl/zh-cn/guide/components/bound-services.html)

[Android 中的 Service 全面总结](http://www.cnblogs.com/newcj/archive/2011/05/30/2061370.html)

[Android Service完全解析，关于服务你所需知道的一切(上)](http://blog.csdn.net/guolin_blog/article/details/11952435)

[Android Service完全解析，关于服务你所需知道的一切(下)](http://blog.csdn.net/guolin_blog/article/details/9797169)

[Service知识总结](http://mouxuejie.com/blog/2016-04-16/service-intentservice-analysis/)

[Android bound service 详解四：service绑定及生命期](http://blog.csdn.net/niu_gao/article/details/7393456)

[Messenger](http://developer.android.com/intl/zh-cn/reference/android/os/Messenger.html)
