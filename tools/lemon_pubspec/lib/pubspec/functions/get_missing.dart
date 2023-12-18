

import 'dart:io';

List<String> getMissing(File file) {

    if (!file.existsSync()){
        throw Exception('file does not exist');
    }

    final contents = file.readAsStringSync();
    final lines = contents.split('\n');
    final assetsIndex = lines.indexWhere((element) => element.contains('assets:'));

    if (assetsIndex == -1){
      throw Exception('"assets:" not found');
    }

    final assetsPath = '${file.parent.path}/assets/';
    final assets = Directory(assetsPath);

    if (!assets.existsSync()){
        throw Exception('assets directory does not exist');
    }

    final assetsPathLength = assets.path.length;
    final children = assets.listSync();
    final missing = <String>[];
    for (var i = 0 ; i < children.length; i++) {
        final child = children[i];
        if (child is! Directory) continue;
        final path = child.path;
        final relativePath = path.substring(assetsPathLength, path.length).replaceAll('\\', '/');
        final prefixedPath = '- assets/$relativePath/';
        final childIndex = lines.indexWhere((element) => element.contains(prefixedPath));
        if (childIndex == -1) {
            missing.add(prefixedPath);
        }
        children.addAll(child.listSync());
    }
    return missing;
}