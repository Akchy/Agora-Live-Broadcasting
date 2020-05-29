import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class HeartAnim extends StatelessWidget {
  final double top;
  final double left;
  final double opacity;

  HeartAnim(this.top, this.left,this.opacity);
  static final RandomColor _randomColor = RandomColor();

  Color _color = _randomColor.randomColor(
  );
  Widget build(BuildContext context) {
    final random = math.Random();
    final confetti = Container(
      child: Opacity(
          opacity:0.95,
          child: Icon(Icons.favorite,color: _color.withOpacity(opacity),size: (18 + random.nextInt(18)).toDouble(),)),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
    );
    return Positioned(
      bottom: top,
      right: left,
      child: confetti,
    );
  }
}
