package com.github.silasgermany.vocab_list

import androidx.annotation.NonNull;
import androidx.lifecycle.LifecycleOwner
import com.ichi2.anki.api.AddContentApi
import com.ichi2.anki.api.NoteInfo
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val modelId: Long = 34
    private val deckId: Long = 34
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "anki").setMethodCallHandler { call, result ->
            if (call.method != "addNotes") return@setMethodCallHandler
//            val notes = call.argument<Map<String, String>>("notes")!!
            val ankiApi = AddContentApi(context.applicationContext)
            val modelList = ankiApi.modelList
            android.util.Log.e("ANKI", modelList?.toString())
//            val existingNotes = ankiApi.findDuplicateNotes(ankiApi.currentModelId, notes.keys.toMutableList())
//            android.util.Log.e("ANKI", existingNotes.toString())
//            notes.entries.filterIndexed{ index, _ -> existingNotes[index]?.isNotEmpty() == true }.forEach { (word, translation) ->
//                val fields = arrayOf(word, translation, "[sound:$word.mp3]")
//                ankiApi.addNote(modelId, deckId, fields, setOf())
//            }
        }
    }
}
