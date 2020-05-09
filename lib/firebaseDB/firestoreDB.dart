import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class FireStoreClass{
  static final Firestore _db = Firestore.instance;
  static final live_collection = 'liveuser';
  static final user_collection = 'users';
  static final email_collection = 'user_email';

  static void createLiveUser({name, id}) async{
    final snapShot = await _db.collection(live_collection).document(name).get();
    if(snapShot.exists){
      await _db.collection(live_collection).document(name).updateData({
        'name': name,
        'channel': id
      });
    } else {
      await _db.collection(live_collection).document(name).setData({
        'name': name,
        'channel': id
      });
    }
  }

  static Future<bool> regUser({name, email, username}) async{
    final snapShot = await _db.collection(user_collection).document(username).get();
    if(snapShot.exists){
      return false;
    } else {
      await _db.collection(user_collection).document(username).setData({
        'name': name,
        'email': email,
        'username': username,
      });
      await _db.collection(email_collection).document(email).setData({
        'name': name,
        'email': email,
        'username': username,
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', name);
      await prefs.setString('username', username);
      return true;
    }
  }

  static void deleteUser({username}) async{
    await _db.collection('liveuser').document(username).delete();
  }

  static void getDetails({email}) async{
    var document = await Firestore.instance.document('user_email/$email').get();
    //print(document.data['username']);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', document.data['name']);
    await prefs.setString('username', document.data['username']);

  }
}