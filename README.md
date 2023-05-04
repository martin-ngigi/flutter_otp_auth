# flutter_otp_auth

- [Youtube tutorial](https://www.youtube.com/watch?v=GoIREQjWiWk&t=3014s)
- [Link to images](https://www.freepik.com/free-photos-vectors/login)

# SHA-1 Generation for android Method 1 (NB: MOST RECOMMENDED WAY)
1. Right click on 'gradlew' and go to 'Open in Terminal' This file is found under {{YOUR PROJECT}}/android/gradlew
- OR while inside project directory, navigate to android directory i.e.
```
cd android
```
2. Type in the following command(on mac).
```
gradlew signingReport
```
- or If did not work first try second command(on windows):
```
./gradlew signingReport
```
- Inside project directory, run following command to clean and get:
```
flutter clean
flutter pub get
```
- If facing any issues generating SHAH-1, comment on packages in pubspec.yml then pub get, afterwards uncomment
- Add The SHA-1 to firebase project by pressing 'add fingerprint' in firebase

## Obtaining package name in iOS:
- In iOS the package name is the bundle identifier in Info.plist. which is found in Runner.xcodeproj/project.pbxproj
PRODUCT_BUNDLE_IDENTIFIER = com.example.flutterOtpAuth;

- on M1 Mac, run following commands to install gem / cocoapods:
```
cd ios
sudo arch -x86_64 gem install ffi
or
sudo arch -x86_64 pod install
or
sudo arch -x86_64 pod install --repo-update
```
- if above dont work, run :
```
brew install cocoapods
```