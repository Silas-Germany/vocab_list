import 'package:flutter/material.dart';
import 'package:vocab_list/helper.dart';

import 'generated/l10n.dart';
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
