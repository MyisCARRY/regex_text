import 'package:flutter/material.dart';

class RegexTextParam {
  RegexTextParam({
    required this.regex,
    required this.style,
    this.priority = 1,
    this.onTap,
  });

  /// [RegExp] by which widget will match phrases and adjust its [style] and add [onTap] gesture detection.
  final RegExp regex;

  /// [TextStyle] which will be applied to all phrases matching [regex].
  final TextStyle style;

  /// When there are two or more overlapping [RegExpMatch], this number decides which one will be used and rest
  /// will be removed. The higher priority [RegExpMatch] will stay and lower will be removed.
  final int priority;

  /// Callback, which should be applied to each phrase matching [regex]. It returns [String] text
  /// that is matched by [regex].
  final void Function(String)? onTap;
}
