import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

Future<bool> registerUser(String email, String pass, String name, String url) async{
  var _auth= FirebaseAuth.instance;
  try{

    var result = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
    var user = result.user;

    var info = UserUpdateInfo();
    info.displayName = name;
    info.photoUrl = url;

    await user.updateProfile(info);
    return true;
  }
  catch(e){
    print(e);
    return false;
  }
}
Future<FirebaseUser> loginFirebase(String email, String pass) async{
  var _auth = FirebaseAuth.instance;

  try {
    var result = await _auth.signInWithEmailAndPassword(
        email: email, password: pass);
    var user = result.user;
    return user;
  }
  catch(e)
  {
    print(e);
    return null;
  }
}