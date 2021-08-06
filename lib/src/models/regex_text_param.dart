import 'package:flutter/material.dart';

class RegexTextParam {
  final RegExp regex;
  final TextStyle style;
  final int priority;
  final void Function(String)? onTap;

  RegexTextParam({
    required this.regex,
    required this.style,
    this.priority = 1,
    this.onTap,
  });
}
