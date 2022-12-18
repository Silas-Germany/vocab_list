import 'package:flutter/material.dart';

import 'helper.dart';
import 'overview.dart';

main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(context) => MaterialApp(
    home: GeneralStatefulWidget(() => Overview()),
  );
}
