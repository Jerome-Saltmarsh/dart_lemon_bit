import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>> readJsonFromFile(String filename, {String? directory}) async {
  final dir = directory != null ? directory : Directory.current.path;
  final filePath = '$dir/$filename';
  final file = File(filePath);
  final exists = await file.exists();
  if (!exists) throw Exception("file could not be found: $filePath");
  final text = await file.readAsString();
  return jsonDecode(text);
}