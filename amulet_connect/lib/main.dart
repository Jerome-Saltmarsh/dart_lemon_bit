import 'package:amulet/ui/classes/amulet_connect_ui.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  windowManager.ensureInitialized().then((value) {
    windowManager.setFullScreen(true);
  });

  runApp(
      AmuletConnectUI()
  );
}

