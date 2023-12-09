import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

class AudioSingle {
  final loader = Completer<bool>();
  final String name;
  final audioPlayer = AudioPlayer();
  var loaded = false;
  var loading = false;

  AudioSingle({
    required this.name,
  });

  void call([double volume = 1.0]){
    play(volume: volume);
  }

  void play({double volume = 1.0}) {
    if (!loaded) {
      load().then((value) {
        if (value){
          play(volume: volume);
        }
      });
      return;
    }
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

  Future load() async {
    if (loaded){
      return false;
    }
    if (loading){
      return loader.future;
    }
    loading = true;
    audioPlayer.setReleaseMode(ReleaseMode.stop).then((value) {
      audioPlayer.setPlayerMode(PlayerMode.lowLatency).then((value) {
        audioPlayer.setSourceAsset('audio/$name.mp3').then((value){
          loaded = true;
          loader.complete(true);
        });
      });
    });
    return loader.future;
  }
}
