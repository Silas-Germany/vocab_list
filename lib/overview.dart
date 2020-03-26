
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocab_list/helper.dart';

import 'generated/l10n.dart';

class Overview extends State<GeneralStatefulWidget> {
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(S.of(context).overview),
    ),
    body: Center(
      child: Text('Hello World'),
    ),
  );
}