import 'package:agorartm/firebaseDB/auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './Registration.dart';

class Login extends StatefulWidget{
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();

  bool invalidError = false;
  bool user_not_found= false;
  final _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height,
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 30.0),
                      child: Theme(
                        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                        child: TextField(
                          autofocus: false,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: 22.0, color: Colors.deepPurple[900]),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            errorText: invalidError? 'Invalid Email': user_not_found? 'Email or Password is wrong': null,
                            hintText: 'Email',
                            contentPadding:
                            const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(25.7),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(25.7),
                            ),
                          ),
                        ),
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 30.0),
                      child: Theme(
                        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                        child: TextField(
                          autofocus: false,
                          controller: _passController,
                          obscureText: true,
                          style: TextStyle(fontSize: 22.0, color: Colors.deepPurple[900]),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Password',
                            contentPadding:
                            const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(25.7),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(25.7),
                            ),
                          ),
                        ),
                      )
                  ),

                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: <Widget>[
                          RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            color: Colors.blue[700],
                            child: Text('Login',style: TextStyle(color: Colors.white,fontSize: 20.0),),
                            onPressed: () async{

                              invalidError=false;
                              user_not_found=false;
                              final pass = _passController.text.toString().trim();
                              final email = _emailController.text.toString().trim();
                              var user = await loginFirebase(email, pass);
                              switch(user){
                                case -1:
                                  setState(() {
                                    invalidError = true;
                                  });
                                  break;
                                case -2:
                                case -3:
                                  setState(() {
                                    user_not_found=true;
                                  });
                              }
                              if(user == null){
                                print('Error');
                              }
                              /*Fluttertoast.showToast(
                            msg: "Your email is $email and password is $pass",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.lightGreen,
                            fontSize: 16.0
                        );*/
                            },
                          ),
                          RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                side: BorderSide(color: Colors.indigo[900])
                            ),
                            color: Colors.white,
                            child: Text('Signup',style: TextStyle(color: Colors.blue[900],fontSize: 20.0),),
                            onPressed: () {

                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Registration()
                              ));

                              /*Fluttertoast.showToast(
                            msg: "Wait a min!!! ",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.lightGreen,
                            fontSize: 16.0
                        );*/
                            },
                          )
                        ],
                      )
                  )

                ],
              ),
            ),
          )
        )
    );
  }
}
