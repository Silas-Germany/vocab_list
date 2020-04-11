import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vocab_list/secrets.dart';

class GeneralStatefulWidget extends StatefulWidget {
  final State<GeneralStatefulWidget> Function() generateState;
  const GeneralStatefulWidget(this.generateState);
  @override State<StatefulWidget> createState() => generateState();
}

abstract class AnkiConverter {

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
    wordFile.writeAsString(
        wordList.map((entry) => [entry.key, entry.value, soundFile(entry), index++].join("\t")).join("\n")
    );
  }

  static String soundFile(MapEntry<String, String> word) => "[sound:${word.key}.mp3]";

  static const url = "https://texttospeech.googleapis.com/v1/text:synthesize?key=$apiKey";
  static const voices = {
    "hi": MapEntry("hi-IN-Wavenet-A", "FEMALE"),
  };

  static downloadSoundFile(String word, String languageCode) async {
    if (directory == null) directory = await getExternalStorageDirectory();
    final mp3File = File("${directory.path}/sound_files_$languageCode/$word.mp3");
    if (mp3File.existsSync()) return;
    final voice = voices[languageCode].key;
    final gender = voices[languageCode].value;
    final code = voice.substring(0, 5);
    final body = {
      "input": {
        "text": word,
      },
      "voice": {
        "languageCode": code,
        "name": voice,
        "ssmlGender": gender,
      },
      "audioConfig": {
        "audioEncoding":"MP3",
      },
    };
    final headers = {"content-type": "application/json"};
    final response = await post(url, headers: headers, body: jsonEncode(body));
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final mp3Data = base64Decode(jsonResponse["audioContent"]);
    mp3File.writeAsBytes(mp3Data);
  }
}