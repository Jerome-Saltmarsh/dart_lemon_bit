import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/getters/getShading.dart';
import 'package:bleed_client/getters/isWaterAt.dart';
import 'package:bleed_client/mappers/mapCharacterToDst.dart';
import 'package:bleed_client/mappers/mapCharacterToImageZombie.dart';
import 'package:bleed_client/mappers/mapHumanToRect.dart';
import 'package:lemon_engine/queries/on_screen.dart';
import 'package:lemon_engine/render/draw_image_rect.dart';

enum CharacterType {
  Human,
  Zombie
}

// void drawCharacterZombie(Character character) {
//   if (!character.alive && isWaterAt(character.x, character.y)) return;
//   if (!onScreen(character.x, character.y)) return;
//
//   Shade shade = getShadeAtPosition(character.x, character.y);
//   if (shade.index >= Shade.VeryDark.index) return;
//
//   drawImageRect(
//     mapCharacterToImageZombie(
//         character.state,
//         character.weapon,
//         shade,
//     ),
//     mapCharacterToSrcZombie(
//         character.weapon,
//         character.state,
//         character.direction,
//         character.frame),
//     mapCharacterToDstMan(character),
//   );
// }

