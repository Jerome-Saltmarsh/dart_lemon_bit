import 'package:audioplayers/audioplayers.dart';

import 'utils.dart';

AudioPlayer _audioPlayer = AudioPlayer();
AudioPlayer _audioPlayer2 = AudioPlayer();

void playAudioZombieHit(){
  if(randomBool()){
    _play('zombie-hit-01.wav');
  }else{
    _play('zombie-hit-02.wav');
  }
}

void playAudioShotgunShot() {
  _playMp3('shotgun-shot');
}

void playAudioHandgunShot() {
  _playMp3('handgun-shot');
}

void _playMp3(String name){
  _audioPlayer.play('assets/audio/$name.mp3', isLocal: true);
}

void _play(String name){
  _audioPlayer2.play('assets/audio/$name', isLocal: true);
}

