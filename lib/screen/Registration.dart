import 'package:agorartm/firebaseDB/auth.dart';
import 'package:flutter/material.dart';

class Registration extends StatefulWidget{
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _emailController = TextEditingController();

  final _passController = TextEditingController();

  final _nameController = TextEditingController();

  final _usernameController = TextEditingController();

  bool usernameError = false;
  bool invalidError = false;
  bool existsError = false;
  bool passwordError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Registration'),
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
                        errorText: invalidError ? 'Invalid Email' : existsError? 'Email Already Exists': null,
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
                      errorText: passwordError ? 'Weak Password! Min 6 characters' : null,
                      hintText: 'Password',
                    ),
                    controller: _passController,
                    obscureText: true,
                    autofocus: false,
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
                      hintText: 'Full Name',


                    ),
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
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
                      errorText: usernameError ? 'Username is not unique' : null,
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Username',
                    ),
                    controller: _usernameController,
                    //textCapitalization: TextCapitalization.words,
                  ),
                  SizedBox(height: 6,),

                  Text('*The username should be unique',
                    style: TextStyle(
                      color: Colors.grey[850],
                      letterSpacing: 1.0,
                      fontSize: 10.0
                    ),
                    //textCapitalization: TextCapitalization.words,
                  ),


                  SizedBox(height: 16,),


                  Container(
                    width: double.infinity,
                    child: FlatButton(
                      child: Text('Register'),
                      textColor: Colors.white,
                      padding: EdgeInsets.all(16),
                      onPressed: () async{

                        usernameError=false;
                        passwordError=false;
                        invalidError=false;
                        existsError=false;
                        final pass = _passController.text.toString().trim();
                        final email = _emailController.text.toString().trim();
                        final name = _nameController.text.toString().trim();
                        final username = _usernameController.text.toString().trim();

                         var result = await registerUser(email, pass, name, username);
                         switch(result) {
                           case 1:
                             Navigator.pop(context);
                             break;
                           case -1:
                             setState(() {
                               usernameError = true;
                             });
                             break;
                           case -2:
                             setState(() {
                               invalidError = true;
                             });
                             break;
                           case -3:
                             setState(() {
                               existsError = true;
                             });
                             break;
                           case -4:
                             setState(() {
                               passwordError = true;
                             });
                             break;
                         }
                       },

                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 32,),

                  Container(
                    width: double.infinity,
                    child: FlatButton(
                      child: Text('Login Here'),
                      textColor: Colors.white,
                      padding: EdgeInsets.all(16),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.green[400],
                    ),
                  )
                ],
              ),
            ),
          ),
        )
    );
  }
}
