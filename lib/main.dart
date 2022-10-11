import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance; // getter
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }

    // 이 스트림(onMessage)에는 RemoteMessage 를 포함한다
    // RemoteMessage 는 어디서 왔는지, 고유 ID, 보낸 시간, 알림을 포함하는지 여부 등 을 다양한 정보(페이로드)를 묘사한다
    // 애플리케이션이 포그라운드에 있는 동안 메시지가 검색되었으므로 Flutter 애플리케이션의 상태 및 컨텍스트에 직접 액세스할 수 있다.

    /* 
    애플리케이션이 포그라운드에 있는 동안 도착하는 알림 메시지는 Android 및 iOS 모두에서 기본적으로 표시되는 알림을 표시하지 않는다. 
    그러나 이 동작을 재정의할 수 있다.

    Android에서는 "High Priority 높은 우선 순위" 알림 채널을 만들어야 한다.
    iOS에서는 애플리케이션의 프레젠테이션 옵션을 업데이트할 수 있다.

    * 포그라운드 사용법
    https://firebase.flutter.dev/docs/messaging/notifications#foreground-notifications
    */
  });

  // ios 포그라운드 알림 활성화 (원래 default 값: flase)
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );

  // android 포그라운드 알림 활성화
  // Android는 다음과 같은 몇 가지 요인에 따라 수신 알림을 다르게 처리.
  // 1. 애플리케이션이 백그라운드에 있거나 종료된 경우 할당된 "Notification channel 알림 채널"을 사용하여 알림이 표시되는 방식을 결정한다.
  // 2. 애플리케이션이 현재 포그라운드에 있으면 가시적인 알림이 표시되지 않는다.

  /* 
  안드로이드
  << Notification channel >>
  안드로이드에서 알림 메시지는 알림 전달 방법을 제어하는 데 사용되는 알림 채널로 전송된다.

  default FCM 채널은 사용자에게 숨겨져 있지만 "default" 중요도 수준을 제공.
  표시되는 알림에는 "max" 중요도 수준이 필요

  이것이 의미하는 것은, 즉 우선 중요도가 최대인 새 채널을 만든 다음, 수신 FCM 알림을 이 채널에 할당
  이것은 flutterfire 범위 밖이지만 local_notification 패키지를 설치하면 된다.
  
  */

  // 1. Create a new AndroidNotificationChannel instance:
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  // 2. create the channel on the device (if a channel with an id already exists, it will be updated):
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel); // 1 에서 만든 channel

  // 3. 생성되면 이제 default FCM channel 이 아닌 자체 채널을 사용할 수있도록 업데이트 할 수 있다.

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // If `onMessage` is triggered with a notification, construct our own
    // local notification to show to users using the created channel.
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
              // other properties...
            ),
          ));
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
