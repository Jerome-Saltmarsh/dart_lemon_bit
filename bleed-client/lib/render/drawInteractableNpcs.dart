import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/render/enums/CharacterType.dart';
import 'package:bleed_client/render/constants/charWidth.dart';
import 'package:bleed_client/render/drawCharacter.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/render/draw_text.dart';
import 'package:lemon_math/diff_over.dart';

void drawInteractableNpc(Character npc) {
  drawCharacter(npc, CharacterType.Human);
  if (diffOver(npc.x, mouseWorldX, 50)) return;
  if (diffOver(npc.y, mouseWorldY, 50)) return;
  drawText(npc.name, npc.x - charWidth * npc.name.length, npc.y);
}



