import 'dart:io';

String getFileSystemEntityFileName(FileSystemEntity entity) =>
    entity.path.split("\\").last;