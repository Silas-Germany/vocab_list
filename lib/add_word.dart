
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'helper.dart';

class EditWord extends State<GeneralStatefulWidget> {

  String? currentWord;
  final bool newWord;
  final Set<String> selectedTranslations = Set();
  String? mainTranslation;
  Map<String, Map<String, List<String>>> translations = {};
  final customTranslationListener = TextEditingController();
  final TextEditingController wordEntryController;
  Timer? textChangedTimer;

  EditWord({MapEntry<String, String>? word}) :
        newWord = word == null,
        currentWord = word?.key,
        wordEntryController = TextEditingController(text: word?.key ?? "")
  {
    init(word?.value.split("; ") ?? []);
  }

  init(List<String> previousTranslations) async {
    if (newWord) return;
    await updateWord(currentWord);
    if (!previousTranslations.contains(mainTranslation)) selectedTranslations.remove(mainTranslation);
    previousTranslations.forEach((translation) {
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
      title: Text(newWord ? 'New word' : "Edit '${currentWord}'"),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.check),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                children: <Widget>[
                  Expanded(child: textEntryField),
                  const SizedBox(height: 32),
                  Builder(builder: (context) => TextButton(
                    onPressed: () async {
                      final value = wordEntryController.text;
                      if  (value.isEmpty) return;
                      final response = await http.get(Uri.parse("https://inputtools.google.com/request?itc=${targetInputMethod}&num=4&text=$value"));
                      final List<dynamic> jsonResponse = json.decode(response.body);
                      final List<dynamic> gInput = ((jsonResponse[1] as List<dynamic>)[0] as List<dynamic>)[1];
                      textChangedTimer = null;
                      final RenderBox renderBox = context.findRenderObject() as RenderBox;
                      final offset = renderBox.localToGlobal(Offset.zero);
                      final position = RelativeRect.fromLTRB(offset.dx, offset.dy + renderBox.size.height, offset.dx, 0);
                      showMenu<String>(
                        context: context,
                        position: position,
                        items: gInput.map((gWord) => PopupMenuItem(
                          value: gWord.toString(),
                          child: Text(gWord),
                        )
                        ).toList(),
                      ).then((String? selected) {
                        if (selected == null) return;
                        wordEntryController.text = selected;
                        updateWord(selected);
                      });
                    },
                    child: const Text('Suggestions'),
                  )),
                ]
            ),
            const SizedBox(height: 32),
            translationField(mainTranslation)
          ] + translations.entries.map((category) => <Widget>[
            Text(category.key, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 24),
          ] + category.value.entries.map(
                  (translation) => translationField(translation.key, backTranslations: translation.value)
          ).toList(),
          ).expand((entry) => entry).toList() + [
            currentWord?.isEmpty != false ? const SizedBox() : TextField(
              controller: customTranslationListener,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Custom translations (new line for each)',
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
    onChanged: (value) {
      textChangedTimer?.cancel();
      if (value.isNotEmpty) {
        textChangedTimer = Timer(const Duration(seconds: 1), () async {
          updateWord(value);
        });
      }
    },
    decoration: const InputDecoration(
        hintText: 'Enter new word',
        border: const OutlineInputBorder()
    ),
  );

  Widget translationField(String? translation, {List<String>? backTranslations}) {
    if (translation == null) return const SizedBox();
    final checkboxValue = selectedTranslations.contains(translation);
    final checkbox = checkboxValue
        ? const Icon(Icons.check_box, color: Colors.blue)
        : const Icon(Icons.check_box_outline_blank, color: Colors.blue);
    final backTranslationWidgets = backTranslations?.expand((backTranslation) =>
        [
          TextSpan(
          text: backTranslation,
          style: backTranslation != wordEntryController.text ? null : const TextStyle(fontWeight: FontWeight.bold),
        ),
          const TextSpan(text: ", "),
        ]
    ).toList();
    backTranslationWidgets?.removeLast();
    backTranslationWidgets?.insert(0, const TextSpan(text: "("));
    backTranslationWidgets?.add(const TextSpan(text: ")"));
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            checkbox,
            const SizedBox(width: 8),
            Text(translation, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            backTranslations == null ? const SizedBox() : Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  children: backTranslationWidgets,
                ),
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
    try {
      final response = await http.get(Uri.parse("https://translate.googleapis.com/translate_a/single?client=gtx&sl=$sourceLanguage&tl=$targetLanguage&dt=bd&dt=t&q=$word"));
      setState(() {
        print(response.body);
        translations.clear();
        selectedTranslations.clear();
        final List<dynamic> jsonResponse = json.decode(response.body);
        mainTranslation = ((jsonResponse[0] as List<dynamic>).first as List<dynamic>).first;
        selectedTranslations.add(mainTranslation as String);
        (jsonResponse[1] as List<dynamic>?)?.forEach((gTranslation) {
          final String category = gTranslation[0];
          translations[category] = {};
          (gTranslation[2] as List<dynamic>).forEach((translationAndBack) {
            final String translation = translationAndBack[0];
            final List<dynamic> backTranslations = translationAndBack[1];
            translations[category]![translation] = backTranslations.map((entry) => entry as String).toList();
          });
        });
        currentWord = word;
      });
    } catch (e) {
      showAboutDialog(context: context, applicationVersion: e.toString());
    }
  }
}
