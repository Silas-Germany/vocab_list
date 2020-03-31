import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class GeneralStatefulWidget extends StatefulWidget {
  final State<GeneralStatefulWidget> Function() generateState;
  const GeneralStatefulWidget(this.generateState);
  @override State<StatefulWidget> createState() => generateState();
}

class Csv {

  static Directory directory;

  static Future<Map<String, String>> getWordList(MapEntry<String, String> languageCodes) async{
    if (directory == null) directory = await getExternalStorageDirectory();
    final wordFile = File("${directory.path}/${languageCodes.key}-${languageCodes.value}.txt");
    final wordList = <String, String>{};
    if (!wordFile.existsSync()) return wordList;
    wordFile.readAsLinesSync().forEach((line) {
      final lineParts = line.split("\t");
      if (lineParts.length >= 2) wordList[lineParts[0]] = lineParts[1];
    });
    return wordList;
  }

  static saveWordList(MapEntry<String, String> languageCodes, Map<String, String> wordList) async{
    if (directory == null) directory = await getExternalStorageDirectory();
    final wordFile = File("${directory.path}/${languageCodes.key}-${languageCodes.value}.txt");
    if (!wordFile.existsSync()) wordFile.createSync();
    wordFile.writeAsStringSync(
      wordList.entries.map((entry) => [entry.key, entry.value, soundFile(entry)].join("\t")).join("\n")
    );
  }

  static String soundFile(MapEntry<String, String> word) => "[sound:${word.key}.mp3]";
}