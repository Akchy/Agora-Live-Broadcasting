import 'package:agora_flutter_quickstart/firebaseDB/auth.dart';
import 'package:flutter/material.dart';

class Registration extends StatelessWidget{
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _nameController = TextEditingController();
  final _imageController = TextEditingController();




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
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Username',
                    ),
                    controller: _imageController,
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

                        final pass = _passController.text.toString().trim();
                        final email = _emailController.text.toString().trim();
                        final name = _nameController.text.toString().trim();
                        final url = _imageController.text.toString().trim();

                       var result = await registerUser(email, pass, name, url);
                       if(result){
                         Navigator.pop(context);

                       }
                       else{
                         print('Error');
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
