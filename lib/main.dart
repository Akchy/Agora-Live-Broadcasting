import 'package:flutter/material.dart';
import './screen/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './HomeScreen.dart';
import './screen/splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kristie',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          {return SplashPage();}
        if (!snapshot.hasData || snapshot.data == null)
          {return Login();}
        return HomeScreen();
      },
    );
  }
}

