import 'package:flutter/material.dart';
import 'user.dart';
import 'post.dart';


TextStyle textStyle = new TextStyle(fontFamily: 'Gotham',color: Colors.white);
TextStyle textStyleBold = new TextStyle(fontFamily: 'Gotham', fontWeight: FontWeight.bold, color: Colors.white);
TextStyle textStyleLigthGrey = new TextStyle(fontFamily: 'Gotham', color: Colors.grey);

Post post1 = new Post(new AssetImage('assets/images/photo_1.jpeg'), user, "My first post", DateTime.now(), [follower1, follower2, follower3], false, false);
final User user = new User('agora', false, AssetImage('assets/images/agora.jpg'),  [
  follower1,
  follower2,
  follower3,
  follower4,
  follower5,
  follower6
]);
User follower1 = new User('akarsh', true, AssetImage('assets/images/follower3.jpeg'), [], );
User follower2 = new User('murshid', false, AssetImage('assets/images/follower2.jpg'),  [], );
User follower3 = new User('william_du', false,AssetImage('assets/images/their_profile.jpeg'), [], );
User follower4 = new User('vick', false,AssetImage('assets/images/profile3.png'), [],  );
User follower5 = new User('Vishal', false,AssetImage('assets/images/profile6.jpg'), [],  );
User follower6 = new User('peter_griffin', false,AssetImage('assets/images/profile4.png'), [], );
List<Post> userPosts = [
  new Post(new AssetImage('assets/images/welcome.jpg'), user, "My first post", DateTime.now(), [follower1, follower2, follower3, follower4, follower5, follower6], false, false),
  new Post(new AssetImage('assets/images/post2.jpg'), follower1, "This is such a great post though", DateTime.now(), [user, follower2, follower3, follower4, follower5], false, false),
 ];


 String title = "Instagram";