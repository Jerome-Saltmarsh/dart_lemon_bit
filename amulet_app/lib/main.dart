import 'package:amulet_app/classes/amulet_app.dart';
import 'package:amulet_app/ui/classes/amulet_app_builder.dart';
import 'package:amulet_flutter/amulet_client.dart';
import 'package:flutter/material.dart';

void main() {
  print('main()');
  runApp(
      AmuletAppBuilder(
        amuletApp: AmuletApp(),
  ));
}

