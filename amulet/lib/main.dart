import 'package:amulet/classes/amulet_app.dart';
import 'package:amulet/ui/classes/amulet_app_builder.dart';
import 'package:amulet_client/amulet/amulet_client.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  windowManager.ensureInitialized().then((value) {
    windowManager.setFullScreen(true);
  });

  runApp(
      AmuletAppBuilder(
        amuletApp: AmuletApp(AmuletClient()),
  ));
}

