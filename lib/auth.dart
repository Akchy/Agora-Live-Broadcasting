import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<String> signInWithGoogle() async {

  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
  await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;
  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);
  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  return 'signInWithGoogle succeeded: $user';
}

void signOutGoogle() async{
  await googleSignIn.signOut();
  print("User Sign Out");
}

Future<bool> registerUser(String email, String pass, String name, String url) async{
  FirebaseAuth _auth= FirebaseAuth.instance;
  try{

    AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
    FirebaseUser user = result.user;

    UserUpdateInfo info = UserUpdateInfo();
    info.displayName = name;
    info.photoUrl = url;

    user.updateProfile(info);
    return true;
  }
  catch(e){
    print(e);
    return false;
  }
}
Future<FirebaseUser> loginFirebase(String email, String pass) async{
  FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    AuthResult result = await _auth.signInWithEmailAndPassword(
        email: email, password: pass);
    FirebaseUser user = result.user;
    return user;
  }
  catch(e)
  {
    print(e);
    return null;
  }
}