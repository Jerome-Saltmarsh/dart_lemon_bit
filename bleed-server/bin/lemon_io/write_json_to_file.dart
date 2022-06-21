import 'dart:convert';
import 'dart:io';

import 'write_string_to_file.dart';


Future<File> writeJsonToFile({
  required String fileName,
  required String directory,
  required Map<String, dynamic> contents
}) async {
   return writeStringToFile(
       fileName: fileName,
       directory: directory,
       contents: jsonEncode(contents)
   );
}