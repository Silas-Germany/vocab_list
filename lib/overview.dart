import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocab_list/add_word.dart';
import 'package:vocab_list/helper.dart';

import 'generated/l10n.dart';

class Overview extends State<GeneralStatefulWidget> {

  static const availableLanguageCode = ["en", "hi"];

  final firstLanguageCodeNotifier = ValueNotifier(availableLanguageCode[0]);
  final secondLanguageCodeNotifier = ValueNotifier(availableLanguageCode[1]);

  final wordList = {
    "घर": "house; home",
    "आदमी": "man; human",
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
    body: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GeneralStatefulWidget(() => LanguageSelector(firstLanguageCodeNotifier)),
              Text("->", style: TextStyle(fontSize: 24)),
              GeneralStatefulWidget(() => LanguageSelector(secondLanguageCodeNotifier)),
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
                  builder: (context) => GeneralStatefulWidget(() => EditWord())
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
                builder: (context) => GeneralStatefulWidget(() => EditWord(currentWord: word))
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