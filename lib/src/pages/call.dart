import 'dart:async';
import 'package:agora_flutter_quickstart/firebaseDB/firestoreDB.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import '../utils/settings.dart';
import 'package:wakelock/wakelock.dart';

class CallPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String channelName;

  /// Creates a call page with given channel name.
  const CallPage({Key key, this.channelName}) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  static final _users = <int>[];
  String channel_name;

  bool muted = false;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
  }

  Future<void> initialize() async {

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    await AgoraRtcEngine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    await AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(APP_ID);
    await AgoraRtcEngine.enableVideo();
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) async{

      final documentId = widget.channelName;
      channel_name= documentId;
      await FireStoreClass.createLiveUser(name: documentId,id: uid);
      // The above line create a document in the firestore with username as documentID

      await Wakelock.enable();
      // This is used for Keeping the device awake. Its now enabled

      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        final info = 'userOffline: $uid';
        _users.remove(uid);
      });
    };
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final list = [
      AgoraRenderWidget(0, local: true, preview: true),
    ];
    _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

/*  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }*/

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    return Container(
        child: Column(
          children: <Widget>[_videoView(views[0])],
        ));

    /*switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }*/

  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  /// Info panel to show logs
  /*Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
*/
  bool pop = false;
  Future<void> _showDialog() async {
    // flutter defined function
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text('Alert Dialog title'),
          content: Text('Alert Dialog body'),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text("Don't"),
              onPressed: () {
                pop=false;
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
            ),
            FlatButton(
              child: Text('Close'),
              onPressed: () async {
                await Wakelock.disable();
                Navigator.of(context).pop();
                pop = true;
              },
            ),


          ],
        );
      },
    );
  }

  void _onCallEnd(BuildContext context) async {
    await _showDialog();
    if(pop){
      await FireStoreClass.deleteUser(username: channel_name);
      //await Firestore.instance.collection('liveuser').document(channel_name).delete();
      Navigator.pop(context);
    }
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    AgoraRtcEngine.switchCamera();
  }

  Future<bool> _willPopCallback() async {
    await _showDialog();
    if(pop) {
      await FireStoreClass.deleteUser(username: channel_name);
      //await Firestore.instance.collection('liveuser').document(channel_name).delete();
      return true;
    }// return true if the route to be popped
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child:Scaffold(
          appBar: AppBar(
            title: Text("${widget.channelName}'s Live"),
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: Stack(
              children: <Widget>[
                _viewRows(),
                _toolbar(),
              ],
            ),
          ),
        ),
        onWillPop: _willPopCallback
    );
  }
}
