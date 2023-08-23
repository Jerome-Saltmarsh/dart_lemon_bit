import 'dart:io';

import 'package:image/image.dart';
import 'package:lemon_atlas/enums/character_state.dart';
import 'package:lemon_atlas/functions/load_file_bytes.dart';

Future<List<Image>> getImagesFallen(CharacterState state) async {
  final directoryName = '${Directory.current.path}/assets/renders/fallen/${state.name}';
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
