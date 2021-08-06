import 'package:flutter/material.dart';
import 'package:regex_text/regex_text.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  final String text1 = 'This is my first #text_regex, check its color!';
  final String text2 = '"here" in @here has higher priority than @user_mention';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: RegexText(
                text1,
                defaultStyle: const TextStyle(color: Colors.black),
                regexes: [
                  RegexTextParam(
                    regex: Regexes.instagramHashtag,
                    style: const TextStyle(color: Colors.blueAccent),
                    onTap: (hashtag) => print('Hashtag: $hashtag'),
                  ),
                ],
              ),
            ),
            Center(
              child: RegexText(
                text2,
                defaultStyle: const TextStyle(color: Colors.black),
                regexes: [
                  RegexTextParam(
                    regex: Regexes.instagramMention,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  RegexTextParam(
                    regex: RegExp(r'here'),
                    style: const TextStyle(color: Colors.greenAccent),
                    priority: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
