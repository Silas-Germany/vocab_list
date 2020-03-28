
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'generated/l10n.dart';
import 'helper.dart';

class EditWord extends State<GeneralStatefulWidget> {

  String currentWord;
  final bool newWord;
  final Set<String> selectedTranslations = Set();
  String mainTranslation;
  Map<String, Map<String, List<String>>> translations = {};
  final customTranslationListener = TextEditingController();
  final languageCode1;
  final languageCode2;
  final wordEntryController;

  EditWord(MapEntry<String, String> languageCodes, {MapEntry<String, String> word}) :
        newWord = word == null,
        currentWord = word?.key,
        languageCode1 = languageCodes.key,
        languageCode2 = languageCodes.value,
        wordEntryController = TextEditingController(text: word?.key ?? "")
  {
    init(word?.value);
  }

  init(String previousTranslations) async {
    if (!newWord) await updateWord(currentWord);
    previousTranslations?.split("; ")?.forEach((translation) {
      final existsInDownloaded = translation == mainTranslation ||
          translations.values.any((existingTranslations) => existingTranslations.containsKey(translation));
      if (existsInDownloaded) {
        selectedTranslations.add(translation);
      } else {
        if (customTranslationListener.text.isNotEmpty) customTranslationListener.text += "\n";
        customTranslationListener.text += translation;
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(newWord ? S.of(context).newWord : S.of(context).editWord(currentWord)),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.check),
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
      ],
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textEntryField,
            const SizedBox(height: 32),
            translationField(mainTranslation)
          ] + translations.entries.map((category) => <Widget>[
            Text(category.key, style: TextStyle(fontSize: 24)),
            const SizedBox(width: 24),
          ] + category.value.entries.map(
                  (translation) => translationField(translation.key, backTranslations: translation.value)
          ).toList(),
          ).expand((entry) => entry).toList() + [
            currentWord?.isEmpty != false ? SizedBox() : TextField(
              controller: customTranslationListener,
              maxLines: null,
              decoration: InputDecoration(
                hintText: S.of(context).customTranslation,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget get textEntryField => TextField(
    autofocus: newWord,
    controller: wordEntryController,
    onChanged: (value) => updateWord(value),
    decoration: InputDecoration(
        hintText: S.of(context).enterWord,
        border: OutlineInputBorder()
    ),
  );

  Widget translationField(String translation, {List<String> backTranslations}) {
    if (translation == null) return SizedBox();
    final checkboxValue = selectedTranslations.contains(translation);
    final checkbox = checkboxValue
        ? Icon(Icons.check_box, color: Colors.blue)
        : Icon(Icons.check_box_outline_blank, color: Colors.blue);
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Row(
          children: [
            checkbox,
            const SizedBox(width: 8),
            Text(translation, style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            backTranslations == null ? SizedBox() : Expanded(
              child: Text("(${backTranslations.join(", ")})",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        setState(() {
          if (!checkboxValue) selectedTranslations.add(translation);
          else selectedTranslations.remove(translation);
        });
      },
    );
  }

  updateWord(word) async {
    final response = await http.get("https://translate.googleapis.com/translate_a/single?client=gtx&sl="
        "$languageCode1&tl=$languageCode2&dt=bd&dt=t&q=$word");
    setState(() {
      translations.clear();
      selectedTranslations.clear();
      final List<dynamic> jsonResponse = json.decode(response.body);
      mainTranslation = ((jsonResponse[0] as List<dynamic>)?.first as List<dynamic>)?.first;
      selectedTranslations.add(mainTranslation);
      (jsonResponse[1] as List<dynamic>)?.forEach((gTranslation) {
        final String category = gTranslation[0];
        translations[category] = {};
        (gTranslation[2] as List<dynamic>).forEach((translationAndBack) {
          final String translation = translationAndBack[0];
          final List<dynamic> backTranslations = translationAndBack[1];
          translations[category][translation] = backTranslations.map((entry) => entry as String).toList();
        });
      });
      currentWord = word;
    });
  }
}