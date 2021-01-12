// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '记事本',
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('添加待提醒事项'),
        ),
        body: Center(
          child: RandomWorlds(),
        ),
      ),
    );
  }
}

class RandomWorlds extends StatefulWidget {
  @override
  _RandomWorldsState createState() => _RandomWorldsState();
}

class _RandomWorldsState extends State<RandomWorlds> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Column(
        children: [
          new Row(children: [
            new Expanded(
              child: TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  icon: Icon(
                    Icons.bookmark_border,
                    size: 25,
                  ),
                  labelText: '提醒事項',
                  helperText: '',
                ),
                autofocus: false,
              ),
            )
          ]),

          new Row(children: [],),
        ],
      ),
    );
  }
}
