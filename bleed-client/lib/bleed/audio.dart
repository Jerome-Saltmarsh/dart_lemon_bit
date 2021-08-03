import 'package:audioplayers/audioplayers.dart';

AudioPlayer _audioPlayer = AudioPlayer();

void playAudioShotgunShot() {
  _playMp3('shotgun-shot');
}

void playAudioHandgunShot() {
  _playMp3('handgun-shot');
}

void _playMp3(String name){
  _audioPlayer.play('assets/audio/$name.mp3', isLocal: true);
}

