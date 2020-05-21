import 'dart:async';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:agorartm/screen/splash.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import '../utils/settings.dart';
import 'package:wakelock/wakelock.dart';

class JoinPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String channelName;
  final int channelId;
  final String username;



  /// Creates a call page with given channel name.
  const JoinPage({Key key, this.channelName, this.channelId, this.username}) : super(key: key);


  @override
  _JoinPageState createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  bool loading = true;
  bool completed = false;
  static final _users = <int>[];
  bool muted = true;

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
    await AgoraRtcEngine.muteLocalAudioStream(muted);
    await AgoraRtcEngine.enableLocalVideo(!muted);


  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      Wakelock.enable();
    };


    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {


        if(uid==widget.channelId){
          setState(() {
            completed=true;
            Future.delayed(const Duration(milliseconds: 1500), () async{
              await Wakelock.disable();
              Navigator.pop(context);
            });
          });
        }
        /*Fluttertoast.showToast(
            msg: '$uid',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.lightGreen,
            fontSize: 16.0
        );*/
        _users.remove(uid);
    };


  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget>  list = [];
    //user.add(widget.channelId);
    _users.forEach((int channelId) {
      if(channelId == widget.channelId) {
        list.add(AgoraRenderWidget(channelId));
      }
    });
    if(list.isEmpty) {

      setState(() {
        loading=true;
      });
    }
    else{
      setState(() {
        loading=false;
      });
    }

    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }


  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    return (loading==true)&&(completed==false)?
      SplashPage():Container(
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


  Future<bool> _willPopCallback() async {
    await Wakelock.disable();
    _leaveChannel();
    _logout();
    return true;
    // return true if the route to be popped
  }

  Widget _ending(){
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Text('The Live has ended\n\nThank you',
          style: TextStyle(
            fontSize: 25.0,letterSpacing: 1.5,
            color: Colors.pinkAccent,
          ),
        )
      ),
    );
  }

  Widget _liveText(){
    return Container(
      alignment: Alignment.topRight,
      child: Padding(
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
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0,horizontal: 8.0),
                child: Text('LIVE',style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _username(){
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0,horizontal: 8.0),
              child: Text('${widget.channelName}',style: TextStyle(color: Colors.white,fontSize: 20,fontStyle: FontStyle.italic),),
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
              child: (completed==true)?_ending():Stack(
                children: <Widget>[
                  _viewRows(),
                  _username(),
                  _liveText(),
                  _buildSendChannelMessage(),
                  _panel(),
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
                        textInputAction: TextInputAction.go,
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
      _log('${widget.username}: $text');
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
      _log('${widget.username}: $text');
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
    await _client.login(null, widget.username );
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

