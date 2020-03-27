import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocab_list/helper.dart';

import 'generated/l10n.dart';

class Overview extends State<GeneralStatefulWidget> {

  static const availableLanguageCode = ["en", "hi"];

  final firstLanguageCodeNotifier = ValueNotifier(availableLanguageCode[0]);
  final secondLanguageCodeNotifier = ValueNotifier(availableLanguageCode[1]);

  final wordList = {
    "घर": "house, home",
    "आदमी": "man, human",
  };

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
      children: <Widget>[
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GeneralStatefulWidget(() => LanguageSelector(firstLanguageCodeNotifier)),
            Text("->", style: TextStyle(fontSize: 24)),
            GeneralStatefulWidget(() => LanguageSelector(secondLanguageCodeNotifier)),
          ],
        ),
      ] + wordList.entries.map((word) => GestureDetector(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(word.key, style: TextStyle(fontSize: 20)),
            Text(word.value, style: TextStyle(fontSize: 20)),
          ],
        ),
        onLongPress: () {
          showDialog(context: context,
              child: AlertDialog(
                content: Text(S.of(context).deleteConfirmation(word.key)),
                actions: [
                  FlatButton(
                    child: Text(S.of(context).no),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text(S.of(context).yes),
                    onPressed: () {
                      setState(() {
                        wordList.remove(word.key);
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )
          );
        },
      )).toList() + [
        SizedBox(height: 16),
        RaisedButton(
          child: Text(S.of(context).newWord, style: TextStyle(fontSize: 24)),
          onPressed: () {},
        ),
        SizedBox(height: 24),
        RaisedButton(
          child: Text(S.of(context).export, style: TextStyle(fontSize: 20)),
          onPressed: () {},
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