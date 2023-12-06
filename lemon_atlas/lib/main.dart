import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lemon_atlas/lemon_args/list_extensions.dart';
import 'sync/functions/sync_all.dart';
import 'sync/ui/sync_ui.dart';

void main(List<String> arguments) {

  if (arguments.any((element) => element == 'sync_all')) {

    final renders = arguments.tryGetArgString('--renders');
    final exports = arguments.tryGetArgString('--exports');

    if (renders == null){
      print("--renders <value> required");
      exit(0);
    }

    if (exports == null){
      print("--exports <value> required");
      exit(0);
    }

    syncAll(
      dirSprites: exports,
      dirRenders: renders
    );
    exit(0);
  } else {
    runApp(SyncUI());
  }

}




