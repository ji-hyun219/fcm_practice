# fcm_practice

fcm 을 이용하여 정해진 시간 주기에 따라 android, ios 앱에 푸시 알림을 보내는 서비스를 연습합니다.

## Todo

1. 애플 개발자 계정 등록  
   계정 등록 후 ios 폴더를 마우스 왼쪽 클릭(xcode open) -> `Runner > signing & capabilities` -> Team 을 내 계정으로 변경
2. ios - 키파일 생성  
   APNs Key는 앱에 푸시 알림 서비스를 사용하기 위해 꼭 필요한 Key.

   - 하나의 키만 생성하면 모든 앱에서 이용 가능하다.
   - 키는 생성 후 한 번만 다운로드할 수 있으며, 이후에 다시 다운로드할 수 없다.
   - 때문에 키를 다운로드한 후 안전한 곳에 백업해두어야 한다.
   - 계정 당 APNS 키는 최대 2개만 발급 가능하다.

3. (ios 기준) 2 의 절차를 마친 후, Xcode의 App(앱) > Capabilities(기능)에서 푸시 알림(push notification)을 사용 설정 (background mode 도 추가 설정하면 된다)
4. 파이어베이스 연동  
   https://firebase.google.com/docs/flutter/setup?hl=ko&platform=ios  
   예전에는 ios, android 폴터 각각에 파이어베이스에서 발급 받은 google service 파일이 필요했으나,  
   현재는 flutterfire configure 명령으로 자동 생성해준 것으로 쉽게 변경된 것 같다.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

5. 로컬 노티피케이션 및 백그라운드 패키지 설치

## ios 의 APNs(Apple Push Notification service) 를 사용하는 이유와 작동 원리

APNs: 애플에서 만든 알림 서비스 플랫폼

https://babbab2.tistory.com/58?category=831129

- 푸시 알람을 위한 필수 동작

1. App 은 디바이스 토큰이 필요하다.
2. 이것은 APNs 에서 얻을 수 있다.
3. App 은 얻은 디바이스 토큰을 push server 에 전송한다. (푸시 알람을 받기 위한 필수 동작 방식)

- 푸시 발생 동작 원리

1. push servcer 는 디바이스 토큰과 데이터(전송하고 싶은 메세지) 를 APNs 에 보낸다.
2. APNs 는 해당 디바이스 토큰으로 데이터를 App 에게 보낸다.

## Device Token

푸시가 전송되는 App 의 주소로, 이 디바이스 토큰은 애플에서 정한 고유한 식별자를 포함시킨 NSData 형태로, 해독을 APNs만 할 수 있다.
