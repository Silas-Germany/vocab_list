package com.github.silasgermany.vocab_list

import android.Manifest.permission.WRITE_EXTERNAL_STORAGE
import android.content.ContentValues
import android.content.pm.PackageManager.PERMISSION_GRANTED
import android.database.Cursor
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat.requestPermissions
import androidx.core.content.ContextCompat.checkSelfPermission
import com.ichi2.anki.FlashCardsContract.Note
import com.ichi2.anki.FlashCardsContract.READ_WRITE_PERMISSION
import com.ichi2.anki.FlashCardsContract.ReviewInfo
import com.ichi2.anki.api.AddContentApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val modelName = "VocabList"
    private val deckName = "VocabList"
    private val frontFormat get() = arrayOf(
            "{{Sound}}\n" +
                    "<br>\n" +
                    "{{Front}}",
            "{{Back}}"
    )
    private val css get() =
        ".card {\n" +
                " font-family: arial;\n" +
                " font-size: 20px;\n" +
                " text-align: center;\n" +
                " color: black;\n" +
                " background-color: white;\n" +
                "}"
    private val backFormat get() = arrayOf(
            "{{FrontSide}}\n" +
                    "<hr id=answer>\n" +
                    "{{Back}}",
            "{{FrontSide}}\n" +
                    "<hr id=answer>\n" +
                    "{{Sound}}\n" +
                    "<br>\n" +
                    "{{Front}}"
    )

    override fun onStart() {
        super.onStart()
        val missingPermission = checkSelfPermission(context, READ_WRITE_PERMISSION) != PERMISSION_GRANTED ||
                checkSelfPermission(context, WRITE_EXTERNAL_STORAGE) != PERMISSION_GRANTED
        if (missingPermission) requestPermissions(this, arrayOf(READ_WRITE_PERMISSION, WRITE_EXTERNAL_STORAGE), 1)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "anki").setMethodCallHandler { call, result ->
            if (checkSelfPermission(context, READ_WRITE_PERMISSION) != PERMISSION_GRANTED) {
                result.error(READ_WRITE_PERMISSION, "Permission not granted", null)
                return@setMethodCallHandler
            }
            val ankiApi = AddContentApi(context.applicationContext)
            val deckId = ankiApi.deckList.entries.find { it.value == deckName }?.key
                    ?: ankiApi.addNewDeck(deckName)!!
            val modelId = ankiApi.modelList.entries.find { it.value == modelName }?.key
                    ?: ankiApi.addNewCustomModel(modelName, arrayOf("Front", "Back", "Sound"), arrayOf("1"),
                            frontFormat, backFormat, css, deckId, 0)!!
            if (call.method == "getNotes") {
                contentResolver.query(Note.CONTENT_URI_V2,
                        arrayOf(Note._ID, Note.FLDS),
                        "${Note.MID}=$modelId",
                        null, null
                )?.use { cursor: Cursor ->
                    val fronts = mutableListOf<String>()
                    val backs = mutableListOf<String>()
                    cursor.moveToFirst()
                    repeat(cursor.count) { _ ->
                        val (front, back) = cursor.getString(1).split("\u001f")
                        fronts.add(front)
                        backs.add(back)
                        cursor.moveToNext()
                    }
                    result.success(mapOf("fronts" to fronts, "backs" to backs))
                }
                return@setMethodCallHandler
            }
            if (call.method != "addNotes") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val frontSides = call.argument<List<String>>("front")!!
            val backSides = call.argument<List<String>>("back")!!
            val existingNotes = ankiApi.findDuplicateNotes(modelId, frontSides)
            frontSides.zip(backSides).forEachIndexed { index, (front, back) ->
                val fields = arrayOf(front, back, "[sound:$front.mp3]")
                val currentNotes = existingNotes[index]
                if (currentNotes?.isNotEmpty() != true) {
                    val noteId = ankiApi.addNote(modelId, deckId, fields, null)
                    val values = ContentValues()
                    values.put("suspended", 1)
                    values.put(ReviewInfo.NOTE_ID, noteId)
                    values.put(ReviewInfo.CARD_ORD, 1)
                    contentResolver.update(ReviewInfo.CONTENT_URI,
                            values,
                            null, null
                    )
                } else {
                    val currentNote = currentNotes.first()
                    if (!currentNote.fields!!.contentEquals(fields)) {
                        ankiApi.updateNoteFields(currentNote.id, fields)
                    }
                }
            }
            result.success(null)
        }
    }
}
