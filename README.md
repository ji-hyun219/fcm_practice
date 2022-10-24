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
   현재는 `flutterfire configure` 명령으로 자동 생성해준 것으로 쉽게 변경된 것 같다.

   `FlutterFire는 Flutter 애플리케이션을 Firebase 에 연결하는 Flutter 플러그인 세트`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

5. 파이어베이스 클라우드 메시징 설치
   https://firebase.flutter.dev/docs/messaging/overview/

   장치의 상태에 따라 수신 메시지가 다르게 처리된다.  
   이러한 시나리오와 FCM 을 자신의 애플리케이션에 통합하는 방법을 이해하려면 먼저 장치가 있을 수 있는 다양한 상태를 설정하는 것이 중요하다.
   |상태|설명|
   |--------|-------------------------------------------------------------|
   |foreground|응용 프로그램이 열려 있을 때 보기 및 사용 중입니다|
   |background|응용 프로그램이 열려 있으나 최소화된 상태, 즉 이는 일반적으로 사용자가 기기의 홈버튼을 눌렀거나 앱 전환기를 통해 다른 앱으로 전환하는 등 상태|
   |종료|기기가 잠겨있거나 애플리케이션이 실행되지 않을 때. 사용자는 기기의 앱 전환 UI를 통해 "스와이프하여 제거"하거나 탭(웹)을 닫아 앱을 종료할 수 있다.|

6. `애플리케이션이 FCM을 통해 메시지 페이로드를 수신하기 전에 충족해야 하는 몇 가지 전제 조건`
   - 애플리케이션은 FCM에 등록할 수 있도록 한 번 이상 열려 있어야 합니다.
   - iOS에서, 사용자가 앱 스위처에서 애플리케이션을 쓸어버리면 백그라운드 메시지가 다시 작동하기 시작하려면 수동으로 다시 열어야 합니다.
   - Android에서, 사용자가 기기 `설정`에서 앱을 `강제 종료`하는 경우 메시지가 작동하기 시작하려면 수동으로 다시 앱을 다시 열어야 합니다.
   - iOS 및 macOS에서 FCM 및 APN과 통합하려면 프로젝트를 올바르게 설정 해야 합니다.
   - 웹에서는, "웹 푸시 인증서" 키를 사용하여 토큰을 요청`(getToken)`해야 합니다.
7. 권한 요청(Web 과 Apple 만)
   iOS, macOS 및 웹에서 FCM 페이로드를 기기에서 수신하려면 먼저 사용자의 허가를 받아야 합니다.  
   Android 애플리케이션은 권한을 요청할 필요가 없습니다.

```dart
FirebaseMessaging messaging = FirebaseMessaging.instance;

NotificationSettings settings = await messaging.requestPermission(
  // NotificationSettings 클래스는 사용자의 결정에 대한 세부 정보를 제공
  alert: true,
  announcement: false,
  badge: true,
  carPlay: false,
  criticalAlert: false,
  provisional: false,
  sound: true,
);

// 사용자에게 부여된 권한
print('User granted permission: ${settings.authorizationStatus}');
```

- 위의 `authorizationStatus`
  `authorized`: 사용자가 권한을 부여했습니다.
  `denied`: 사용자가 권한을 거부했습니다.
  `notDetermined`: 사용자가 아직 권한 부여 여부를 선택하지 않았습니다.
  `provisional`: 사용자가 임시 권한을 부여했습니다

  안드로이드에서는 authorizationStatus 는 현재 장치에서 enabled, disabled, 지원되는지 여부를 return 한다.

8. 메시지 처리
   권한이 부여되고 다양한 유형의 장치 상태가 이해되면 이제 애플리케이션에서 FCM 을 처리할 수 있다.

   - 메세지 유형 (= 페이로드) 에 따라 다르게 처리함

   1. 알림 전용 메시지(가시적인 알림 제공)
   2. 데이터 전용 메시지(무음 메시지, 낮은 우선순위로 간주되나 FCM 페이로드에 추가 속성을 보내 우선순위 높일 수 있음)
   3. 알림 및 데이터 메시지

9. 로컬 노티피케이션 및 백그라운드 패키지 설치

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

## Android gradle 이란?

`Gradle` 이란 `빌드 배포 도구(build tool)` 이다.  
안드로이드 스튜디오로 프로젝트를 만들면 Gradle 이란 것도 생성되는 것을 볼 수 있다.  
이는 `안드로이드 스튜디오(IDE)와 빌드 시스템이 서로 독립적`이기 때문이다.  
이클립스에서는 프로젝트 빌드를 이클립스 내에서 담당했지만  
안드로이드 스튜디오는 코드의 편집만을 담당할 뿐, `빌드는 Gradle 을 통해 모두 수행`된다.  
때문에 간혹 안드로이드 스튜디오의 프로젝트 설정과 Gradle 빌드 설정이 동기화되지 않아 스튜디오에서 에러로 표시하는 경우가 있다.  
하지만 빌드 절차가 IDE 와 분리되어 있기 때문에 프로젝트를 더 깔끔하게 관리할 수 있게 되었다.

