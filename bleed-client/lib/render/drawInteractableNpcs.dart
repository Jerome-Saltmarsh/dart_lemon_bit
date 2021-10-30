import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/functions/diffOver.dart';
import 'package:bleed_client/engine/functions/drawText.dart';
import 'package:bleed_client/engine/properties/mouseWorld.dart';
import 'package:bleed_client/render/drawCanvas.dart';
import 'package:bleed_client/render/drawCharacterMan.dart';
import 'package:bleed_client/state.dart';

void drawInteractableNpcs() {
  for (int i = 0; i < compiledGame.totalNpcs; i++) {
    Character interactableNpc = compiledGame.interactableNpcs[i];
    drawCharacterMan(interactableNpc);
    if (diffOver(interactableNpc.x, mouseWorldX, 50)) continue;
    if (diffOver(interactableNpc.y, mouseWorldY, 50)) continue;
    drawText(compiledGame.interactableNpcs[i].name, interactableNpc.x - charWidth * compiledGame.interactableNpcs[i].name.length,
        interactableNpc.y);
  }
}

