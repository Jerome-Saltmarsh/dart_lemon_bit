import 'dart:io';


String removeLastDirectory(String path) {
  final parts = path.split(Platform.pathSeparator);
  if (parts.isNotEmpty) {
    parts.removeLast();
  }
  return parts.join(Platform.pathSeparator);
}


String getLastFolder(String path) {
  final parts = path.split(Platform.pathSeparator);
  if (parts.isNotEmpty) {
    return parts.last;
  }
  return '';
}

String getParentName(File file) {
  final segments = file.parent.uri.pathSegments;
  if (segments.length <= 2){
    return '';
  }
  return segments[segments.length - 2];
}

