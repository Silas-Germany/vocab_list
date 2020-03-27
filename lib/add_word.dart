
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'generated/l10n.dart';
import 'helper.dart';

class EditWord extends State<GeneralStatefulWidget> {

  final MapEntry<String, String> currentWord;
  final bool newWord;
  final wordChangedListener = TextEditingController();
  final Set<String> selectedTranslations = Set();
  final Map<String, Map<String, List<String>>> translations = {
    "Noun": {
      "house": ["घर"],
      "home": ["घर"],
    }
  };

  EditWord({this.currentWord = const MapEntry("", "")}) : newWord = currentWord.key.isEmpty;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(newWord ? S.of(context).newWord : S.of(context).editWord(currentWord.key)),
    ),
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          newWord ? textEntryField : SizedBox(),
          const SizedBox(height: 32),
        ] + translations.entries.map((category) => <Widget>[
          Text(category.key, style: TextStyle(fontSize: 24)),
          const SizedBox(width: 24),
        ] + category.value.entries.map((translation) => Row(
          children: [
            Checkbox(
              value: selectedTranslations.contains(translation.key),
              onChanged: (value) {
                setState(() {
                  if (value) selectedTranslations.add(translation.key);
                  else selectedTranslations.remove(translation.key);
                });
              },
            ),
            Text(translation.key, style: TextStyle(fontSize: 16)),
            const SizedBox(width: 16),
          ] + translation.value.map((backTranslation) => Text(backTranslation,
            style: TextStyle(fontSize: 16),
          )).toList(),
        )).toList(),
        ).expand((entry) => entry).toList() + [
          SizedBox(height: 32),
          Center(
            child: RaisedButton(
              child: Text(S.of(context).saveWord),
              onPressed: () {
                final word = MapEntry(wordChangedListener.text, selectedTranslations.join("; "));
                Navigator.of(context).pop(word);
              },
            ),
          ),
        ],
      ),
    ),
  );

  Widget get textEntryField => TextField(
    controller: wordChangedListener,
    decoration: InputDecoration(
        hintText: S.of(context).enterWord,
        border: OutlineInputBorder()
    ),
  );
}