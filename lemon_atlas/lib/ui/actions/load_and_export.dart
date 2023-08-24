
import 'package:lemon_widgets/lemon_widgets.dart';

import 'export_file.dart';
import 'export_files.dart';

void loadAndExport({
  required int rows,
  required int columns,
}) async {
  final files = await loadFilesFromDisk();

  if (files == null) {
    return;
  }

  files.length == 1
      ? exportFile(files, rows, columns)
      : exportFiles(files: files, rows: rows, columns: columns);
}

