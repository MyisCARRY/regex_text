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
  final String text1 = 'czincz\n'
      '#_czincz_czincz_\n'
      '#czincz.czincz\n'
      '#czincz..czincz\n'
      '#.czincz #czincz.\n'
      '#czincz#czincz_czincz\n'
      ' #czinczinczinczinczinczinczinczinczincz\n'
      '@____czincz___czincz____\n'
      '@czincz.czincz\n'
      '@czincz..czincz\n'
      '@.czincz @czincz.\n'
      '@czincz@czincz_czincz\n'
      ' @czinczinczinczinczinczinczinczinczincz\n'
      '@here\n'
      'czincz';

  final String text2 = 'czincz';

  bool text = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            text = !text;
          });
        },
      ),
      body: SafeArea(
        child: RegexText(
          text ? text1 : text2,
          defaultStyle: TextStyle(color: Colors.black),
          regexes: [
            RegexTextParam(
              regex: Regexes.instagramHashtag,
              style: TextStyle(color: Colors.blueAccent),
              onTap: (String hashtag) => print('Hashtag: $hashtag'),
            ),
            RegexTextParam(
              regex: Regexes.instagramMention,
              style: TextStyle(color: Colors.greenAccent),
              onTap: (String mention) => print('User mention: $mention'),
            ),
            RegexTextParam(
              regex: RegExp(r'here'),
              style: TextStyle(color: Colors.redAccent),
              priority: 2,
              onTap: (String hashtag) => print('Helloooooo!!!'),
            ),
          ],
        ),
      ),
    );
  }
}
