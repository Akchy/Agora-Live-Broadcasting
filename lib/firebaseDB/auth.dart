import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:agorartm/firebaseDB/firestoreDB.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<String> signInWithGoogle() async {

  final googleSignInAccount = await googleSignIn.signIn();
  final googleSignInAuthentication =
  await googleSignInAccount.authentication;

  final credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final authResult = await _auth.signInWithCredential(credential);
  final user = authResult.user;
  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);
  final currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  return 'signInWithGoogle succeeded: $user';
}

void signOutGoogle() async{
  await googleSignIn.signOut();
  print('User Sign Out');
}

Future<int> registerUser({email, name, pass, username, image}) async{
  var _auth= FirebaseAuth.instance;
  try{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('username', username);
    var userNameExists = await FireStoreClass.checkUsername(username: username);
    if(!userNameExists) {
      return -1;
    }
    var result = await _auth.createUserWithEmailAndPassword(email: email, password: pass);

    var user = result.user;

    var info = UserUpdateInfo();
    info.displayName = name;
    info.photoUrl = '/';

    await user.updateProfile(info);
    await FireStoreClass.regUser(name: name,email: email,username: username,image: image);
    return 1;
  }
  catch(e){
    print(e.code);
    switch (e.code) {
      case 'ERROR_INVALID_EMAIL':
        return -2;
        break;
      case 'ERROR_EMAIL_ALREADY_IN_USE':
        return -3;
        break;
        /*
      case 'ERROR_USER_NOT_FOUND':
        authError = 'User Not Found';
        break;
      case 'ERROR_WRONG_PASSWORD':
        authError = 'Wrong Password';
        break;
        */
      case 'ERROR_WEAK_PASSWORD':
        return -4;
        break;
    }
    return 0;
  }
}

Future<void> logout() async{
  var _auth = FirebaseAuth.instance;
  final prefs = await SharedPreferences.getInstance();
  prefs.clear();
  _auth.signOut();
}

Future<int> loginFirebase(String email, String pass) async{
  var _auth = FirebaseAuth.instance;
  try {
    await FireStoreClass.getDetails(email:email);
    var result = await _auth.signInWithEmailAndPassword(
        email: email, password: pass);
    var user = result.user;
    if(user==null) {
      return null;
    }
    return 1;
  }
  catch(e)
  {
    switch (e.code) {
      case 'ERROR_WRONG_PASSWORD':
        return -1;
        break;
      case 'ERROR_INVALID_EMAIL':
        return -2;
        break;
      case 'ERROR_USER_NOT_FOUND':
        return -3;
        break;
      /*case 'ERROR_WRONG_PASSWORD':
        authError = 'Wrong Password';
        break;
      case 'ERROR_WEAK_PASSWORD':
        return -4;
        break;
       */
    }
    return null;
  }
}