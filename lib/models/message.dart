
import 'package:flutter/material.dart';

class Post {
  AssetImage image;
  String description;
  String user;
  String userPic;
  bool isLiked;
  bool isSaved;

  Post(this.image, this.user, this.userPic, this.description,  this.isLiked, this.isSaved);
}