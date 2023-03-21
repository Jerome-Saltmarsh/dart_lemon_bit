
import 'dart:math';

import 'package:gamestream_flutter/library.dart';
import 'package:just_audio/just_audio.dart';

class AudioSingle {
  final String name;
  late AudioSource source;
  late double volume;
  final audioPlayer = AudioPlayer();

  String get url => 'assets/audio/$name.mp3';

  AudioSingle({
    required this.name,
    required this.volume,
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

  void playV3(Vector3 value, {double maxDistance = 600}){
    playXYZ(value.x, value.y, value.z, maxDistance: maxDistance);
  }

  void playXYZ(double x, double y, double z, {double maxDistance = 600}){
    if (GameAudio.mutedSound.value) return;
    final distanceFromPlayer = GamePlayer.position.distance3(x, y, z);
    final distanceVolume = GameAudio.convertDistanceToVolume(
        distanceFromPlayer,
        maxDistance: maxDistance,
    );
    play(volume: distanceVolume);
  }

  void stop(){
    audioPlayer.stop();
  }

  void play({double volume = 1.0}) async {
    if (GameAudio.mutedSound.value) return;
    final playVolume = this.volume * volume;
    if (playVolume <= 0) return;
    await audioPlayer.setVolume(min(playVolume, 1));
    if (audioPlayer.audioSource == null) throw Exception("no audio source");
    await audioPlayer.seek(null);
    if (!audioPlayer.playing){
      await audioPlayer.play().catchError((error){
        print("failed to play $name");
      });
    }
  }
}
