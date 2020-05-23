
import 'package:flutter/material.dart';
import 'user.dart';

class Post {
  AssetImage image;
  String description;
  User user;
  List<User> likes;
  DateTime date;
  bool isLiked;
  bool isSaved;

  Post(this.image, this.user, this.description, this.date, this.likes, this.isLiked, this.isSaved);
}