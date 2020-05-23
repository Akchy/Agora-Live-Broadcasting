import 'dart:async';

import 'package:agorartm/firebaseDB/auth.dart';
import 'package:agorartm/screen/agora/join.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'agora/host.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();
  int channel;

  static final databaseReference = Firestore.instance;
  var name='Jon Doe', username='jon';

  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    loadCounter();
  }

  Future<void> loadCounter() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'Jon Doe';
      username = prefs.getString('username') ?? 'jon';
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () => logout(),
                child: Icon(
                    Icons.exit_to_app
                ),
              )
          ),
        ],
        backgroundColor: Colors.black87,
        title: Text("$name's Profile"),
      ),
      body: Container(
        color: Colors.black,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment(0.0, 0.0),
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10.0),
        child: Column(
          children: <Widget>[
            RaisedButton(
              onPressed: onCreate,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
              padding: EdgeInsets.all(0.0),
              child: Ink(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.purple, Colors.pink],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30.0)
                ),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
                  alignment: Alignment.center,
                  child: Text(
                    'Create Live',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Live Users',style: TextStyle(color: Colors.pinkAccent,fontSize: 30,fontFamily:'Oswald'),),
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection('liveuser').snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError)
                        return new Text('Error: ${snapshot.error}');
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return new Text('Loading...');
                        default:
                          return Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    Colors.purpleAccent, Colors.pinkAccent
                                  ],
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(10.0))
                            ),
                            child: new ListView(
                              shrinkWrap: true,
                              children: snapshot.data.documents.map((
                                  DocumentSnapshot document) {
                                return new ListTile(
                                  onTap: ()=> onJoin(document['name']),
                                  title: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: new Text(document['name'],style: TextStyle(color: Colors.white,fontSize: 20),),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                      }
                    }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onJoin(channelName) async {
    // update input validation
    if (channelName.isNotEmpty) {
      await getChannel(channelName);
      // push video page with given channel name
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinPage(
            channelName: channelName,
            channelId: channel,
            username: username,
          ),
        ),
      );
    }
  }

  Future<void> getChannel(channelName) async{
    await databaseReference
        .collection('liveuser')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) {
        var v = f.data;
        if(v['name'] == channelName) {
          channel = int.parse(f.data['channel'].toString());
        }
      });
    });
  }

  Future<void> onCreate() async {
    // await for camera and mic permissions before pushing video page
    await _handleCameraAndMic();
    // push video page with given channel name
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallPage(
          channelName: username,
        ),
      ),
    );

  }


  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }
}
