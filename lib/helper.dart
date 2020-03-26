import 'package:flutter/widgets.dart';

class GeneralStatefulWidget extends StatefulWidget {
  final State<GeneralStatefulWidget> Function() generateState;
  const GeneralStatefulWidget(this.generateState);
  @override State<StatefulWidget> createState() => generateState();
}
