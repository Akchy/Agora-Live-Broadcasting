import 'dart:async';
import 'package:agorartm/firebaseDB/firestoreDB.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import '../../utils/settings.dart';
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
  String channelName;

  bool muted = false;
  bool _isLogin = true;
  bool _isInChannel = true;

  final _channelMessageController = TextEditingController();

  final _infoStrings = <String>[];

  AgoraRtmClient _client;
  AgoraRtmChannel _channel;

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
    _createClient();
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
      channelName= documentId;
      FireStoreClass.createLiveUser(name: documentId,id: uid);
      // The above line create a document in the firestore with username as documentID

      await Wakelock.enable();
      // This is used for Keeping the device awake. Its now enabled

      setState(() {
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
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
  }



  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
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
                  horizontal: 3,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),

                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

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
      _logout();
      _leaveChannel();
      FireStoreClass.deleteUser(username: channelName);
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
      _logout();
      _leaveChannel();
      FireStoreClass.deleteUser(username: channelName);
      //await Firestore.instance.collection('liveuser').document(channel_name).delete();
      return true;
    }
    return false;// return true if the route to be popped
  }

  Widget _endCall(){
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            elevation: 2.0,
            padding: const EdgeInsets.all(15.0),
            child: Text('END',style: TextStyle(color: Colors.pink,fontSize: 20,fontWeight: FontWeight.bold),),
          ),
        ],
      ),
    );
  }

  Widget _liveText(){
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Colors.pink, Colors.red
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(8.0))
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0,horizontal: 8.0),
              child: Text('LIVE',style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child:SafeArea(
          child: Scaffold(
            body: Center(
              child: Stack(
                children: <Widget>[
                  _viewRows(),// Video Widget
                  _endCall(),
                  _liveText(),
                  _buildSendChannelMessage(), // send message
                  _panel(), // view message
                ],
              ),
            ),
          ),
        ),
        onWillPop: _willPopCallback
    );
  }
// Agora RTM

  Widget _buildSendChannelMessage() {
    if (!_isLogin || !_isInChannel) {
      return Container();
    }
    return Container(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0,),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0,0,0,0),
                  child: new TextField(
                    cursorColor: Colors.red,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                    style: TextStyle(color: Colors.white),
                    controller: _channelMessageController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Comment',
                      hintStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.white)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.white)
                      ),
                    )
                  ),
                )
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 4.0, 0),
              child: MaterialButton(
                minWidth: 0,
                onPressed: _toggleSendChannelMessage,
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                color: Colors.pinkAccent[400],
                padding: const EdgeInsets.all(12.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 0),
              child: MaterialButton(
                minWidth: 0,
                onPressed: _onToggleMute,
                child: Icon(
                  muted ? Icons.mic_off : Icons.mic,
                  color: muted ? Colors.white : Colors.pinkAccent[400],
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                color: muted ? Colors.pinkAccent[400] : Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0, 8.0, 0),
              child: MaterialButton(
                minWidth: 0,
                onPressed: _onSwitchCamera,
                child: Icon(
                  Icons.switch_camera,
                  color: Colors.pinkAccent[400],
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                color: Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
            )
          ]
        ),
      ),
    );
  }

  void _logout() async {
    try {
      await _client.logout();
      _log('Logout success.');
    } catch (errorCode) {
      _log('Logout error: ' + errorCode.toString());
    }
  }



  void _leaveChannel() async {
    try {
      await _channel.leave();
      _log('Leave channel success.');
      _client.releaseChannel(_channel.channelId);
      _channelMessageController.text = null;

    } catch (errorCode) {
      _log('Leave channel error: ' + errorCode.toString());
    }
  }

  void _toggleSendChannelMessage() async {
    String text = _channelMessageController.text;
    if (text.isEmpty) {
      return;
    }
    try {
      _channelMessageController.clear();
      await _channel.sendMessage(AgoraRtmMessage.fromText(text));
      _log('${widget.channelName}: $text');
    } catch (errorCode) {
      _log('Send channel message error: ' + errorCode.toString());
    }
  }

  void _sendMessage(text) async {
    if (text.isEmpty) {
      return;
    }
    try {
      _channelMessageController.clear();
      await _channel.sendMessage(AgoraRtmMessage.fromText(text));
      _log('${widget.channelName}: $text');
    } catch (errorCode) {
      _log('Send channel message error: ' + errorCode.toString());
    }
  }

  void _createClient() async {
    _client =
    await AgoraRtmClient.createInstance('b42ce8d86225475c9558e478f1ed4e8e');
    _client.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      _log(peerId + ": " + message.text);
    };
    _client.onConnectionStateChanged = (int state, int reason) {
      if (state == 5) {
        _client.logout();
        _log('Logout.');
        setState(() {
          _isLogin = false;
        });
      }
    };
    await _client.login(null, widget.channelName );
    _channel = await _createChannel(widget.channelName);
    await _channel.join();
  }

  Future<AgoraRtmChannel> _createChannel(String name) async {
    AgoraRtmChannel channel = await _client.createChannel(name);
    channel.onMemberJoined = (AgoraRtmMember member) {
      _log(
          'Member joined: ' + member.userId);
    };
    channel.onMessageReceived =
        (AgoraRtmMessage message, AgoraRtmMember member) {
      _log(member.userId + ':-  ' + message.text);
    };
    return channel;
  }

  void _log(String info) {
    print(info);
    setState(() {
      _infoStrings.insert(0, info);
    });
  }
}
