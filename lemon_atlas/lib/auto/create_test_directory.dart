
import 'dart:io';

void createTextDirectory(String fileContent) {
  // Define the file name and content.
  String directoryPath = 'C:/Users/Jerome/test_hello_saved';
  String fileName = 'hello.txt';

  // Create the directory if it doesn't exist.
  Directory(directoryPath).createSync(recursive: true);

  // Create a File object with the full path.
  File file = File('$directoryPath/$fileName');

  // Write the content to the file.
  file.writeAsString(fileContent).then((_) {
    print('File "$fileName" created with content "$fileContent"');
    exit(0);
  }).catchError((error) {
    print('Error creating file: $error');
    exit(0);
  });
}
