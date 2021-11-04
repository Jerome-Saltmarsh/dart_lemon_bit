import 'package:bleed_client/classes/Settings.dart';
import 'package:bleed_client/engine/GameWidget.dart';
import 'package:bleed_client/state/sharedPreferences.dart';

Settings settings = Settings();

void toggleAudioMuted(){
  settings.audioMuted = !settings.audioMuted;
  rebuildUI();
  sharedPreferences.setBool('audioMuted' , settings.audioMuted);
}