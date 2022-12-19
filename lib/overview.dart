import 'package:flutter/material.dart';
import 'package:vocab_list/add_word.dart';
import 'package:vocab_list/helper.dart';

enum Order {
  added,
  word,
  translation,
}

class Overview extends State<GeneralStatefulWidget> {

  Order order = Order.added;

  List<MapEntry<String, String>> wordList;

  @override
  void initState() {
    super.initState();
    updateWordList();
  }

  updateWordList() {
    setState(() {
      wordList = null;
    });
    AnkiConverter.getWordList().then((list) {
      setState(() {
        wordList = list;
      });
    });
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text("Overview (${wordList?.length ?? "?"} words, ${order.toString().split(".").last})", overflow: TextOverflow.fade,),
      actions: wordList == null ? [] : [
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: () {
            setState(() {
              order = Order.values[(order.index + 1) % Order.values.length];
            });
          },
        ),
        IconButton(
          icon:  const Icon(Icons.send),
          onPressed: () async {
            await AnkiConverter.sendToAnki(wordList);
            wordList.clear();
            wordList.addAll(await AnkiConverter.getFromAnki());
            setState(() {
              AnkiConverter.saveWordList(wordList);
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            final newWord = await Navigator.of(context).push<MapEntry<String, String>>(MaterialPageRoute(
                builder: (context) => GeneralStatefulWidget(() => EditWord())
            ));
            if (newWord != null) {
              if (wordList.any((word) => word.key == newWord.key)) showDialog(
                context: context,
                builder: (context) => const AlertDialog(
                  content: Text('Word existed already'),
                ),
              );
              else setState(() {
                wordList.insert(0, newWord);
                AnkiConverter.saveWordList(wordList);
                AnkiConverter.downloadSoundFile(newWord.key);
              });
            }
          },
        ),
      ],
    ),
    body: wordList == null ? const Center(child: CircularProgressIndicator()) : Column(
      children: <Widget>[
        const SizedBox(height: 16),
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
                      builder: (context) => GeneralStatefulWidget(() => EditWord(word: entry))
                  )).then((newWord) {
                    if (newWord != null) {
                      if (newWord.key != entry.key && wordList.any((word) => word.key == newWord.key)) showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          content: Text('Word existed already'),
                        ),
                      );
                      else setState(() {
                        wordList[wordList.indexOf(entry)] = newWord;
                        AnkiConverter.saveWordList(wordList);
                        AnkiConverter.downloadSoundFile(newWord.key);
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
    icon: const Icon(Icons.delete),
    onPressed: () {
      showDialog(context: context,
          builder: (context) => AlertDialog(
            content: Text("Do you want to delete '${word.key}'?"),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  setState(() {
                    wordList.remove(word);
                    AnkiConverter.saveWordList(wordList);
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
      "en": 'English',
      "hi": 'Hindi',
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