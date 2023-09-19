
import 'package:lemon_atlas/amulet/functions/load_images_from_directory.dart';
import 'package:lemon_atlas/amulet/src.dart';
import 'package:lemon_atlas/atlas/functions/src.dart';


Future buildCharacterKid({
  required CharacterState state,
  required KidPart part,
  required Perspective perspective,
}) async {

  final perspectiveIso = perspective == Perspective.isometric;
  final renderDir = perspectiveIso ? directoryRendersIsometric : directoryRendersFront;
  final directory = '$renderDir/kid/${part.groupName}/${part.fileName}/${state.name}';
  final srcImages = await loadImagesFomDirectory(directory);

  final sprite = buildSpriteFromSrcImages(
    srcImages: srcImages,
    rows: 8,
    columns: srcImages.length ~/ 8,
  );

  final outputDirectory = perspectiveIso
      ? directorySpritesIsometric : directorySpritesFront;

  return exportSprite(
    sprite: sprite,
    directory: '$outputDirectory/kid/${part.groupName}/${part.fileName}',
    name: state.name,
  );
}