- 이전에는 라이브러리를 추가하려면 jar 파일을 받아서 설정해줘야 했지만 라이브러리들이 많아짐에 따라 `자동화 도구가 필요`해지게 되었고 `ant, maven, gradle` 등의 `라이브러리 관리 도구`가 등장했다. `안드로이드 스튜디오에서는 Gradle을 채택`하여 쓰고 있다.

### build.gradle 파일

https://uroa.tistory.com/64  
모듈의 빌드 방법이 정의된 빌드스크립트.  
빌드에 사용할 `SDK 버전`부터 시작하여 `애플리케이션 버전`, `사용하는 라이브러리` 등 다양한 항목을 설정하는 것이 가능하다.

### Manifest 파일

매니페스트 파일에는 많은 정보를 담을 수 있지만 그 중에서도 특히 선언되어야 하는 정보가 있다.

1. 앱의 패키지 이름
   매니페스트 파일의 Root element(<manifest></manifest>) 에는 해당 앱의 패키지 네임이 반드시 기재되어야 한다.

```xml
<?xml version="1.0" encoding="utf-8"?>

<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.fcm_practice"
    android:versionCode="1"
    android:versionName="1.0" >
...
</manifest>
```

manifest 의 패키지 네임은 언제 사용될까?  
이는 우리가 앱을 빌드하여 APK 를 추출하는 과정에서 Android Build Tool 에 의해 다음 2가지 목적으로 사용된다.

- App Resource 에 접근하는데 사용되는 R 클래스의 네임스페이스로 적용.
- 위 예에서는 com.example.fcm_practice.R 클래스가 생성.
- 매니페스트 파일 내에서 선언된 상대경로에 적용.
- 예를 들어 <activity android:name=".MainActivity"> 라고 선언했다면 이는 `"com.example.fcm_practice.MainActivity"` 를 가리킴.

2. 앱에서 사용되는 4대 컴포넌트(액티비티, 서비스, 브로드캐스트 리시버, 컨텐트 프로바이더)

- <activity> : Activity
- <service> : Service
- <receiver> : Broadcast Receiver
- <provider> : Content Provider

4대 컴포넌트들은 각각 인텐트에 의해 활성화됨.  
여기서 인텐트란 메세지 객체로, 어떤 행동을 수행할지에 대한 명령이나 작업에 필요한 데이터를 포함

3. 권한(Permission)
4. 앱에서 요구하는 하드웨어와 소프트웨어 특징

https://readystory.tistory.com/187

# 포그라운드 알림

애플리케이션 위에 잠시 동안 표시되는 알림이며 중요한 이벤트에 사용해야 한다.

Android와 iOS는 애플리케이션이 포그라운드에 있는 동안 알림을 처리할 때 다른 동작을 가지므로 개발하는 동안 이를 염두.

### 안드로이드 포그라운드 알림

main.dart 에 어느 정도 설명을 붙여놓았고  
Manifest 파일도 수정해야 한다.  
https://firebase.google.com/docs/cloud-messaging/android/client#manifest

# 백그라운드 메시지

애플리케이션이 백그라운드에 있는 동안 메시지를 처리하는 것은 약간 다릅니다.  
메시지는 onBackgroundMessage 핸들러를 통해 처리할 수 있습니다.

수신되면 격리(isolate) 가 생성되어 (android 만 해당, ios/MacOs 는 별도의 격리가 필요하지 않다) 애플리케이션이 실행되고 있지 않을 때도 메시지르 처리할 수 있다.

onBackgroundMeassage handler 를 처리할 때 몇 가지 유의할 점이 있다.

1. 익명함수가 아니어야 한다.
2. 최상위 함수여야 한다.

핸들러는 애플리케이션 컨텍스트 외부에서 자체 격리에서 실행되기 때문에 애플리케이션 상태를 업데이트하거나 로직에 영향을 미치는 UI를 실행할 수 없다.  
그러나 HTTP 요청과 같은 논리를 수행하고, IO 작업(예: 로컬 저장소 업데이트)을 수행하고, 다른 플러그인과 통신하는 등의 작업을 수행할 수 있다.

또한 가능한 한 빨리 논리를 완성하는 것이 좋다.  
길고 집중적인 작업을 실행하면 장치 성능에 영향을 미치고 OS가 프로세스를 종료할 수 있다.  
작업이 30초 이상 실행되면 장치가 자동으로 프로세스를 종료할 수 있다

