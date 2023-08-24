import 'dart:io';

import 'package:image/image.dart';
import 'package:lemon_atlas/io/load_file_bytes.dart';

import 'enums/character_state.dart';
import 'enums/kid_part.dart';

Future<List<Image>> getImagesKid(CharacterState state, KidPart part) async {
  final directoryName = '${Directory.current.path}/assets/renders/kid/${part.groupName}/${part.fileName}/${state.name}';
  final images = <Image> [];
  for (var i = 1; i <= 64; i++){
    final iPadded = i.toString().padLeft(4, '0');
    final fileName = '$directoryName/$iPadded.png';
    final bytes = await loadFileBytes(fileName);
    var image = decodePng(bytes);

    if (image == null) {
      throw Exception();
    }
    if (image.format != Format.int8){
      image = image.convert(format: Format.int8);
    }
    images.add(image);
  }
  return images;
}
