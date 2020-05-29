import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        color:  Colors.black,
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 10.0),
                Text('Loading',style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 18.0
                ),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}