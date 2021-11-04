import 'package:bleed_client/audio.dart';
import 'package:bleed_client/engine/GameWidget.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';

Future init() async {
  initAudioPlayers();
  await images.load();
  initUI();
  rebuildUI();
}