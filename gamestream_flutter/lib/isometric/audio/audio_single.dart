
import 'package:gamestream_flutter/isometric/audio/convert_distance_to_volume.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:just_audio/just_audio.dart';

class AudioSingle {
  final String name;
  late AudioSource source;
  final players = <AudioPlayer>[];
  late double volume;
  late double maxDistance;

  String get url => 'assets/audio/sounds/$name.mp3';

  AudioSingle({
    required this.name,
    required this.volume,
    this.maxDistance = 200,
  }){
    source = AudioSource.uri(Uri.parse(url));
  }

  void call(double volume){
    play(volume: volume);
  }

  void playXYZ({required double x, required double y, required double z}){
    final distanceFromPlayer = player.distance3(x, y, z);
    final distanceVolume = convertDistanceToVolume(
        distanceFromPlayer,
        maxDistance: maxDistance,
    );
    play(volume: distanceVolume);
  }

  void play({double volume = 1.0}) async {
    final playVolume = this.volume * volume;
    if (playVolume <= 0) return;
    final player = getAudioPlayer;
    assert (!player.playing);
    await player.setVolume(playVolume);
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
