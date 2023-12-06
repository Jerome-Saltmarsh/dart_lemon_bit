import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

class AudioSingle {
  final String name;
  final audioPlayer = AudioPlayer();

  AudioSingle({
    required this.name,
  }){
    // AudioCache.instance.prefix = 'flutter_assets/';
    // source = AssetSource('audio/$name.mp3');
    audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    // audioPlayer.setSourceAsset('audio/$name.mp3');
  }


  void call([double volume = 1.0]){
    play(volume: volume);
  }

  void play({double volume = 1.0}) {
    if (volume <= 0) return;
    final audioPlayer = this.audioPlayer;
    if (audioPlayer.volume != volume){
      audioPlayer.setVolume(min(volume, 1)).then((value) {
        restart();
      });
      return;
    }
    restart();
  }

  void restart(){
    audioPlayer.seek(const Duration());
    audioPlayer.resume();
  }
}
