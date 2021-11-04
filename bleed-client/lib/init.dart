import 'package:bleed_client/engine/render/gameWidget.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';

Future init() async {
  await images.load();
  initUI();
  rebuildUI();
}