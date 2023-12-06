import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

class AudioSingle {
  final String name;
  final audioPlayer = AudioPlayer();
  var loaded = false;

  AudioSingle({
    required this.name,
  }){
    audioPlayer.setPlayerMode(PlayerMode.lowLatency).then((value) {
      audioPlayer.setSourceAsset('audio/$name.mp3').then((value){
         loaded = true;
      });
    });

  }


  void call([double volume = 1.0]){
    play(volume: volume);
  }

  void play({double volume = 1.0}) {
    if (!loaded) return;
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
