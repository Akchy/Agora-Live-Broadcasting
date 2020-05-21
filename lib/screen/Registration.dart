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
          backgroundColor: Colors.black87,
          title: Text('Registration'),
        ),
        body: Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment(0.0, 0.0),
            child: SingleChildScrollView(
                child:  Column(
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
                            style: TextStyle(fontSize: 18.0, color: Colors.black87),
                            decoration: InputDecoration(
                              filled: true,
                              errorText: invalidError ? 'Invalid Email' : existsError? 'Email Already Exists': null,
                              fillColor: Colors.white,
                              hintText: 'Email',
                              contentPadding:
                              const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(25.7),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(25.7),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
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
                            obscureText: true,
                            controller: _passController,
                            style: TextStyle(fontSize: 18.0, color: Colors.black87),
                            decoration: InputDecoration(
                              filled: true,
                              errorText: passwordError ? 'Weak Password! Min 6 characters' : null,
                              fillColor: Colors.white,
                              hintText: 'Password',
                              contentPadding:
                              const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(25.7),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(25.7),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
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
                            controller: _nameController,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(fontSize: 18.0, color: Colors.black87),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Full Name',
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
                    ),Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 30.0),
                        child: Theme(
                          data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                          child: TextField(
                            autofocus: false,
                            controller: _usernameController,
                            style: TextStyle(fontSize: 18.0, color: Colors.black87),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              errorText: usernameError ? 'Username is not unique' : null,
                              hintText: 'Username',
                              contentPadding:
                              const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(25.7),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(25.7),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
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

                    Text('*The username should be unique',
                      style: TextStyle(
                          color: Colors.yellowAccent,
                          letterSpacing: 1.0,
                          fontSize: 10.0
                      ),
                      //textCapitalization: TextCapitalization.words,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,

                          children: <Widget>[
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: BorderSide(color: Colors.black)
                              ),
                              color: Colors.pink,
                              padding: EdgeInsets.all(8.0),
                              child: Text('Signup',style: TextStyle(color: Colors.white,fontSize: 20.0),),
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
                            )
                          ],
                        )
                    )

                  ],
                ),
            ),
        ),
    );
  }
}
