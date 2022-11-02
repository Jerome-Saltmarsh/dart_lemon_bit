
import 'package:gamestream_flutter/library.dart';
import 'package:just_audio/just_audio.dart';

class AudioSingle {
  final String name;
  late AudioSource source;
  late double volume;
  late double maxDistance;
  final audioPlayer = AudioPlayer();

  String get url => 'assets/audio/sounds/$name.mp3';

  AudioSingle({
    required this.name,
    required this.volume,
    this.maxDistance = 200,
  }){
    source = AudioSource.uri(Uri.parse(url));
    audioPlayer.setAudioSource(source);
    audioPlayer.processingStateStream.listen(onProcessingStateStreamChanged);
  }

  void onProcessingStateStreamChanged(ProcessingState state){
    if (state == ProcessingState.completed){
      audioPlayer.pause();
    }
  }

  void call([double volume = 1.0]){
    play(volume: volume);
  }

  void playV3(Vector3 value){
    playXYZ(value.x, value.y, value.z);
  }

  void playXYZ(double x, double y, double z){
    final distanceFromPlayer = GamePlayer.position.distance3(x, y, z);
    final distanceVolume = GameAudio.convertDistanceToVolume(
        distanceFromPlayer,
        maxDistance: maxDistance,
    );
    play(volume: distanceVolume);
  }

  void play({double volume = 1.0}) async {
    final playVolume = this.volume * volume;
    if (playVolume <= 0) return;
    await audioPlayer.setVolume(playVolume);
    if (audioPlayer.audioSource == null) throw Exception("no audio source");
    await audioPlayer.seek(null);
    if (!audioPlayer.playing){
      await audioPlayer.play().catchError((error){
        print("failed to play $name");
      });
    }
  }
}
