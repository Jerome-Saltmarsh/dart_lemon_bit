import 'package:bleed_client/classes/Settings.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/ui.dart';

Settings settings = Settings();

void toggleAudioMuted(){
  settings.audioMuted = !settings.audioMuted;
  redrawUI();
  sharedPreferences.setBool('audioMuted' , settings.audioMuted);
}