
import 'package:just_audio/just_audio.dart';

class AudioSingle {
  final String name;
  late AudioSource source;
  final player = AudioPlayer();

  AudioSingle(this.name){
    source = AudioSource.uri(Uri.parse('assets/audio/sounds/$name.mp3'));
    player.setAudioSource(source);
  }

  void call(double volume){
    play(volume: volume);
  }

  void play({double volume = 1.0}) async {
    await player.setVolume(volume);
    if (player.audioSource == null) throw Exception("no audio source");
    await player.seek(const Duration());
    await player.play();
  }
}
