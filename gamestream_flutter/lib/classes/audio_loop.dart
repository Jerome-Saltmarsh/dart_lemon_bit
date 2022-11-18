import 'package:just_audio/just_audio.dart';
import 'package:lemon_math/library.dart';

class AudioLoop {
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
    audioPlayer.setVolume(getTargetVolume());
  }

  void onPositionChanged(Duration duration){
    if (duration.inSeconds < durationInSeconds) return;
    restart();
  }

  void restart(){
    audioPlayer.seek(const Duration());
  }

  void update(){
    final change = (getTargetVolume() - volume) * 0.05;
    if (change.abs() < 0.005) {
       return;
    }
    volume = clamp(volume + change, 0, 1.0);
    audioPlayer.setVolume(volume);
  }

  void updateForce(){
    final change = (getTargetVolume() - volume) * 0.05;
    volume = clamp(volume + change, 0, 1.0);
    audioPlayer.setVolume(volume);
  }
}
