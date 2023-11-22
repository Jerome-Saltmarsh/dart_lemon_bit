import 'package:just_audio/just_audio.dart';
import 'package:lemon_math/src.dart';

class AudioLoop {

  static const minVolumeDelta = 0.005;


  final String name;
  double Function() getTargetVolume;
  final audioPlayer = AudioPlayer();
  late Duration duration;
  var durationInSeconds = 0;
  var volumeFade = 0.05;

  AudioLoop({
    required this.name,
    required this.getTargetVolume,
    this.volumeFade = 0.05,
  }) {
    // load().catchError((error){
    //    print('an error occurred loading $name');
    //    print(error);
    // });
  }

  double get volume => audioPlayer.volume;

  Future load() async {
    // final d = await audioPlayer.setAsset('audio/$name.mp3');
    // audioPlayer.play();
    // audioPlayer.positionStream.listen(onPositionChanged);
    // if (d == null) throw Exception('could not get duration for $name');
    // durationInSeconds = d.inSeconds;
    // duration = d;
    // await audioPlayer.setLoopMode(LoopMode.one);
    // setVolume(0);
  }

  void onPositionChanged(Duration duration){
    if (duration.inSeconds < durationInSeconds) return;
    restart();
  }

  void restart(){
    // audioPlayer.seek(const Duration());
  }

  void update(){
    // final targetVolume = clamp01(getTargetVolume());
    // final volumeDelta = (targetVolume - volume) * volumeFade;
    // if (volumeDelta.abs() < minVolumeDelta) {
    //   if (targetVolume == 0 && volume != 0){
    //     setVolume(0);
    //   }
    //   return;
    // }
    // setVolume(volume + volumeDelta);
  }

  void setVolume(double value){
    // if (volume == value) return;
    // final clampedVolume = clamp01(value);
    // if (volume == clampedVolume) return;
    // audioPlayer.setVolume(clampedVolume);
  }
}
