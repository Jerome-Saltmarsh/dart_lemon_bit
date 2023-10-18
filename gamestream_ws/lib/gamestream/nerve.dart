import 'dart:async';
import 'dart:io';

import 'package:gamestream_ws/gamestream/server.dart';
import 'package:gamestream_ws/user_service/user_service.dart';
import 'package:gamestream_ws/packages.dart';
import 'amulet.dart';

class Nerve {
  late final Amulet amulet;
  late final Server server;
  final UserService userService;
  final bool admin;

  Nerve({
    required this.userService,
    this.admin = false,
  }){
    server = Server(nerve: this);
    amulet = Amulet(nerve: this);
    _construct();
  }

  Future _construct() async {
    printSystemInformation();
    await amulet.construct();
    await server.construct();
  }

  void printSystemInformation() {
    print('gamestream-version: $version');
    print('dart-version: ${Platform.version}');
    print("environment: ${isLocalMachine
        ? "Jerome's Computer" : "Google Cloud"}");
  }
}