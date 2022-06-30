
import 'package:just_audio/just_audio.dart';

class AudioSingle {
  final String name;
  late AudioSource source;
  final players = <AudioPlayer>[];

  String get url => 'assets/audio/sounds/$name.mp3';

  AudioSingle(this.name){
    source = AudioSource.uri(Uri.parse(url));
  }

  void call(double volume){
    play(volume: volume);
  }

  void play({double volume = 1.0}) async {
    final player = getAudioPlayer;
    assert (!player.playing);
    await player.setVolume(volume);
    if (player.audioSource == null) throw Exception("no audio source");
    await player.seek(const Duration());
    await player.play();
    await player.seek(const Duration());
  }

  AudioPlayer get getAudioPlayer {
     for (final player in players) {
       if (player.playing) continue;
       return player;
     }
     final newPlayer = AudioPlayer();
     newPlayer.setAudioSource(source);
     players.add(newPlayer);
     return newPlayer;
  }
}
