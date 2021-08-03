import 'dart:ui';

import 'package:flutter_game_engine/game_engine/game_resources.dart';
import 'package:howler/howler.dart';
import 'package:universal_html/html.dart';
import 'package:audioplayers/audioplayers.dart';

Image imageHuman;
Image imageTiles;
Image tileGrass01;
Howl howlShotgunFireAudio;
Howl howlPistolFireAudio;
AudioElement audioElementPistolShot;
AudioPlayer audioPlayer = AudioPlayer();

Future loadResources() async {
  await _loadImages();
}

Future<void> _loadImages() async {
  tileGrass01 = await loadImage("images/tile-grass-01.png");
  imageHuman = await loadImage("images/iso-character.png");
  imageTiles = await loadImage("images/Tiles.png");
}

void loadHtmlAudioFiles() {
  print("loading html audio");
  try {
    audioElementPistolShot = AudioElement();
    audioElementPistolShot.id = 'handgun-shot';
    audioElementPistolShot.src = 'audio/handgun-shot.mp3';
    print("load html audio succeeded");
  } catch (error) {
    print('loading audio error');
    print(error);
  }
}

void loadHowlAudio(){
  print("load");
  howlShotgunFireAudio = loadAudio('audio/shotgun-fire.mp3');
  howlPistolFireAudio = loadAudio('audio/handgun-shot.mp3');
  print("how loaded");
}

Howl loadAudio(String fileName, {double volume = 0.6}) {
  Howl howl = Howl(
    src: [fileName],
    loop: false,
    volume: volume,
    preload: true,
    html5: true,
  );
  howl.load();
  return howl;
}

void playAudioShotgunShot() {}


void playAudioPistolShot() {
  playerAudioPlayer();
}

void playHowlAudioShot() {
  try {
    if (howlPistolFireAudio != null) {
      print("playing howl pistol shot");
      howlPistolFireAudio.setVolume(1);
      howlPistolFireAudio.mute(false);
      howlPistolFireAudio.play();
    }
  }catch(error){
    print('howl error');
    print(error);
  }
}

void playerAudioPlayer(){
  audioPlayer.play('assets/audio/handgun-shot.mp3', isLocal: true);
}

void playHtmlAudioShot() {
  try {
    if (audioElementPistolShot != null) {
      print("playing audio pistol shot");
      audioElementPistolShot.volume = 1;
      audioElementPistolShot.muted = false;
      try {
        audioElementPistolShot.play().catchError((error){
          print(error);
          print(audioElementPistolShot.error);
        });
        print("plaed audio element pistol shot");
        print(audioElementPistolShot.error);
      } catch (e) {
        print('failed to play audioPistolShot');
        print(e);
        print(audioElementPistolShot.error);
      }
    }
  }catch(error){
    print('html audio error');
    print(error);
  }
}
