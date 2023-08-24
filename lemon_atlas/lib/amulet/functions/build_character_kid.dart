
import 'dart:io';

import 'package:lemon_atlas/atlas/functions/src.dart';

import '../enums/character_state.dart';
import '../enums/kid_part.dart';
import 'get_images_kid.dart';

void buildCharacterKid({
  required CharacterState state,
  required KidPart part,
}) async {

  final srcImages = await getImagesKid(state, part);

  final sprite = buildSpriteFromSrcImages(
    srcImages: srcImages,
    rows: 8,
    columns: 8,
  );

  exportSprite(
    sprite: sprite,
    directory: '${Directory.current.path}/assets/sprites_3/kid/${part.groupName}/${part.fileName}',
    name: state.name,
  );
}
