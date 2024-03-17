
import 'package:amulet_connect/enums/server_mode.dart';

String getServerModeText(ServerMode serverMode) => switch (serverMode) {
      ServerMode.local => 'OFFLINE',
      ServerMode.remote => 'ONLINE'
    };
