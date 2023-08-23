
import 'package:image/image.dart';
import 'package:lemon_atlas/functions/build_atlas.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

void buildAtlas({
  required int rows,
  required int columns,
}) async {
  final file = await loadFileFromDisk();

  if (file == null) {
    return;
  }

  final fileBytes = file.bytes;
  if (fileBytes == null){
    throw Exception();
  }

  buildFromAtlas(
      srcImage: decodePng(fileBytes) ?? (throw Exception()),
      rows: rows,
      columns: columns,
      name: file.name.replaceAll('.png', ''),
  );
}