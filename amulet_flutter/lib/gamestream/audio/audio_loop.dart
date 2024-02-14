import 'package:audioplayers/audioplayers.dart';
import 'package:lemon_math/src.dart';

class AudioLoop {

  static const minVolumeDelta = 0.005;

  final String name;
  double Function() getTargetVolume;
  final audioPlayer = AudioPlayer();
  late Duration duration;
  var durationInSeconds = 0;
  var volumeFade = 0.05;
  var loaded = false;

  double get volume => audioPlayer.volume;

  AudioLoop({
    required this.name,
    required this.getTargetVolume,
    this.volumeFade = 0.05,
  });

  Future load() => audioPlayer.setReleaseMode(ReleaseMode.loop).then((value) {
      audioPlayer.setPlayerMode(PlayerMode.lowLatency).then((value) {
        audioPlayer.setSourceAsset('audio/$name.mp3').then((value){
          loaded = true;
          audioPlayer.setVolume(0);
          audioPlayer.resume();
        });
      });
    });

  void update(){
    final targetVolume = clamp01(getTargetVolume());
    final volumeDelta = (targetVolume - volume) * volumeFade;
    if (volumeDelta.abs() < minVolumeDelta) {
      if (targetVolume == 0 && volume != 0){
        setVolume(0);
      }
      return;
    }
    setVolume(volume + volumeDelta);
  }

  void setVolume(double value){
    if (volume == value) return;
    final clampedVolume = clamp01(value);
    if (volume == clampedVolume) return;
    audioPlayer.setVolume(clampedVolume);
  }
}
