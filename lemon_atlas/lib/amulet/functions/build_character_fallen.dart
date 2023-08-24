import 'package:lemon_atlas/amulet/variables/directory_tmp.dart';
import 'package:lemon_atlas/atlas/src.dart';

import '../enums/character_state.dart';
import 'get_images_fallen.dart';


void buildCharacterFallen(CharacterState characterState) async {
  final images = await getImagesFallenForCharacterState(characterState);

  if (images.isEmpty) {
    throw Exception();
  }

  final sprite = buildSpriteFromSrcImages(
    srcImages: images,
    rows: 8,
    columns: 8,
  );

  exportSprite(
      sprite: sprite,
      directory: '$directoryTmp/fallen',
      name: characterState.name,
  );
}
