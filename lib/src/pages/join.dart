import 'dart:async';
import 'package:agora_flutter_quickstart/screen/splash.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/settings.dart';
import 'package:wakelock/wakelock.dart';

class JoinPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String channelName;
  final int channelId;



  /// Creates a call page with given channel name.
  const JoinPage({Key key, this.channelName, this.channelId}) : super(key: key);


  @override
  _JoinPageState createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  bool loading = true;
  bool completed = false;
  static final _users = <int>[];
  static final user = <int>[];
  bool muted = true;


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
  }*/

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
      Navigator.pop(context);
    }
  }
  Future<bool> _willPopCallback() async {
    await _showDialog();
    if(pop) {
      return true;
    }// return true if the route to be popped
  }

  Widget _ending(){
    return Center(
      child: Text('The Live has ended\nThank you',
        style: TextStyle(
          fontSize: 25.0,letterSpacing: 1.5,
          color: Colors.red[900],
        ),
      )
    );
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
            child: (completed==true)?_ending():Stack(
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

