import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gradient_text/gradient_text.dart';

class SplashScreen extends StatefulWidget{

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  var image;
  @override
  void initState() {
    super.initState();
    image = Image.asset('assets/images/agora.jpg');
    startTime();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(image.image, context);
  }

  startTime() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed('/HomeScreen');
  }


  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/images/insta.png"), context);
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[900],
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height-100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 80,
                    width: 80,
                    child: Center(
                      child: Image.asset('assets/images/insta.png'),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('from', style: TextStyle(color: Colors.white,fontSize: 13),),
                  SizedBox(height: 4,),
                  GradientText('FACEBOOK',
                      gradient: LinearGradient(
                          colors: [Colors.orange,  Colors.redAccent[700], Colors.pink]),
                      style: TextStyle(fontSize: 16,),
                      textAlign: TextAlign.center,
                  ),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}