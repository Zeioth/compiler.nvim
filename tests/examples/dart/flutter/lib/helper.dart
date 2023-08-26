import 'package:flutter/material.dart';

class HelloWorldApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Hello, World!'),
        ),
        body: Center(
          child: Text(
            'Hello, Flutter World!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

