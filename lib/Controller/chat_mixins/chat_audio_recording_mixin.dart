import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:live_chat/Data/Model/chat_message_model.dart';
import 'package:live_chat/main.dart';
import 'chat_base_controller.dart';

mixin ChatAudioRecordingMixin on ChatBaseController {
  FlutterSoundRecorder? _recorder;
  bool isRecording = false;
  bool isRecordingPaused = false;
  bool _isRecorderInitialized = false;

  Future<void> _ensureRecorderInitialized() async {
    if (_isRecorderInitialized) return;
    try {
      _recorder ??= FlutterSoundRecorder();
      await _recorder!.openRecorder();
      _isRecorderInitialized = true;
    } catch (e) {
      log("Error opening recorder: $e");
    }
  }

  Future<void> startRecording() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      log("Microphone permission not granted");
      return;
    }
    await _ensureRecorderInitialized();
    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder!.startRecorder(toFile: path);
    isRecording = true;
    isRecordingPaused = false;
    update();
  }

  Future<void> pauseRecording() async {
    if (_recorder != null && isRecording && !isRecordingPaused) {
      await _recorder!.pauseRecorder();
      isRecordingPaused = true;
      update();
    }
  }

  Future<void> resumeRecording() async {
    if (_recorder != null && isRecording && isRecordingPaused) {
      await _recorder!.resumeRecorder();
      isRecordingPaused = false;
      update();
    }
  }

  Future<void> cancelRecording() async {
    try {
      if (_recorder != null && isRecording) {
        await _recorder!.stopRecorder();
      }
      isRecording = false;
      isRecordingPaused = false;
      update();
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    }
  }

  Future<void> stopRecording() async {
    String? recordPath = await _recorder!.stopRecorder();
    isRecording = false;
    isRecordingPaused = false;
    update();

    if (recordPath == null || recordPath.isEmpty) return;
    File file = File(recordPath);
    if (!await file.exists()) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    messages.insert(
        0,
        ChatMessage(
          imageUrl: null,
          reaction: [],
          senderName: sharedPreferences!.getString("username") ??
              sharedPreferences!.getString("usernameGust") ??
              "",
          message: recordPath,
          messageType: 'voice',
          messageId: tempId,
          isFromSender: true,
          isPending: true,
          timestamp: DateFormat('h:mm a').format(DateTime.now()),
        ));

    await sendMessage(audioFile: file, messageType: 'audio', tempId: tempId);
  }

  void closeRecorder() {
    _recorder?.closeRecorder();
  }
}
