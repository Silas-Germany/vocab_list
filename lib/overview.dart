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

  Map<String, String> wordList;

  @override
  void initState() {
    super.initState();
    updateWordList();
    languageCode1Notifier.addListener(() {
      if (languageCode1Notifier.value == languageCode2Notifier.value) {
        final sameCode = languageCode1Notifier.value;
        languageCode2Notifier.value = availableLanguageCode.firstWhere((code) => code != sameCode);
      } else updateWordList();
    });
    languageCode2Notifier.addListener(() {
      if (languageCode1Notifier.value == languageCode2Notifier.value) {
        final sameCode = languageCode1Notifier.value;
        languageCode1Notifier.value = availableLanguageCode.firstWhere((code) => code != sameCode);
      } else updateWordList();
    });
  }

  updateWordList() {
    setState(() {
      wordList = null;
    });
    Csv.getWordList(languageCodes).then((list) {
      setState(() {
        wordList = list;
      });
    });
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(S.of(context).overview),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () async {
            final word = await Navigator.of(context).push<MapEntry<String, String>>(MaterialPageRoute(
                builder: (context) => GeneralStatefulWidget(() => EditWord(languageCodes))
            ));
            if (word != null) {
              wordList[word.key] = word.value;
              Csv.saveWordList(languageCodes, wordList);
            }
          },
        ),
      ],
    ),
    body: wordList == null ? Center(child: CircularProgressIndicator()) : Column(
      children: <Widget>[
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GeneralStatefulWidget(() => LanguageSelector(languageCode1Notifier)),
            IconButton(
              icon: Icon(Icons.swap_horiz),
              onPressed: () {
                setState(() {
                  final oldValue = languageCode1Notifier.value;
                  languageCode1Notifier.value = languageCode2Notifier.value;
                  languageCode2Notifier.value = oldValue;
                });
              },
            ),
            GeneralStatefulWidget(() => LanguageSelector(languageCode2Notifier)),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: wordList.length,
            itemBuilder: (context, index) => InkWell(
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 8),
                        menuPopup(wordList.entries.toList()[index]),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(wordList.entries.toList()[index].key, style: TextStyle(fontSize: 20)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(wordList.entries.toList()[index].value, style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ],
              ),
              onLongPress: () {
                Navigator.of(context).push<MapEntry<String, String>>(MaterialPageRoute(
                    builder: (context) => GeneralStatefulWidget(() => EditWord(languageCodes, word: wordList.entries.toList()[index]))
                )).then((newWord) {
                  if (newWord != null) {
                    wordList.remove(wordList.entries.toList()[index].key);
                    wordList[newWord.key] = newWord.value;
                    Csv.saveWordList(languageCodes, wordList);
                  };
                });
              }
              ,
            ),
          ),
        ),
      ],
    ),
  );

  Widget menuPopup(MapEntry<String, String> word) => IconButton(
    icon: Icon(Icons.delete),
    onPressed: () {
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
  );
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
      "ru": S.of(context).russian,
      "zh-TW": S.of(context).cantonese,
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