
import 'package:just_audio/just_audio.dart';

class AudioSingle {
  final String name;
  final audioPlayer = AudioPlayer();

  AudioSingle({
    required this.name,
  }){
    // audioPlayer.setAsset('audio/$name.mp3').then((value) {
    //   audioPlayer.processingStateStream.listen(onProcessingStateStreamChanged);
    // });
  }

  void onProcessingStateStreamChanged(ProcessingState state){
    // if (state == ProcessingState.completed){
    //   audioPlayer.pause();
    // }
  }

  void call([double volume = 1.0]){
    // play(volume: volume);
  }

  void stop(){
    // audioPlayer.stop();
  }

  void play({double volume = 1.0}) async {
    // if (volume <= 0) return;
    // final audioPlayer = this.audioPlayer;
    // await audioPlayer.setVolume(min(volume, 1));
    // if (audioPlayer.audioSource == null) throw Exception('no audio source');
    // await audioPlayer.seek(null);
    // if (!audioPlayer.playing){
    //   await audioPlayer.play().catchError((error){
    //     print('failed to play $name');
    //   });
    // }
  }
}
