// ignore: depend_on_referenced_packages
import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<void> playWebAudio(String path) async {
  try {
    // ignore: avoid_print
    print("Web Audio: Isku dayaya - $path");

    final audio = web.document.createElement('audio') as web.HTMLAudioElement;
    audio.src = path;

    // We use a helper function to handle the JSPromise
    try {
      await audio.play().toDart;
      // ignore: avoid_print
      print("Web Audio: Si guul leh ayaa loo shiday");
    } catch (e) {
      // ignore: avoid_print
      print(
        "Web Audio: Waddadii koowaad way fashilantay, isku dayaya fallback...",
      );

      String fallbackPath;
      if (path.contains('assets/assets/')) {
        fallbackPath = path.replaceFirst('assets/assets/', 'assets/');
      } else if (path.startsWith('assets/')) {
        fallbackPath = path.replaceFirst('assets/', '');
      } else {
        fallbackPath = 'assets/$path';
      }

      // ignore: avoid_print
      print("Web Audio: Isku dayaya fallback - $fallbackPath");
      audio.src = fallbackPath;
      await audio.play().toDart;
    }
  } catch (e) {
    // ignore: avoid_print
    print("Mashiinka dhawaaqa Web-ka ayaa diiday: $e");
  }
}
