import 'package:amulet_flutter/types/server_mode.dart';

String getServerModeText(ServerMode serverMode) => switch (serverMode) {
      ServerMode.local => 'Single player',
      ServerMode.remote => 'Multiplayer'
    };
