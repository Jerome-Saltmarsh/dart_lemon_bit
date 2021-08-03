import 'package:audioplayers/audioplayers.dart';

AudioPlayer _audioPlayer = AudioPlayer();

void playAudioShotgunShot() {}

void playAudioPistolShot() {
  _audioPlayer.play('assets/audio/handgun-shot.mp3', isLocal: true);
}

