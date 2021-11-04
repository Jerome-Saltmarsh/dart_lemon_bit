import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/functions/diffOver.dart';
import 'package:bleed_client/engine/render/drawText.dart';
import 'package:bleed_client/engine/properties/mouseWorld.dart';
import 'package:bleed_client/render/constants/charWidth.dart';
import 'package:bleed_client/render/drawCharacterMan.dart';

void drawInteractableNpc(Character npc) {
  drawCharacterMan(npc);
  if (diffOver(npc.x, mouseWorldX, 50)) return;
  if (diffOver(npc.y, mouseWorldY, 50)) return;
  drawText(npc.name, npc.x - charWidth * npc.name.length, npc.y);
}



