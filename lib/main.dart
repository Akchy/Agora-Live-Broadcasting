
import 'package:agorartm/screen/home.dart';
import 'package:agorartm/screen/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './screen/Loading.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agora Live',
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {

  final MaterialColor blackColor = const MaterialColor(
      0xFF000000,
      const <int, Color>{
        50: const Color(0xFF000000),
        100: const Color(0xFF000000),
        200: const Color(0xFF000000),
        300: const Color(0xFF000000),
        400: const Color(0xFF000000),
        500: const Color(0xFF000000),
        600: const Color(0xFF000000),
        700: const Color(0xFF000000),
        800: const Color(0xFF000000),
        900: const Color(0xFF000000),
      },
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          {return LoadingPage();}
        if (!snapshot.hasData || snapshot.data == null)
          {return LoginScreen();}
        return MaterialApp(
          title: 'Agora Live',
          theme: ThemeData(
            primarySwatch: blackColor,
          ),
          home: HomePage(),
        );
      },
    );
  }
}

