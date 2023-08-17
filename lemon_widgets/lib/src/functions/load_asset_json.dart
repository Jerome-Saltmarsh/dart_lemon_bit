import 'dart:convert';

import 'package:flutter/services.dart';

Future<Map<String, dynamic>> loadAssetJson(String filename) async {
  final jsonContents = await rootBundle.loadString(filename);
  return jsonDecode(jsonContents);
}