
import 'dart:io';

import 'package:lemon_atlas/sync/classes/sync_job.dart';
import 'package:lemon_atlas/sync/synchronize.dart';
import 'package:lemon_atlas/utils/clean_url.dart';

SyncJob? buildSyncJob({
      required File file,
      required String dirRenders,
      required String dirSprites,
}) {
  final lastModified = file.lastModifiedSync();
  final nameAbsolute = file.path.replaceAll(dirRenders, '');
  final name = removeLastDirectory(nameAbsolute);
  final fileName = getLastFolder(name);
  final targetDirectory = removeLastDirectory('$dirSprites/$name');
  final filePath = '$targetDirectory/$fileName';
  final fileJson = File('$filePath.json');
  final filePng = File('$filePath.png');
  final srcDir = file.parent.path;

  if (
    !fileJson.existsSync() ||
    !filePng.existsSync() ||
    fileJson.lastModifiedSync().isBefore(lastModified) ||
    filePng.lastModifiedSync().isBefore(lastModified)
  ){
    return SyncJob(
        source: cleanUrl(srcDir),
        target: cleanUrl(targetDirectory),
        name: cleanUrl(fileName),
    );
  }
}