### 낮은 우선 순위 메시지

위에서 언급했듯이 데이터 전용 메시지는 "낮은 우선 순위"로 분류됩니다.  
애플리케이션이 백그라운드에 있거나 종료되었거나 배터리 부족이나 현재 높은 CPU 사용량과 같은 다양한 기타 조건에 있는 경우 장치가 이러한 메시지를 조절하고 무시할 수 있습니다.

전달되는 데이터 전용 메시지에 의존해서는 안 됩니다.  
다음 번에 사용자가 앱을 열 때 데이터를 표시할 준비가 되도록 데이터를 미리 가져오는 등 애플리케이션의 중요하지 않은 기능을 지원하는 데만 사용해야 합니다.  
메시지가 전달되지 않으면 앱이 오픈에 계속 작동하고 데이터를 가져옵니다.

## ios APNs 인증 과정

1. identifier 클릭해서 앱 추가
2. `푸시노티피케이션`쪽 보면 `configure` 버튼 옆에 `인증서(Certificate)` 가 0개임
3. 인증서를 수동적으로 만들어줘야 한다
4. 인증서 --> `개발용 SSL Certificate` 와 `배포용 SSL Certificate` 이렇게 2개가 존재
5. 만드는 방법은 2개 다 동일
6. 암튼 선택하면 Upload a Certificate Signing Request 하라고 함
7. CSR(CertificateSigningRequest) 만드는 방법은 `KeyChain.app` 을 켜서 `키체인 접근` > `인증서 지원` > `인증 기관에서 인증서 요청` 클릭
8. CSR 파일을 업로드! > `continue` 하기
9. 그러면 `.cer 파일`을 다운로드 받을 수 있다.
10. 이 파일이 APNs 인증서.
11. 파이어베이스에서 `APNs 인증 키`와 `APNs 인증서` 를 업로드해야 함
    /////////////////////////// 인증서 ///////////////////////////
12. 인증서 파일을 클릭해서 `내보내기` 클릭 (이때 `p12 포맷`으로 설정)
13. p12 파일을 추출할 수 있음
14. 파이어베이스에서 APN 인증서 업로드할 때 13에서 추출한 파일을 업로드
    /////////////////////////// 인증키 ///////////////////////////
15. apple developer 사이트에서 keys 항목 클릭
16. key 생성
17. 파이어베이스에 `APN 인증 키` 부분에다가 업로드
18. https://www.youtube.com/watch?v=ytT65m_CjXU&list=LL&index=9 <-- 여기서 10분 6초부터 시작

??? 'push notification 이 없다' --> 프로비저닝 프로필 생성해야 하나 --> 맞다!  
https://medium.com/jinshine-%EA%B8%B0%EC%88%A0-%EB%B8%94%EB%A1%9C%EA%B7%B8/%EC%BD%94%EB%93%9C%EC%82%AC%EC%9D%B4%EB%8B%9D-%EC%9D%B8%EC%A6%9D%EC%84%9C-%ED%94%84%EB%A1%9C%EB%B9%84%EC%A0%80%EB%8B%9D-%ED%94%84%EB%A1%9C%ED%8C%8C%EC%9D%BC%EC%9D%B4%EB%9E%80-2bd2c652d00f

19. 프로비저닝 프로필 생성 후, xcode 에서 `'Automatically manage signing'` 을 해제해서 수동으로 import 해주면 된다.
20. 그 후 xcode 에서 `'push notification'` 과 `'background modes'` 를 선택해서 capabiility 를 활성화 시켜준다.  
    (알아둬야 할 것은 프로비저닝 프로필에서 `push notification` 을 활성화 시켜줬다고 해서 업데이트 된게 아니라 따로 xcode 에서 또 capability 를 활성화 시켜줘야 하는데
    그 이유는 `프로비저닝 프로필`은 현재 내 플젝에서 사용하겠다고 선택한 Capability 목록을 담고 있는게 아니라 `선택가능한/지원가능한 Capability 목록`을 담고 있기 때문이다.)  
    https://eunjin3786.tistory.com/373

## 프로비저닝 프로필

인증서를 발급받으면 애플에서 인증을 한 개발자가 된 개발자가 된 것.  
하지만 앱을 사인(sign)할 수 있도록 허락을 받은 상태이지, 기기가 또 나를 (개발자)를 신뢰하고 있는지를 알아야만 설치를 시켜줌  
지금 만든 애플 인증서와 iOS 기기를 연결시켜주어야 하는데 이것을 프로비저닝 프로파일이라고 함  
프로비저닝 프로파일은 `app id`, `certificate`, `device` 정보를 가지고 있어, iOS 기기 애플 인증서를 연결해주는 역할
