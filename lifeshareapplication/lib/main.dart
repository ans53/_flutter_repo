// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lifeshareapplication/model/data_flow.dart';
import 'package:lifeshareapplication/splashscreen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'http_client.dart'; // Import the HTTP client

Color primaryColor = const Color.fromARGB(255, 253, 82, 8);
Color darkPrimaryColor = const Color.fromARGB(255, 1, 46, 69);
Color backgroundColor = const Color.fromARGB(255, 228, 247, 253);
Color accentColor = const Color.fromARGB(255, 26, 195, 190);
Color buttonColor = Colors.amber;
late String appName;
late String packageName;
late String version;
late String buildNumber;

Future<void> init() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  appName = packageInfo.appName;
  packageName = packageInfo.packageName;
  version = packageInfo.version;
  buildNumber = packageInfo.buildNumber;

    print('App Name: $appName');
  print('Package Name: $packageName');
  print('Version: $version');
  print('Build Number: $buildNumber');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBcqEOgzPvzSEqA9RnrWAfcJapSmsA1N4g',
    appId: '1:1030884467571:android:f43e6851ee099ed3a89b06',
    messagingSenderId: '1030884467571',
    projectId: 'lifeshare-873ea',
    databaseURL: 'https://lifeshare-873ea-default-rtdb.firebaseio.com',
    storageBucket: 'lifeshare-873ea.appspot.com',
    ),
  );
  await init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => UuidProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),

      ],
      child: const MyApp(),
    ),
  );

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    client.close(); // Close the shared HTTP client
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeShare',
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkPrimaryColor,
          brightness: Brightness.dark,
        ),
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: darkPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: accentColor,
          titleTextStyle: const TextStyle(color: Color.fromARGB(255, 1, 46, 69),fontSize: 25,fontWeight: FontWeight.w800),
        ),
        scaffoldBackgroundColor: backgroundColor,
        cardColor: accentColor,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: primaryColor,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
