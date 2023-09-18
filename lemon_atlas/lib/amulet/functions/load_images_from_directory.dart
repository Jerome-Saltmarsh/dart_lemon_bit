import 'package:image/image.dart';
import 'package:lemon_atlas/io/load_file_bytes.dart';

Future<List<Image>> loadImagesFomDirectory(String directoryName, {required int total}) async {
  final images = <Image> [];
  for (var i = 1; i <= total; i++){
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
