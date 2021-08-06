import 'package:regex_text/src/models/regex_text_param.dart';

class RegexTextMatch {
  final RegExpMatch match;
  final RegexTextParam param;

  RegexTextMatch({
    required this.param,
    required this.match,
  });
}
