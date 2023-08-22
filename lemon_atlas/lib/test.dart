
import 'dart:io';

void main() async {
  final file = File('hello.txt');
  final content = 'Hello, World!';

  file.writeAsStringSync(content);

  print('File created and content saved.');
}


