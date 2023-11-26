import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:typedef/json.dart';

Future<Json> getBody(Request request) async =>
    json.decode(await request.readAsString());