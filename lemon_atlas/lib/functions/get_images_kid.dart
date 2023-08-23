import 'dart:io';

import 'package:image/image.dart';
import 'package:lemon_atlas/enums/character_state.dart';
import 'package:lemon_atlas/enums/kid_part.dart';

import 'load_file_bytes.dart';

Future<List<Image>> getImagesKid(CharacterState state, KidPart part) async {
  final directoryName = '${Directory.current.path}/assets/renders/kid/${part.groupName}/${part.fileName}/${state.name}';
  final images = <Image> [];
  for (var i = 1; i <= 64; i++){
    final iPadded = i.toString().padLeft(4, '0');
    final fileName = '$directoryName/$iPadded.png';
    final bytes = await loadFileBytes(fileName);
    final image = decodePng(bytes);

    if (image == null) {
      throw Exception();
    }
    images.add(image);
  }
  return images;
}
