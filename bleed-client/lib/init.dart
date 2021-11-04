import 'package:bleed_client/audio.dart';
import 'package:bleed_client/bleed.dart';
import 'package:bleed_client/engine/GameWidget.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';

Future init() async {
  initBleed();
  initAudioPlayers();
  await images.load();
  initUI();
  rebuildUI();

  onRightClickChanged.stream.listen((bool down){
    inputRequest.sprint = down;
  });
}