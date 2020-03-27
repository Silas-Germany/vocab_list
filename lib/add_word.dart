
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'generated/l10n.dart';
import 'helper.dart';

class EditWord extends State<GeneralStatefulWidget> {

  String currentWord;
  final bool newWord;
  final Set<String> selectedTranslations;
  final Map<String, Map<String, List<String>>> translations = {
    "Noun": {
      "house": ["घर"],
      "home": ["घर"],
    }
  };
  final customTranslationListener = TextEditingController();

  EditWord({MapEntry<String, String> currentWord}) :
        newWord = currentWord == null,
        currentWord = currentWord?.key,
        selectedTranslations = currentWord?.value?.split(("; "))?.toSet() ?? Set() {
    customTranslationListener.text = selectedTranslations.where(
            (translation) => !translations.containsKey(translation)
    ).join("\n");
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(newWord ? S.of(context).newWord : S.of(context).editWord(currentWord)),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textEntryField,
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
              const SizedBox(width: 8),
              Text("(${translation.value.join(",")})",
                style: TextStyle(fontSize: 16),
              )
            ],
          )).toList() + [
            TextField(
              controller: customTranslationListener,
              maxLines: null,
              decoration: InputDecoration(
                hintText: S.of(context).customTranslation,
              ),
            )
          ],
          ).expand((entry) => entry).toList() + [
            SizedBox(height: 32),
            Center(
              child: RaisedButton(
                child: Text(S.of(context).saveWord),
                onPressed: () {
                  final allTranslations = selectedTranslations.toList() + customTranslationListener.text.split("\n").where(
                          (translation) => translation.trim().isNotEmpty
                  ).toList();
                  if (currentWord != null && allTranslations.isNotEmpty) {
                    final currentTranslations = allTranslations.join("; ");
                    Navigator.of(context).pop(MapEntry(currentWord, currentTranslations));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget get textEntryField => TextField(
    controller: TextEditingController(text: currentWord ?? ""),
    onChanged: (value) {
      currentWord = value;
    },
    decoration: InputDecoration(
        hintText: S.of(context).enterWord,
        border: OutlineInputBorder()
    ),
  );
}