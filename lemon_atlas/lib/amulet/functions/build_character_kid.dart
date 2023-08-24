
import 'package:lemon_atlas/amulet/src.dart';
import 'package:lemon_atlas/atlas/functions/src.dart';

Future buildCharacterKid({
  required CharacterState state,
  required KidPart part,
}) async {

  final srcImages = await getImagesKid(state, part);

  final sprite = buildSpriteFromSrcImages(
    srcImages: srcImages,
    rows: 8,
    columns: 8,
  );

  return exportSprite(
    sprite: sprite,
    directory: '$directoryTmp/kid/${part.groupName}/${part.fileName}',
    name: state.name,
  );
}
