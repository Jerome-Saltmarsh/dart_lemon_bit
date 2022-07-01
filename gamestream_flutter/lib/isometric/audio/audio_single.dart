
import 'package:just_audio/just_audio.dart';

class AudioSingle {
  final String name;
  late AudioSource source;
  final players = <AudioPlayer>[];
  late double volume;

  String get url => 'assets/audio/sounds/$name.mp3';

  AudioSingle({required this.name, required this.volume}){
    source = AudioSource.uri(Uri.parse(url));
  }

  void call(double volume){
    play(volume: volume);
  }

  void play({double? volume}) async {
    if (volume != null){
      this.volume = volume;
    }
    if (volume == 0) return;
    final player = getAudioPlayer;
    assert (!player.playing);
    await player.setVolume(this.volume);
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
