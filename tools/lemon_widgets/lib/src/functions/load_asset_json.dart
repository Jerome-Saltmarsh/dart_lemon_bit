import 'dart:convert';

import 'package:flutter/services.dart';

Future<Map<String, dynamic>> loadAssetJson(String filename) async {
  return jsonDecode(await rootBundle.loadString(filename));
}