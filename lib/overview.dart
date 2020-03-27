import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocab_list/add_word.dart';
import 'package:vocab_list/helper.dart';

import 'generated/l10n.dart';

class Overview extends State<GeneralStatefulWidget> {

  static const availableLanguageCode = [
    "en",
    "hi",
    "de",
    "ru",
    "zh-TW",
  ];

  final languageCode1Notifier = ValueNotifier(availableLanguageCode[1]);
  final languageCode2Notifier = ValueNotifier(availableLanguageCode[0]);
  MapEntry<String, String> get languageCodes => MapEntry(languageCode1Notifier.value, languageCode2Notifier.value);

  final wordList = {
    "घर": "house; home",
    "आदमी": "man; human",
  };

  @override
  void initState() {
    super.initState();
    languageCode1Notifier.addListener(() {
      if (languageCode1Notifier.value == languageCode2Notifier.value) {
        final sameCode = languageCode1Notifier.value;
        languageCode2Notifier.value = availableLanguageCode.firstWhere((code) => code != sameCode);
      } else setState(() {});
    });
    languageCode2Notifier.addListener(() {
      if (languageCode1Notifier.value == languageCode2Notifier.value) {
        final sameCode = languageCode1Notifier.value;
        languageCode1Notifier.value = availableLanguageCode.firstWhere((code) => code != sameCode);
      } else setState(() {});
    });
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(S.of(context).overview),
    ),
    body: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GeneralStatefulWidget(() => LanguageSelector(languageCode1Notifier)),
              Text("->", style: TextStyle(fontSize: 24)),
              GeneralStatefulWidget(() => LanguageSelector(languageCode2Notifier)),
            ],
          ),
          Table(
            columnWidths: const {0: FlexColumnWidth(60), 1: FlexColumnWidth(100)},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey, width: 1)),
            children: wordList.entries.map((word) => TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      menuPopup(word),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(word.key, style: TextStyle(fontSize: 20)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(word.value, style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
            ).toList(),
          ),
          const SizedBox(height: 16),
          RaisedButton(
            child: Text(S.of(context).newWord, style: const TextStyle(fontSize: 24)),
            onPressed: () async {
              final word = await Navigator.of(context).push<MapEntry<String, String>>(MaterialPageRoute(
                  builder: (context) => GeneralStatefulWidget(() => EditWord(languageCodes))
              ));
              if (word != null) wordList[word.key] = word.value;
            },
          ),
          const SizedBox(height: 24),
          RaisedButton(
            child: Text(S.of(context).export, style: const TextStyle(fontSize: 20)),
            onPressed: () {},
          ),
        ],
      ),
    ),
  );

  Widget menuPopup(MapEntry<String, String> word) {
    return PopupMenuButton<int>(
      child: Icon(Icons.settings),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 0,
          child: Text("Edit"),
        ),
        PopupMenuItem(
          value: 1,
          child: Text("Delete"),
        ),
      ],
      onSelected: (item) {
        switch(item) {
          case 0: {
            Navigator.of(context).push<MapEntry<String, String>>(MaterialPageRoute(
                builder: (context) => GeneralStatefulWidget(() => EditWord(languageCodes, word: word))
            )).then((newWord) {
              if (newWord != null) {
                wordList.remove(word.key);
                wordList[newWord.key] = newWord.value;
              };
            });
          }
          break;
          case 1: {

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
          }
          break;
        }
      },
    );
  }
}

class LanguageSelector extends State<GeneralStatefulWidget> {

  ValueNotifier<String> languageCodeNotifier;

  LanguageSelector(this.languageCodeNotifier);

  static const dropDownStyle = TextStyle(fontSize: 22);

  @override Widget build(BuildContext context) {
    final availableLanguages = {
      "en": S.of(context).english,
      "hi": S.of(context).hindi,
      "de": S.of(context).german,
      "ru": S.of(context).russish,
      "zh-TW": S.of(context).cantoneese,
    };
    return DropdownButton<String>(
      value: languageCodeNotifier.value,
      items: availableLanguages.entries.map((language) => DropdownMenuItem(
        value: language.key,
        child: Text(language.value, style: dropDownStyle),
      )).toList(),
      onChanged: (String value) {
        languageCodeNotifier.value = value;
      },
    );
  }
}