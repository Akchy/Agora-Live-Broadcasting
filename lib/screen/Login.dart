import 'package:agora_flutter_quickstart/firebaseDB/auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './Registration.dart';

class Login extends StatelessWidget{
  final _emailController = TextEditingController();
  final _passController = TextEditingController();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(32),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  TextFormField(
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.grey[200])
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.grey[300])
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        hintText: 'Email ID',


                    ),
                    controller: _emailController,
                    //textCapitalization: TextCapitalization.words,
                  ),

                  SizedBox(height: 16,),

                  TextFormField(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[200])
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300])
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Password',


                    ),
                    controller: _passController,
                    obscureText: true,
                    autofocus: false,
                    //textCapitalization: TextCapitalization.words,
                  ),

                  SizedBox(height: 16,),

                  Container(
                    width: double.infinity,
                    child: FlatButton(
                      child: Text('LOGIN'),
                      textColor: Colors.white,
                      padding: EdgeInsets.all(16),
                      onPressed: () async{

                        final pass = _passController.text.toString().trim();
                        final email = _emailController.text.toString().trim();
                        var user = await loginFirebase(email, pass);
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
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 32,),

                  Container(
                    width: double.infinity,
                    child: FlatButton(
                      child: Text('Register'),
                      textColor: Colors.white,
                      padding: EdgeInsets.all(16),
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
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 32,),

                  Container(
                    width: double.infinity,
                    child: FlatButton(
                      child: Text('Google'),
                      textColor: Colors.white,
                      padding: EdgeInsets.all(16),
                      onPressed:() async {
                        await signInWithGoogle();
                        /*Fluttertoast.showToast(
                            msg: "Wait a min!!! $res",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.lightGreen,
                            fontSize: 16.0
                        );*/

                        Navigator.pop(context);
                      },
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
}
