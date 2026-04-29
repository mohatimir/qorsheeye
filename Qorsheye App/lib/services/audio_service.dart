import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// This is the "Magic": It chooses the right file at compile-time
import 'web_audio_stub.dart'
    if (dart.library.js_interop) 'web_audio_web.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playPreview(String soundName) async {
    String ext = soundName.contains('mixkit') ? 'wav' : 'mp3';
    
    if (kIsWeb) {
      // Calls the web version if on web, or stub if on mobile (but kIsWeb prevents it)
      await playWebAudio('assets/assets/sounds/$soundName.$ext');
    } else {
      // Mobile implementation using audioplayers
      try {
        await _player.stop();
        await _player.play(AssetSource('sounds/$soundName.$ext'));
      } catch (e) {
        // ignore: avoid_print
        print("Mobile Audio Error: $e");
      }
    }
  }
}
