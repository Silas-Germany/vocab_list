import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vocab_list/secrets.dart';

// Defining the language-settings that are supposed to be used
const sourceLanguage = "en";
const targetLanguage = "hi";
const targetVoice = MapEntry("hi-IN-Wavenet-D", "FEMALE");
const targetInputMethod = "hi-t-i0-und";

// General StatefulWidget as it's not really necessary to have this class
class GeneralStatefulWidget extends StatefulWidget {
  final State<GeneralStatefulWidget> Function() generateState;
  const GeneralStatefulWidget(this.generateState);
  @override State<StatefulWidget> createState() => generateState();
}

abstract class AnkiConverter {

  static Directory? directory;

  static Future<List<MapEntry<String, String>>> getWordList() async{
    if (directory == null) directory = await getExternalStorageDirectory();
    final wordFile = File("${directory!.path}/${sourceLanguage}-${targetLanguage}.txt");
    final wordList = <MapEntry<String, String>>[];
    if (!wordFile.existsSync()) return wordList;
    final wordFileLines = wordFile.readAsLinesSync();
    if (wordFileLines.isEmpty) return wordList;
    if (wordFileLines.first.split("\t").length == 4) wordFileLines.sort((a, b) => a.split("\t").last.compareTo(b.split("\t").last));
    final addedWords = Set<String>();
    wordFileLines.forEach((line) {
      final lineParts = line.split("\t");
      if (lineParts.length >= 2 && addedWords.add(lineParts[0])) wordList.add(MapEntry(lineParts[0], lineParts[1]));
    });
    return wordList;
  }

  static saveWordList(List<MapEntry<String, String>> wordList) async{
    if (directory == null) directory = await getExternalStorageDirectory();
    final wordFile = File("${directory!.path}/${sourceLanguage}-${targetLanguage}.txt");
    if (!wordFile.existsSync()) wordFile.createSync();
    int index = 100;
    wordFile.writeAsString(
        wordList.map((entry) => [entry.key, entry.value, soundFile(entry), index++].join("\t")).join("\n")
    );
  }

  static String soundFile(MapEntry<String, String> word) => "[sound:${word.key}.mp3]";

  static const url = "https://texttospeech.googleapis.com/v1/text:synthesize?key=$apiKey";

  static downloadSoundFile(String word) async {
    if (directory == null) directory = await getExternalStorageDirectory();
    final mp3File = File("/sdcard/AnkiDroid/collection.media/$word.mp3");
    if (mp3File.existsSync()) return;
    final voice = targetVoice.key;
    final gender = targetVoice.value;
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
    final response = await post(Uri.parse(url), headers: headers, body: jsonEncode(body));
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final mp3Data = base64Decode(jsonResponse["audioContent"]);
    mp3File.writeAsBytes(mp3Data);
  }

  static sendToAnki(List<MapEntry<String, String>> wordList) async {
    final channel = await const MethodChannel("anki");
    final front = <String>[];
    final back = <String>[];
    wordList.reversed.forEach((entry) { front.add(entry.key); back.add(entry.value); });
    await channel.invokeMethod("addNotes", {"front": front, "back": back});
  }

  static Future<List<MapEntry<String, String>>> getFromAnki() async {
    final channel = await const MethodChannel("anki");
    final words = await channel.invokeMethod("getNotes");
    final fronts = words["fronts"] as List;
    final backs = words["backs"] as List;
    if (fronts.length != backs.length) throw "Invalid Data";
    final wordList = List<MapEntry<String, String>>.empty(growable: true);
    for(int i = 0; i < fronts.length; i++) {
      wordList.add(MapEntry(fronts[i], backs[i]));
    }
    return wordList.reversed.toList();
  }
}