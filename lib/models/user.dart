import 'post.dart';
import 'package:flutter/material.dart';

class User {
  String username;
  List<Post> posts;
  AssetImage profilePicture;
  List<User> followers;
  List<User> following;
  List<Post> savedPosts;
  bool me;


  User(this.username, this.me, this.profilePicture, this.following,);
}