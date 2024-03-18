import 'package:amulet/classes/amulet_connect.dart';
import 'package:amulet/ui/classes/amulet_connect_ui.dart';
import 'package:amulet_client/amulet/amulet_client.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  windowManager.ensureInitialized().then((value) {
    windowManager.setFullScreen(true);
  });

  runApp(
      AmuletConnectUI(
        amuletApp: AmuletConnect(AmuletClient()),
  ));
}

