import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocab_list/add_word.dart';
import 'package:vocab_list/helper.dart';

import 'generated/l10n.dart';

enum Order {
  added,
  word,
  translation,
}

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
  Order order = Order.added;

  MapEntry<String, String> get languageCodes => MapEntry(languageCode1Notifier.value, languageCode2Notifier.value);

  List<MapEntry<String, String>> wordList;

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
    AnkiConverter.getWordList(languageCodes).then((list) {
      setState(() {
        wordList = list;
      });
    });
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(S.of(context).overview(wordList?.length ?? "?", order.toString().split(".").last), overflow: TextOverflow.fade,),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.sort),
          onPressed: () {
            setState(() {
              order = Order.values[(order.index + 1) % Order.values.length];
              wordList.forEach((entry) => AnkiConverter.downloadSoundFile(entry.key, languageCodes.key));
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () async {
            final newWord = await Navigator.of(context).push<MapEntry<String, String>>(MaterialPageRoute(
                builder: (context) => GeneralStatefulWidget(() => EditWord(languageCodes))
            ));
            if (newWord != null) {
              if (wordList.any((word) => word.key == newWord.key)) showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Text(S.of(context).existed),
                ),
              );
              else setState(() {
                wordList.insert(0, newWord);
                AnkiConverter.saveWordList(languageCodes, wordList);
                AnkiConverter.downloadSoundFile(newWord.key, languageCodes.key);
              });
            }
          },
        ),
      ],
    ),
    body: wordList == null ? const Center(child: CircularProgressIndicator()) : Column(
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
            itemBuilder: (context, index) {
              final sortedWordList = wordList.toList(growable: false);
              switch(order) {
                case Order.added:
                  break;
                case Order.word:
                  sortedWordList.sort((entry1, entry2) => entry1.key.compareTo(entry2.key));
                  break;
                case Order.translation:
                  sortedWordList.sort((entry1, entry2) => entry1.value.compareTo(entry2.value));
                  break;
              }
              final entry = sortedWordList[index];
              return InkWell(
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Row(
                        children: <Widget>[
                          const SizedBox(width: 8),
                          menuPopup(entry),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(entry.key, style: const TextStyle(fontSize: 20)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(entry.value, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                  ],
                ),
                onLongPress: () {
                  Navigator.of(context).push<MapEntry<String, String>>(MaterialPageRoute(
                      builder: (context) => GeneralStatefulWidget(() => EditWord(languageCodes, word: entry))
                  )).then((newWord) {
                    if (newWord != null) {
                      if (newWord.key != entry.key && wordList.any((word) => word.key == newWord.key)) showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Text(S.of(context).existed),
                        ),
                      );
                      else setState(() {
                        wordList[wordList.indexOf(entry)] = newWord;
                        AnkiConverter.saveWordList(languageCodes, wordList);
                        AnkiConverter.downloadSoundFile(newWord.key, languageCodes.key);
                      });
                    };
                  });
                },
              );
            },
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
                    wordList.remove(word);
                    AnkiConverter.saveWordList(languageCodes, wordList);
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