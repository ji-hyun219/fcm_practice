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

6. 로컬 노티피케이션 및 백그라운드 패키지 설치

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
