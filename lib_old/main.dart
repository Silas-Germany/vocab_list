import 'package:flutter/material.dart';

import 'generated/l10n.dart';
import 'helper.dart';
import 'overview.dart';

main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(context) => MaterialApp(
    localizationsDelegates: [S.delegate],
    supportedLocales: S.delegate.supportedLocales,
    home: GeneralStatefulWidget(() => Overview()),
  );
}
