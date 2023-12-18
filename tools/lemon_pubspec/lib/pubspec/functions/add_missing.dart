

import 'dart:io';

void addMissing(List<String> missing, File file) {

  if (!file.existsSync()){
    throw Exception('file does not exist');
  }

  final contents = file.readAsStringSync();
  final lines = contents.split('\n');
  lines.removeWhere((element) => element.isEmpty);
  for (final missingLine in missing){
    lines.add('    $missingLine\r');
  }
  lines.add('');

  final folded = lines.fold('', (previousValue, element) => '$previousValue\n$element');
  file.writeAsStringSync(folded);
  print("all added");
}