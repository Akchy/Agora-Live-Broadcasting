import 'dart:async';

import 'package:agorartm/firebaseDB/auth.dart';
import 'package:agorartm/models/live.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/global.dart';
import '../models/post.dart';
import 'agora/host.dart';
import 'agora/join.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final FlareControls flareControls = FlareControls();
  final databaseReference = Firestore.instance;
  List<Live> list =[];
  bool ready =false;
  Live liveUser;
  var name;
  var image ='https://nichemodels.co/wp-content/uploads/2019/03/user-dummy-pic.png';
  var username;
  var postUsername;

  @override
  Widget build(BuildContext context) {
    return getMain();
  }




  @override
  void initState() {
    super.initState();
    loadSharedPref();
    list = [];
    liveUser = new Live(username: username,me: true,image:image );
    setState(() {
      list.add(liveUser);
    });
    dbChangeListen();
    /*var date = DateTime.now();
    var newDate = '${DateFormat("dd-MM-yyyy hh:mm:ss").format(date)}';
    */
  }


  Future<void> loadSharedPref() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'Jon Doe';
      username = prefs.getString('username') ?? 'jon';
      image = prefs.getString('image') ?? 'https://nichemodels.co/wp-content/uploads/2019/03/user-dummy-pic.png';
    });
  }

  void dbChangeListen(){
    databaseReference.collection('liveuser').orderBy("time",descending: true)
        .snapshots()
        .listen((result) {   // Listens to update in appointment collection

      setState(() {
        list = [];
        liveUser = new Live(username: username,me: true,image:image );
        list.add(liveUser);
      });
      result.documents.forEach((result) {
        setState(() {
          list.add(new Live(username: result.data['name'],image: result.data['image'],channelId:result.data['channel'],me: false));

        });
      });
    });

  }


  Widget getMain() {
    return Scaffold(
      appBar: AppBar(

        leading: Transform.translate(
          offset: Offset(-5, 0),
          child:  Icon(FontAwesomeIcons.camera,color: Colors.white,)
        ),
        titleSpacing: -10,
        title: Text('Agoragram', style: TextStyle(fontFamily: 'Billabong',fontSize: 28),),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Icon(FontAwesomeIcons.paperPlane,color: Colors.white,),
          ),
          /*Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () => logout(),
                child: Icon(
                    Icons.exit_to_app
                ),
              )
          ),*/
      ],

        backgroundColor: Colors.black87,
      ),
      body: Container(
        color: Colors.black,
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget> [
                Container(
                  height: 100,
                  child: getStories(),
                ),
                Divider(
                  height: 0,
                ),
                Column(
                  children: getPosts(context),
                ),
                SizedBox(height: 10,)
              ],
            )
          ],
        )
      ),
    );
  }

  Widget getStories() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: getUserStories()
    );
  }

  List<Widget> getUserStories() {
    List<Widget> stories = [];
    for (Live users in list) {
      stories.add(getStory(users));
    }
    return stories;
  }

  Widget getStory(Live users) {
    return Container(
      margin: EdgeInsets.all(5),
      child: Column(
        children: <Widget>[
          Container(
              height: 70,
              width: 70,
              child: GestureDetector(
                onTap: (){
                  if(users.me==true){
                    // Host function
                    onCreate(username: users.username, image: users.image);
                  }
                  else{
                    // Join function
                    onJoin(channelName: users.username,channelId: users.channelId,username: username, hostImage: users.image,userImage: image);
                  }
                },
                child: Stack(
                  alignment: Alignment(0, 0),
                  children: <Widget>[
                    !users.me ? Container(
                      height: 60,
                      width: 60,
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                colors: [
                                  Colors.indigo,
                                  Colors.blue,
                                  Colors.cyan
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight
                            )
                        ),
                      ),
                    ) : SizedBox(height: 0,),
                    Container(
                      height: 55.5,
                      width: 55.5,
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                      ),
                    ),
                    CachedNetworkImage(
                      imageUrl: users.image,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 52.0,
                        height: 52.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    users.me ? Container(
                        height: 55,
                        width: 55,
                        alignment: Alignment.bottomRight,
                        child: Container(
                          decoration: new BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),

                          child: Icon(
                            Icons.add,
                            size: 13.5,
                            color: Colors.white,
                          ),
                        )
                    ) :
                    Container(
                        height: 70,
                        width: 70,
                        alignment: Alignment.bottomCenter,

                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(
                              height: 17,
                              width: 25,
                              decoration: new BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(
                                        4.0) //         <--- border radius here
                                ),
                                gradient: LinearGradient(
                                    colors: [Colors.black, Colors.black],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight
                                ),
                              ),


                            ),
                            Container(
                                decoration: new BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          2.0) //         <--- border radius here
                                  ),
                                  gradient: LinearGradient(
                                      colors: [Colors.indigo, Colors.blueAccent],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight
                                  ),
                                ),

                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Text(
                                    'LIVE',
                                    style: TextStyle(
                                        fontSize: 7,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                )
                            ),
                          ],
                        )
                    )
                  ],
                ),
              )
          ),
          SizedBox(height: 3,),
          Text(users.username ?? '', style: textStyle)
        ],
      ),
    );
  }

  List<Widget> getPosts(BuildContext context) {
    List<Widget> posts = [];
    int index = 0;
    for (Post post in userPosts) {
      posts.add(getPost(context, post, index));
      index ++;
    }
    return posts;
  }

  Widget getPost(BuildContext context, Post post, int index) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      height: 30,
                      width: 30,
                      child: CircleAvatar(backgroundImage: AssetImage(post.userPic),),
                    ),
                    Text(post.user,style: TextStyle(color: Colors.white),)
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.more_vert,color: Colors.white,),
                  onPressed: () {

                  },
                )
              ],
            ),
          ),

          GestureDetector(
            onDoubleTap: () {
              setState(() {
                userPosts[index].isLiked = post.isLiked ? true : true;
              });
            },
            child: Container(
            constraints: BoxConstraints(
              maxHeight: 280
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: post.image
              )
            ),
                ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  post.isLiked?
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: GestureDetector(
                        onTap: (){
                          setState(() {
                            userPosts[index].isLiked = post.isLiked ? false : true;
                          });
                        },
                        child: Icon(
                          Icons.favorite,
                          size: 30,
                          color: Colors.lightBlue ,
                        )
                    ),
                  ):
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          userPosts[index].isLiked = post.isLiked ? false : true;

                        });
                      },
                        child: Icon(
                          Icons.favorite_border,
                          size: 30,

                          color: Colors.white,
                        )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 13),
                    child: Icon(
                      FontAwesomeIcons.comment,
                      size: 25,

                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 13),
                    child: Icon(
                      FontAwesomeIcons.paperPlane,
                      size: 23,

                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              Stack(
                    alignment: Alignment(0, 0),
                    children: <Widget>[
                      Icon(FontAwesomeIcons.bookmark, size: 28, color: Colors.white,),
                      IconButton(icon: Icon(Icons.bookmark), color: post.isSaved ? Colors.white : Colors.black,
                      onPressed: () {
                        setState(() {
                            userPosts[index].isSaved = post.isSaved ? false : true;

                          });
                      },)
                    ],
                  )
            ],
          ),

          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 15, right: 10),
                child: Text(
                  post.user,
                  style: textStyleBold,
                ),
              ),
              Text(
                post.description,
                style: textStyle,
              )
            ],
          ),
          SizedBox(height: 10,)

        ],
      )
    );
  }

  Future<void> onJoin({channelName,channelId, username, hostImage, userImage}) async {
    // update input validation
    if (channelName.isNotEmpty) {
      // push video page with given channel name
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinPage(
            channelName: channelName,
            channelId: channelId,
            username: username,
            hostImage: hostImage,
            userImage: userImage,
          ),
        ),
      );
    }
  }


  Future<void> onCreate({username, image}) async {
    // await for camera and mic permissions before pushing video page
    await _handleCameraAndMic();
    var date = DateTime.now();
    var currentTime = '${DateFormat("dd-MM-yyyy hh:mm:ss").format(date)}';
    // push video page with given channel name
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallPage(
          channelName: username,
          time: currentTime ,
          image: image,
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
