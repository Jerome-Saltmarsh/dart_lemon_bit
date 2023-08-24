
import 'dart:io';

import 'package:image/image.dart';
import 'package:lemon_atlas/atlas/functions/src.dart';
import 'package:lemon_atlas/io/create_directory_if_not_exists.dart';

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
    directory: 'C:/Users/Jerome/github/bleed/lemon_atlas/assets/sprites_3/kid/${part.groupName}/${part.fileName}',
    name: state.name,
  );
}
