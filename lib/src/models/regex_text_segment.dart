import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

class RegexTextSegment {
  final String text;
  final TextStyle style;
  late final GestureRecognizer? gestureRecognizer;

  RegexTextSegment({
    required this.text,
    required this.style,
    void Function()? onTap,
  }) {
    if (onTap != null) {
      gestureRecognizer = TapGestureRecognizer()..onTap = onTap;
    }else{
      gestureRecognizer = null;
    }
  }

  void dispose(){
    gestureRecognizer?.dispose();
  }
}
