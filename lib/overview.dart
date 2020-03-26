import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocab_list/helper.dart';

import 'generated/l10n.dart';

class Overview extends State<GeneralStatefulWidget> {

  static const availableLanguageCode = ["en", "hi"];

  final firstLanguageCodeNotifier = ValueNotifier(availableLanguageCode[0]);
  final secondLanguageCodeNotifier = ValueNotifier(availableLanguageCode[1]);

  @override
  void initState() {
    super.initState();
    firstLanguageCodeNotifier.addListener(() {
      if (firstLanguageCodeNotifier.value == secondLanguageCodeNotifier.value) {
        final sameCode = firstLanguageCodeNotifier.value;
        secondLanguageCodeNotifier.value = availableLanguageCode.firstWhere((code) => code != sameCode);
      } else setState(() {});
    });
    secondLanguageCodeNotifier.addListener(() {
      if (firstLanguageCodeNotifier.value == secondLanguageCodeNotifier.value) {
        final sameCode = firstLanguageCodeNotifier.value;
        firstLanguageCodeNotifier.value = availableLanguageCode.firstWhere((code) => code != sameCode);
      } else setState(() {});
    });
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

  LanguageSelector(this.languageCodeNotifier);

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