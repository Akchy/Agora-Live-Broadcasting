import 'dart:async';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:agorartm/firebaseDB/firestoreDB.dart';
import 'package:agorartm/models/message.dart';
import 'package:agorartm/screen/Loading.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/settings.dart';
import 'package:wakelock/wakelock.dart';
import 'dart:math' as math;
import 'package:agorartm/screen/HearAnim.dart';

class JoinPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String channelName;
  final int channelId;
  final String username;
  final String hostImage;
  final String userImage;



  /// Creates a call page with given channel name.
  const JoinPage({Key key, this.channelName, this.channelId, this.username,this.hostImage,this.userImage}) : super(key: key);


  @override
  _JoinPageState createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  bool loading = true;
  bool completed = false;
  static final _users = <int>[];
  bool muted = true;
  int userNo = 0;
  var userMap ;
  bool heart = false;
  bool requested = false;

  bool _isLogin = true;
  bool _isInChannel = true;

  final _channelMessageController = TextEditingController();

  final _infoStrings = <Message>[];

  AgoraRtmClient _client;
  AgoraRtmChannel _channel;

  //Love animation
  final _random = math.Random();
  Timer _timer;
  double _height = 0.0;
  int _numConfetti = 10;
  var len;

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
    userMap = {widget.username: widget.userImage};
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
    await AgoraRtcEngine.enableLocalAudio(!muted);
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
    return Expanded(child: ClipRRect(child: view));
  }


  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    return (loading==true)&&(completed==false)?
      //LoadingPage()
        LoadingPage()
        :Container(
          child: Column(
            children: <Widget>[_videoView(views[0])],
        ));
  }

  void popUp() async{
    setState(() {
      heart=true;
    });
    Timer(Duration(seconds: 4), () =>
    {
      _timer.cancel(),
      setState(() {
        heart=false;
      })
    });
    _timer = Timer.periodic(Duration(milliseconds: 125), (Timer t) {
      setState(() {
        _height += _random.nextInt(20);
      });
    });
  }

  Widget heartPop(){
    final size = MediaQuery.of(context).size;
    final confetti = <Widget>[];
    for (var i = 0; i < _numConfetti; i++) {
      final height = _random.nextInt(size.height.floor());
      final width = 20;
      confetti.add(HeartAnim(height % 200.0,
          width.toDouble(),1));
    }


    return Container(
      child: Padding(
        padding: const EdgeInsets.only(bottom:20),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            height: 400,
            width: 200,
            child: Stack(
              children: confetti,
            ),
          ),
        ),
      ),
    );
  }


  /// Info panel to show logs
  Widget _messageList() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
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
                child: (_infoStrings[index].type=='join')? Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CachedNetworkImage(
                        imageUrl: _infoStrings[index].image,
                        imageBuilder: (context, imageProvider) => Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const  EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        child: Text(
                          '${_infoStrings[index].user} joined',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ):
                (_infoStrings[index].type=='message')?
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CachedNetworkImage(
                        imageUrl: _infoStrings[index].image,
                        imageBuilder: (context, imageProvider) => Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const  EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            child: Text(
                              _infoStrings[index].user,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          SizedBox(height: 5,),
                          Padding(
                            padding: const  EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            child: Text(
                              _infoStrings[index].message,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
                    :null,
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
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    return true;
    // return true if the route to be popped
  }

  Widget _ending(){
    return Container(
      color: Colors.black.withOpacity(.7),
      child: Center(
        child: Container(
          width: double.infinity,
          color: Colors.grey[700],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text('The Live has ended',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Colors.indigo, Colors.blue
                      ],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(4.0))
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0,horizontal: 8.0),
                  child: Text('LIVE',style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left:5),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.6),
                        borderRadius: BorderRadius.all(Radius.circular(4.0))
                    ),
                    height: 28,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(FontAwesomeIcons.eye,color: Colors.white,size: 13,),
                          SizedBox(width: 5,),
                          Text('$userNo',style: TextStyle(color: Colors.white,fontSize: 11),),
                        ],
                      ),
                    )
                ),
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
            CachedNetworkImage(
              imageUrl: widget.hostImage,
              imageBuilder: (context, imageProvider) => Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: imageProvider, fit: BoxFit.cover),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0,horizontal: 8.0),
              child: Text(
                '${widget.channelName}',
                style: TextStyle(
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black,
                        offset: Offset(0, 1.3),
                      ),
                    ],
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget requestedWidget(){
    return Container(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.center,
          spacing: 0,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20, ),
              width: 130,
              alignment: Alignment.center,
              child: Stack(
                children: <Widget>[
                  Container(
                    width: 130,
                    alignment: Alignment.centerLeft,
                    child: Stack(
                      alignment: Alignment(0, 0),
                      children: <Widget>[
                        Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        CachedNetworkImage(
                          imageUrl: widget.hostImage,
                          imageBuilder: (context, imageProvider) => Container(
                            width: 70.0,
                            height: 70.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 130,
                    alignment: Alignment.centerRight,
                    child: Stack(
                      alignment: Alignment(0, 0),
                      children: <Widget>[
                        Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        CachedNetworkImage(
                          imageUrl: widget.userImage,
                          imageBuilder: (context, imageProvider) => Container(
                            width: 70.0,
                            height: 70.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                '${widget.channelName} Wants You To Be In This Live Video.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20,top: 0,bottom:20,right: 20,),
              child: Text(
                'Anyone can watch, and some of your followers may get notified.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              width: double.maxFinite,
              child: RaisedButton(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text('Go Live with ${widget.channelName}',style: TextStyle(color: Colors.white),),
                ),
                elevation: 2.0,
                color: Colors.blue[400],
                onPressed: (){
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              width: double.maxFinite,
              child: RaisedButton(

                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text('Decline',style: TextStyle(color: Colors.pink[300]),),
                ),
                elevation: 2.0,
                color: Colors.transparent,
                onPressed: (){
                  setState(() {
                    requested=false;
                  });
                },
              ),
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
            body: Container(
              color: Colors.black,
              child: Center(
                child: (completed==true)?_ending():Stack(
                  children: <Widget>[
                    _viewRows(),
                    if(completed==false)_bottomBar(),
                    _username(),
                    _liveText(),
                    if(completed==false)_messageList(),
                    if(heart == true && completed==false) heartPop(),
                    if(requested == true) requestedWidget(),

                    //_ending()
                  ],
                ),
              ),
            ),
          ),
        ),
        onWillPop: _willPopCallback
    );
  }
  // Agora RTM


  Widget _bottomBar() {
    if (!_isLogin || !_isInChannel) {
      return Container();
    }
    return Container(
      alignment: Alignment.bottomRight,
      child: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.only(left:8,top:5,right: 8,bottom: 5),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0,0,0,0),
                      child: new TextField(
                          cursorColor: Colors.blue,
                          textInputAction: TextInputAction.go,
                          onSubmitted: _sendMessage,
                          style: TextStyle(color: Colors.white,),
                          controller: _channelMessageController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Comment',
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                borderSide: BorderSide(color: Colors.white)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                borderSide: BorderSide(color: Colors.white)
                            ),
                          )
                      ),
                    )
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
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
                    color: Colors.blue[400],
                    padding: const EdgeInsets.all(12.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: MaterialButton(
                    minWidth: 0,
                    onPressed: ()
                    async{
                      popUp();
                    await _channel.sendMessage(AgoraRtmMessage.fromText('m1x2y3z4p5t6l7k8'));
                    },
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    padding: const EdgeInsets.all(12.0),
                  ),
                ),
              ]
          ),
        ),
      ),
    );
  }

  void _logout() async {
    try {
      await _client.logout();
     // _log('Logout success.');
    } catch (errorCode) {
      //_log('Logout error: ' + errorCode.toString());
    }
  }


  void _leaveChannel() async {
    try {
      await _channel.leave();
      //_log('Leave channel success.');
      _client.releaseChannel(_channel.channelId);
      _channelMessageController.text = null;

    } catch (errorCode) {
      //_log('Leave channel error: ' + errorCode.toString());
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
      _log(user: widget.username, info: text,type: 'message');
    } catch (errorCode) {
      //_log('Send channel message error: ' + errorCode.toString());
    }
  }

  void _sendMessage(text) async {
    if (text.isEmpty) {
      return;
    }
    try {
      _channelMessageController.clear();
      await _channel.sendMessage(AgoraRtmMessage.fromText(text));
      _log(user: widget.channelName, info:text,type: 'message');
    } catch (errorCode) {
      //_log('Send channel message error: ' + errorCode.toString());
    }
  }

  void _createClient() async {
    _client =
    await AgoraRtmClient.createInstance('b42ce8d86225475c9558e478f1ed4e8e');
    _client.onMessageReceived = (AgoraRtmMessage message, String peerId)  async{
      var img = await FireStoreClass.getImage(username: peerId);
      userMap.putIfAbsent(peerId, () => img);
      _log(user: peerId, info: message.text, type: 'message');
    };
    _client.onConnectionStateChanged = (int state, int reason) {
      if (state == 5) {
        _client.logout();
       // _log('Logout.');
        setState(() {
          _isLogin = false;
        });
      }
    };
    await _client.login(null, widget.username );
    _channel = await _createChannel(widget.channelName);
    await _channel.join();
    var len;
    _channel.getMembers().then((value) {
      len = value.length;
      setState(() {
        userNo= len-1 ;
      });
    });


  }

  Future<AgoraRtmChannel> _createChannel(String name) async {
    AgoraRtmChannel channel = await _client.createChannel(name);
    channel.onMemberJoined = (AgoraRtmMember member) async{
      var img = await FireStoreClass.getImage(username: member.userId);
      userMap.putIfAbsent(member.userId, () => img);

      _channel.getMembers().then((value) {
        len = value.length;
        setState(() {
          userNo= len-1 ;
        });
      });

      _log(info: 'Member joined: ',  user: member.userId,type: 'join');
    };
    channel.onMemberLeft = (AgoraRtmMember member) {
      var len;
      _channel.getMembers().then((value) {
        len = value.length;
        setState(() {
          userNo= len-1 ;
        });
      });

    };
    channel.onMessageReceived =
        (AgoraRtmMessage message, AgoraRtmMember member) async {
          var img = await FireStoreClass.getImage(username: member.userId);
          userMap.putIfAbsent(member.userId, () => img);
          _log(user: member.userId, info: message.text, type: 'message');
    };
    return channel;
  }

  void _log({String info,String type,String user}) {
    if(type=='message' && info.contains('m1x2y3z4p5t6l7k8')){
      popUp();
    }else {
      Message m;
      var image = userMap[user];
      if(info.contains('d1a2v3i4s5h6')){
        var mess = info.split(' ');
        if(mess[1]==widget.username){
          /*m = new Message(
              message: 'working', type: type, user: user, image: image);*/
          setState(() {
            //_infoStrings.insert(0, m);
            requested = true;
          });
        }
      }
      else {
        m = new Message(
            message: info, type: type, user: user, image: image);
        setState(() {
          _infoStrings.insert(0, m);
        });
      }
    }
  }
}

