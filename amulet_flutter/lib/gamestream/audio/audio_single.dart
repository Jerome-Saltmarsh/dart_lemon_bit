import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

class AudioSingle {
  final String name;
  final audioPlayer = AudioPlayer();
  // late final Source source;

  AudioSingle({
    required this.name,
  }){
    // AudioCache.instance.prefix = 'flutter_assets/';
    // source = AssetSource('audio/$name.mp3');
    audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    audioPlayer.setSourceAsset('audio/$name.mp3');
  }


  void call([double volume = 1.0]){
    play(volume: volume);
  }

  void stop() {
    audioPlayer.seek(const Duration()).then((value) {
      audioPlayer.stop();
    });
  }

  void play({double volume = 1.0}) async {
    if (volume <= 0) return;
    final audioPlayer = this.audioPlayer;
    if (audioPlayer.volume != volume){
      await audioPlayer.setVolume(min(volume, 1));
    }
    audioPlayer.seek(const Duration());
    audioPlayer.resume();
  }
}
