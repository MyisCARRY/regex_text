import 'package:flutter/cupertino.dart';
import 'package:regex_text/src/models/regex_text_match.dart';
import 'package:regex_text/src/models/regex_text_param.dart';
import 'package:regex_text/src/models/regex_text_segment.dart';

/// Applies TextStyle and Callback to every phrase matching any RegExp given in [regexes]
class RegexText extends StatefulWidget {
  const RegexText(
    this.text, {
    required this.defaultStyle,
    this.regexes = const [],
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
    Key? key,
  }) : super(key: key);

  /// String that will be checked against given [RegExp] in [regexes] and adjusted with corresponding [TextStyle]
  final String text;

  /// [TextStyle] which will be applied to all text that was not match in any [RegExp] from [regexes]
  final TextStyle defaultStyle;

  /// [RegexTextParam] that will find matching phrases in [text] and apply corresponding styles and onTap callbacks
  final List<RegexTextParam> regexes;


  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  /// The directionality of the text.
  ///
  /// This decides how [textAlign] values like [TextAlign.start] and
  /// [TextAlign.end] are interpreted.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the [text] is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// Defaults to the ambient [Directionality], if any. If there is no ambient
  /// [Directionality], then this must not be null.
  final TextDirection? textDirection;

  /// Whether the text should break at soft line breaks.
  ///
  /// If false, the glyphs in the text will be positioned as if there was unlimited horizontal space.
  final bool softWrap;

  /// How visual overflow should be handled.
  final TextOverflow overflow;

  /// The number of font pixels for each logical pixel.
  ///
  /// For example, if the text scale factor is 1.5, text will be 50% larger than
  /// the specified font size.
  final double textScaleFactor;

  /// An optional maximum number of lines for the text to span, wrapping if necessary.
  /// If the text exceeds the given number of lines, it will be truncated according
  /// to [overflow].
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  final int? maxLines;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale.
  ///
  /// It's rarely necessary to set this property. By default its value
  /// is inherited from the enclosing app with `Localizations.localeOf(context)`.
  ///
  /// See [RenderParagraph.locale] for more information.
  final Locale? locale;

  /// {@macro flutter.painting.textPainter.strutStyle}
  final StrutStyle? strutStyle;

  /// {@macro flutter.painting.textPainter.textWidthBasis}
  final TextWidthBasis textWidthBasis;

  /// {@macro flutter.dart:ui.textHeightBehavior}
  final TextHeightBehavior? textHeightBehavior;

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
            .map((segment) => TextSpan(
                  text: segment.text,
                  style: segment.style,
                  recognizer: segment.gestureRecognizer,
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

    for (final param in regexes) {
      matches.addAll(param.regex.allMatches(text).map((match) => RegexTextMatch(
            match: match,
            param: param,
          )));
    }

    if (matches.isEmpty) {
      segments.add(RegexTextSegment(text: text, style: defaultStyle));
    } else {
      matches.sort((m1, m2) => m1.match.start - m2.match.start);

      matches = _removeOverlappingMatches(matches);

      var pivot = 0;
      for (final m in matches) {
        var matchStart = m.match.start;
        var matchEnd = m.match.end;

        if (pivot < m.match.start) {
          segments.add(RegexTextSegment(text: text.substring(pivot, matchStart), style: defaultStyle));
        }

        final matchedText = text.substring(matchStart, matchEnd);
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

    for (var i = 0; i < matches.length; i++) {
      for (var j = 0; j < matches.length; j++) {
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
    removeIndexes.sort((a, b) => b - a);

    removeIndexes.forEach((i) {
      matches.removeAt(i);
    });

    return matches;
  }

  void _disposeSegments() {
    for (final segment in segments) {
      segment.dispose();
    }
  }
}
