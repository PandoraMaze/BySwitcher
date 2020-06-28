import 'package:byswitcher/byswitcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'base/page_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pandora Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends BasePageWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends BasePageState<MyHomePage> {
  var _switchState;

  @override
  String getTitle() {
    // TODO: implement getTitle
    return 'Switcher Demo';
  }

  @override
  void initParams() {
    super.initParams();
  }

  @override
  buildBody() => Container(
        padding: EdgeInsets.all(16.0),
        color: Color(0xFFF9FCF8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BySwitcher.loading(
              thumbColor: Colors.white,
              state: _switchState,
              onChanged: (targetState) {
                setState(() {
                  _switchState = targetState;
                });
              },
              onLoading: (targetState) => Future.delayed(
                Duration(seconds: 3),
                () => setState(() {
                  _switchState = targetState;
                }),
              ),
            ),
            SizedBox(height: 12.0),
            BySwitcher.loading(
              thumbColor: Colors.white,
              activeTrackColor: Color(0xFF2AD182),
              inactiveTrackColor: Color(0xFFE7E6E9),
              withBorder: false,
              state: _switchState,
              inactiveFlag: Icon(Icons.clear),
              activeFlag: Icon(Icons.check, color: Colors.white),
              progressImg: Image.asset(
                'images/ic_loading_circle.webp',
                alignment: Alignment.center,
              ),
              onChanged: (targetState) {
                setState(() {
                  _switchState = targetState;
                });
              },
              onLoading: (targetState) => Future.delayed(
                Duration(seconds: 2),
                () => setState(() {
                  _switchState = targetState;
                }),
              ),
            ),
            SizedBox(height: 12.0),
            BySwitcher(
              width: 166,
              thumbColor: Colors.white,
              activeTrackColor: Colors.cyan,
              inactiveTrackColor: Color(0xFFE7E6E9),
              thumb: Icon(Icons.sentiment_neutral, color: Colors.cyan),
              inactiveFlag: Icon(Icons.sentiment_dissatisfied, color: Colors.red),
              activeFlag: Icon(Icons.sentiment_satisfied, color: Colors.white),
              state: _switchState,
              onChanged: (targetState) {
                setState(() {
                  _switchState = targetState;
                });
              },
            ),
          ],
        ),
      );
}
