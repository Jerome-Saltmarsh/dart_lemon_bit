import 'package:amulet_flutter/server/server_mode.dart';

String getServerModeText(ServerMode serverMode) => switch (serverMode) {
      ServerMode.local => 'OFFLINE',
      ServerMode.remote => 'ONLINE'
    };
