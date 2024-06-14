# Application for Mobile Engineer Role at LightForth - Take Home Project

## About this project
This Flutter application take-home project dynamically supports multiple themes using Firebase Remote Configuration and tracks user subscriptions using Firebase Realtime Database.

## Setup Instructions

This project was built using **flutter** and has been fully configured to work on the Android platform.

To setup and run this project locally, follow the instructions below:

1. Clone this repository to your local machine.
2. Run `flutter pub get` to install dependencies.
3. Run `flutter run` to run the application.
4. If you want to run the application on a physical device or an emulator, you will need to create a Firebase project and add the `google-services.json` file to the `android/app` directory.

## App Publishing
For the distribution of this app to testers, `fastlane` has been added to the project. To publish a new build to Firebase App Distribution for Android, run the following commands:

```
cd android
fastlane android_beta_app
cd ../
```

## App Features
This app has a list of 8 themes in total. 3 default themes and 5 subscriber themes.
The default themes are all available for use by default, without any extra action needed, while the subscriber themes are only available after you subscribe as a user.

To subscribe as a user and gain access to the subscriber themes, you need to click the subscription button from the home page.

Clicking this button subscribes you as a user and saves the new expiry time for your subscription in **Firebase Realtime Database**.

Each subscription session TTL is set to **10 minutes**.

## Resources
- [Flutter](https://flutter.dev/)
- [Firebase Realtime Database](https://firebase.google.com/docs/database?hl=en)
- [Firebase Remote Config](https://firebase.google.com/docs/remote-config)


For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
