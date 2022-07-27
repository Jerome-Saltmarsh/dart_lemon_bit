
import 'package:gamestream_flutter/isometric/audio/convert_distance_to_volume.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
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

  void call([double volume = 1.0]){
    play(volume: volume);
  }

  void playV3(Vector3 value){
    playXYZ(value.x, value.y, value.z);
  }

  void playXYZ(double x, double y, double z){
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
    await player.setVolume(playVolume);
    if (player.audioSource == null) throw Exception("no audio source");
    await player.seek(null);
    if (!player.playing){
      await player.play().catchError((error){
        print("failed to play $name");
      });
    }
  }

  AudioPlayer get getAudioPlayer {
     for (final player in players) {
       if (player.playing) continue;
       player.seek(null);
       return player;
     }

     final newPlayer = AudioPlayer();
     newPlayer.setAudioSource(source);
     newPlayer.processingStateStream.listen((event) {
        if (event == ProcessingState.completed){
          newPlayer.pause();
        }
     });
     players.add(newPlayer);
     return newPlayer;
  }
}
