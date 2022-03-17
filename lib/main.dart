import 'package:flutter/material.dart';
import 'package:loyaltycard/auth/kyc.dart';
import 'home.dart';
import 'loader.dart';
import 'auth/login.dart';
import 'auth/registration.dart';
import 'package:loyaltycard/rewards/rewardsceen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/kyc.dart';
import 'auth/profile.dart';

void main() {
  runApp(const MyApp());
}

class Palette {
  static const MaterialColor kToDark = const MaterialColor(
    0xff081a69, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    const <int, Color>{
      50: const Color(0xff081a69), //10%
      100: const Color(0xff081a69), //20%
      200: const Color(0xff081a69), //30%
      300: const Color(0xff081a69), //40%
      400: const Color(0xff081a69), //50%
      500: const Color(0xff081a69), //60%
      600: const Color(0xff081a69), //70%
      700: const Color(0xff081a69), //80%
      800: const Color(0xff081a69), //90%
      900: const Color(0xff081a69), //100%
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'loader',
      theme: ThemeData(
        primarySwatch: Palette.kToDark,
        primaryColor: Color(0xff081a69),
        backgroundColor: Colors.grey,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            onPrimary: Colors.white,

            // minimumSize: Size(36, 26),
            // padding: EdgeInsets.symmetric(horizontal: 16),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
        ),
      ),
      routes: {
        'loader': (context) => Loader(),
        'home': (context) => MyHomePage(),
        'login': (context) => Login(),
        'registration': (context) => Registration(),
        'kyc': (context) => Kyc(),
        'profile': (context) => UserProfile(),
      },
    );
  }
}
