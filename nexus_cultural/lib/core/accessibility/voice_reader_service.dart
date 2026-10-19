import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceReaderService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> init() async {
    await _flutterTts.setLanguage('es-CO'); // Colombian Spanish
    await _flutterTts.setSpeechRate(0.61); // Gentle, slow cadence for elderly listeners
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(0.95);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
    });
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await _flutterTts.stop();
    _isSpeaking = true;
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }
}

final voiceReaderProvider = Provider<VoiceReaderService>((ref) {
  final service = VoiceReaderService();
  service.init();
  return service;
});

final isSpeakingProvider = StateProvider<bool>((ref) => false);
