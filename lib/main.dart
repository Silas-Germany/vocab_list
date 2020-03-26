import 'package:flutter/material.dart';

main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(context) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: Text('Hello World'),
      ),
    ),
  );
}
