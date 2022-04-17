# pushnotification

Firebaseの実装手順、動的に画像設定方法は今は非公開にしてます。

## Environment

```
FCN
 Android Embedding V2

Flutter
 sdk: ">=2.16.2 <3.0.0"
  
 pubspec.yaml
 firebase_messaging: 最新
 flutter_local_notifications: 最新
  
 URLから画像を使用する場合に使用
 path_provider:
 http:
```

## Document

#### *画像について imageurlの画像取得はドキュメント通りに実施しても対応できなかった*

ネットには画像を動的に変更する方法は見つからなかったが、対応方法を見つけたので動画挙動のみ公開。

AndroidとiOSの　PackageとbundleIdをCLIツールで認証させる。
```
$ dart pub global activate flutterfire_cli
$ export PATH="$PATH":"$HOME/.pub-cache/bin"
$ flutterfire configure

```

リンクの公式ドキュメント通り、Firebaseの登録、iOSの証明書等の登録は手順通り実施。　
コードはSampleコードで認証、読み込みできれば動作、確認できます。
https://firebase.flutter.dev/docs/messaging/overview/

## Example Android

通知バナーを表示する場合、設定画面から許可が必要。(実機ならパーミッション出るかもしれない)
パーミッション設定の対応未確認。
スケジュール通知予約可能。
通知をする場合の必須実装はmanifestなどにはない。
スリープモードでも動作確認


https://user-images.githubusercontent.com/16457165/163712672-a031f7bf-e9f0-4751-b13c-61322a9a7a54.mov



## Example iOS
設定画面などで許可は不要
バックグラウンドではiconは表示しませんでした。確認中
https://github.com/firebase/flutterfire/issues/8352#issuecomment-1100660846
スケジュール通知予約可能
スリープモードでも動作確認



https://user-images.githubusercontent.com/16457165/163712689-906fda2a-f11a-4488-99fb-476fe3be3081.mov




