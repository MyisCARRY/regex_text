import 'package:regex_text/src/models/regex_text_param.dart';

class RegexTextMatch {
  RegexTextMatch({
    required this.param,
    required this.match,
  });

  final RegExpMatch match;
  final RegexTextParam param;
}
