import 'package:bleed_client/classes/Settings.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:lemon_engine/game.dart';

Settings settings = Settings();

void toggleAudioMuted(){
  settings.audioMuted = !settings.audioMuted;
  rebuildUI();
  sharedPreferences.setBool('audioMuted' , settings.audioMuted);
}