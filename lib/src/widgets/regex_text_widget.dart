import 'package:flutter/cupertino.dart';
import 'package:regex_text/src/models/regex_text_match.dart';
import 'package:regex_text/src/models/regex_text_param.dart';
import 'package:regex_text/src/models/regex_text_segment.dart';

class RegexText extends StatefulWidget {
  final String text;
  final TextStyle defaultStyle;
  final List<RegexTextParam> regexes;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool softWrap;
  final TextOverflow overflow;
  final double textScaleFactor;
  final int? maxLines;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const RegexText(
    this.text, {
    Key? key,
    this.regexes = const [],
    required this.defaultStyle,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor = 1.0,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegexTextState();
}

class _RegexTextState extends State<RegexText> {
  late List<RegexTextSegment> segments;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: widget.defaultStyle,
        children: segments
            .map((RegexTextSegment segment) => TextSpan(
                  text: segment.text,
                  style: segment.style,
                  recognizer: segment.gestureRecognizer == null ? null : segment.gestureRecognizer,
                ))
            .toList(),
      ),
    );
  }

  @override
  void initState() {
    segments = _getSegments(widget.text, widget.regexes, widget.defaultStyle);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant RegexText oldWidget) {
    _disposeSegments();
    segments = _getSegments(widget.text, widget.regexes, widget.defaultStyle);

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _disposeSegments();

    super.dispose();
  }

  List<RegexTextSegment> _getSegments(String text, List<RegexTextParam> regexes, TextStyle defaultStyle) {
    List<RegexTextSegment> segments = [];
    List<RegexTextMatch> matches = [];

    for (RegexTextParam param in regexes) {
      matches.addAll(param.regex.allMatches(text).map((RegExpMatch match) => RegexTextMatch(
            match: match,
            param: param,
          )));
    }

    if (matches.isEmpty) {
      segments.add(RegexTextSegment(text: text, style: defaultStyle));
    } else {
      matches.sort((RegexTextMatch m1, RegexTextMatch m2) => m1.match.start - m2.match.start);

      matches = _removeOverlappingMatches(matches);

      int pivot = 0;
      for (RegexTextMatch m in matches) {
        int matchStart = m.match.start;
        int matchEnd = m.match.end;

        if (pivot < m.match.start) {
          segments.add(RegexTextSegment(text: text.substring(pivot, matchStart), style: defaultStyle));
        }

        String matchedText = text.substring(matchStart, matchEnd);
        segments.add(RegexTextSegment(
          text: matchedText,
          style: m.param.style,
          onTap: m.param.onTap == null ? null : () => m.param.onTap!(matchedText),
        ));
        pivot = matchEnd;
      }

      if (pivot < text.length) {
        segments.add(RegexTextSegment(text: text.substring(pivot, text.length), style: defaultStyle));
      }
    }

    return segments;
  }

  List<RegexTextMatch> _removeOverlappingMatches(List<RegexTextMatch> matches) {
    List<int> removeIndexes = [];

    for (int i = 0; i < matches.length; i++) {
      for (int j = 0; j < matches.length; j++) {
        if (i != j) {
          if (matches[i].match.start <= matches[j].match.start && matches[j].match.start < matches[i].match.end) {
            if (matches[i].param.priority < matches[j].param.priority) {
              removeIndexes.add(i);
            } else {
              removeIndexes.add(j);
            }
          }
        }
      }
    }

    // removing duplicates
    removeIndexes = removeIndexes.toSet().toList();
    removeIndexes.sort((int a, int b) => b - a);

    for (int i in removeIndexes) {
      matches.removeAt(i);
    }

    return matches;
  }

  void _disposeSegments() {
    for (RegexTextSegment segment in segments) {
      segment.dispose();
    }
  }
}
