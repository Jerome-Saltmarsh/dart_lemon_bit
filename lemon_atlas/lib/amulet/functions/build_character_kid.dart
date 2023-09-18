
import 'package:lemon_atlas/amulet/functions/load_images_from_directory.dart';
import 'package:lemon_atlas/amulet/src.dart';
import 'package:lemon_atlas/atlas/functions/src.dart';


Future buildCharacterKid({
  required CharacterState state,
  required KidPart part,
  required Perspective perspective,
}) async {

  final perspectiveIso = perspective == Perspective.isometric;
  final renderDir = perspectiveIso ? 'renders' : 'renders_front';
  final directory = '$directoryAssets/$renderDir/kid/${part.groupName}/${part.fileName}/${state.name}';
  final srcImages =
      await loadImagesFomDirectory(directory, total: perspectiveIso ? 64 : 8);

  final sprite = buildSpriteFromSrcImages(
    srcImages: srcImages,
    rows: 8,
    columns: perspective == Perspective.isometric ? 8 : 1,
  );

  final outputDirectory = perspective == Perspective.isometric
      ? directorySprites : directorySpritesFront;

  return exportSprite(
    sprite: sprite,
    directory: '$outputDirectory/kid/${part.groupName}/${part.fileName}',
    name: state.name,
  );
}
