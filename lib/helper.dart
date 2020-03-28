import 'dart:io';

import 'package:csv/csv.dart';
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
    final wordFile = File("${directory.path}/${languageCodes.key}-${languageCodes.value}.csv");
    final wordList = <String, String>{};
    if (!await wordFile.exists()) return wordList;
    CsvToListConverter().convert(await wordFile.readAsString()).forEach((line) {
      final wordParts = line.map((word) => word.toString()).toList();
      wordList[wordParts[0]] = wordParts[1];
    });
    return wordList;
  }

  static saveWordList(MapEntry<String, String> languageCodes, Map<String, String> wordList) async{
    if (directory == null) directory = await getExternalStorageDirectory();
    final wordFile = File("${directory.path}/${languageCodes.key}-${languageCodes.value}.csv");
    if (!wordFile.existsSync()) wordFile.createSync();
    wordFile.writeAsStringSync(
        ListToCsvConverter().convert(wordList.entries.map((entry) => [entry.key, entry.value]).toList())
    );
  }
}