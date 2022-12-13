import 'package:just_audio/just_audio.dart';
import 'package:lemon_math/library.dart';

class AudioLoop {

  static const Min_Volume_Change = 0.005;
  static const Volume_Fade = 0.05;

  final String name;
  var volume = 0.0;
  double Function() getTargetVolume;
  final audioPlayer = AudioPlayer();
  late Duration duration;
  var durationInSeconds = 0;

  AudioLoop({required this.name, required this.getTargetVolume}) {
    load().catchError((error){
       print("an error occurred loading $name");
       print(error);
    });
  }

  Future load() async {
    final d = await audioPlayer.setUrl('assets/audio/sounds/$name.mp3');
    audioPlayer.play();
    audioPlayer.positionStream.listen(onPositionChanged);
    if (d == null) throw Exception("could not get duration for $name");
    durationInSeconds = d.inSeconds;
    duration = d;
    audioPlayer.setLoopMode(LoopMode.one);
    setVolume(0);
  }

  void onPositionChanged(Duration duration){
    if (duration.inSeconds < durationInSeconds) return;
    restart();
  }

  void restart(){
    audioPlayer.seek(const Duration());
  }

  void update(){
    final targetVolume = clamp01(getTargetVolume());
    final change = (targetVolume - volume) * Volume_Fade;
    if (change.abs() < Min_Volume_Change) return;
    setVolume(volume + change);
  }

  void setVolume(double value){
    if (volume == value) return;
    final clampedVolume = clamp01(value);
    if (volume == clampedVolume) return;
    audioPlayer.setVolume(clampedVolume);
  }
}
