import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_theme_take_home_project/firebase_options.dart';
import 'package:firebase_theme_take_home_project/home.dart';
import 'package:firebase_theme_take_home_project/theme_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// *
/// Main entry point to the App
/// Before runApp() is called, we will initialise all bindings
/// 
Future<void> main() async {
  // Ensure all bindings are initialised before calling runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  
  // Connect to Firebase Remote Config, with a timeout of 10 seconds and a minimum fetch interval of 1 hour
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
  ));

  // Set default values for Firebase Remote Config
  await remoteConfig.setDefaults( {
    "default_themes": json.encode(defaultThemeOptions),
    "subscriber_themes": json.encode(subscriberThemeOptions)
  });
  
  await remoteConfig.fetchAndActivate();

  // Listen for changes to Firebase Remote Config and apply them to the app
  remoteConfig.onConfigUpdated.listen((event) async {
    await remoteConfig.activate();
  });
  
  var defaultThemes = json.decode(remoteConfig.getValue("default_themes").asString());
  var subscriberThemes = json.decode(remoteConfig.getValue("subscriber_themes").asString());

  runApp(MyApp(defaultThemes: defaultThemes, subscriberThemes: subscriberThemes,));
}

class MyAppState extends ChangeNotifier {
  dynamic currentTheme;

  void setCurrentTheme(selectedTheme) {
    currentTheme = selectedTheme;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.defaultThemes,
    required this.subscriberThemes
  });

  final List defaultThemes;
  final List subscriberThemes;

  /// * This widget is the root of your application.
  // It connects to the appState and provides it to the MaterialApp, so we can watch for changes to the appState from within the MaterialApp
  ///
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialHomeContainer(defaultThemes: defaultThemes, subscriberThemes: subscriberThemes,),
    );
  }
}

class MaterialHomeContainer extends StatelessWidget {
  const MaterialHomeContainer({super.key, required this.defaultThemes, required this.subscriberThemes});

  final List defaultThemes;
  final List subscriberThemes;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    // Set the default app theme to the first theme on the list default themes on app launch
    var currentTheme = defaultThemes.first;

    if (appState.currentTheme != null) {
      currentTheme = appState.currentTheme;
    }

    // This MaterialApp widget uses a theme created from the color in the applied theme
    return MaterialApp(
      title: 'Mobile Engineer Take-Home Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(int.parse(currentTheme['color']))),
        useMaterial3: true,
      ),
      home: Home(
        title: 'Mobile Engineer Take-Home Project',
        defaultThemes: defaultThemes,
        subscriberThemes: subscriberThemes,
      ),
    );
  }
}