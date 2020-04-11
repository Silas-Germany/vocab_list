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

  static Future<List<MapEntry<String, String>>> getWordList(MapEntry<String, String> languageCodes) async{
    if (directory == null) directory = await getExternalStorageDirectory();
    final wordFile = File("${directory.path}/${languageCodes.key}-${languageCodes.value}.txt");
    final wordList = <MapEntry<String, String>>[];
    if (!wordFile.existsSync()) return wordList;
    final wordFileLines = wordFile.readAsLinesSync();
    if (wordFileLines.first.split("\t").length == 4) wordFileLines.sort((a, b) => a.split("\t").last.compareTo(b.split("\t").last));
    final addedWords = Set<String>();
    wordFileLines.forEach((line) {
      final lineParts = line.split("\t");
      if (lineParts.length >= 2 && addedWords.add(lineParts[0])) wordList.add(MapEntry(lineParts[0], lineParts[1]));
    });
    return wordList;
  }

  static saveWordList(MapEntry<String, String> languageCodes, List<MapEntry<String, String>> wordList) async{
    if (directory == null) directory = await getExternalStorageDirectory();
    final wordFile = File("${directory.path}/${languageCodes.key}-${languageCodes.value}.txt");
    if (!wordFile.existsSync()) wordFile.createSync();
    int index = 100;
    wordFile.writeAsStringSync(
        wordList.map((entry) => [entry.key, entry.value, soundFile(entry), index++].join("\t")).join("\n")
    );
  }

  static String soundFile(MapEntry<String, String> word) => "[sound:${word.key}.mp3]";
}