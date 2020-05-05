import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreClass{
  static final Firestore _db = Firestore.instance;
  static final reg_collection = 'liveuser';
  static void createLiveUser({name, id}) async{
    final snapShot = await _db.collection(reg_collection).document(name).get();
    if(snapShot.exists){
      await _db.collection(reg_collection).document(name).updateData({
        'name': name,
        'channel': id
      });
    } else {
      await _db.collection(reg_collection).document(name).setData({
        'name': name,
        'channel': id
      });
    }

  }

  static void deleteUser({username}) async{
    await _db.collection('liveuser').document(username).delete();
  }
}