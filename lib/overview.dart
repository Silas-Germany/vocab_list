import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocab_list/helper.dart';

import 'generated/l10n.dart';

class Overview extends State<GeneralStatefulWidget> {

  final firstLanguageCodeNotifier = ValueNotifier("en");
  final secondLanguageCodeNotifier = ValueNotifier("hi");

  @override
  void initState() {
    super.initState();
    firstLanguageCodeNotifier.addListener(() => setState(() {}));
    secondLanguageCodeNotifier.addListener(() => setState(() {}));
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(S.of(context).overview),
    ),
    body: Column(
      children: [
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GeneralStatefulWidget(() => LanguageSelector(firstLanguageCodeNotifier)),
            Text("->", style: TextStyle(fontSize: 24)),
            GeneralStatefulWidget(() => LanguageSelector(secondLanguageCodeNotifier)),
          ],
        ),
      ],
    ),
  );
}

class LanguageSelector extends State<GeneralStatefulWidget> {

  ValueNotifier<String> languageCodeNotifier;
  static const availableLanguageCode = ["en", "hi"];

  LanguageSelector(this.languageCodeNotifier) :
        assert(availableLanguageCode.contains(languageCodeNotifier.value));

  static const dropDownStyle = TextStyle(fontSize: 22);

  @override Widget build(BuildContext context) =>
      DropdownButton<String>(
        value: languageCodeNotifier.value,
        items: [
          DropdownMenuItem(
            value: "en",
            child: Text(S.of(context).english, style: dropDownStyle),
          ),
          DropdownMenuItem(
            value: "hi",
            child: Text(S.of(context).hindi, style: dropDownStyle),
          ),
        ],
        onChanged: (String value) {
          languageCodeNotifier.value = value;
        },
      );
}