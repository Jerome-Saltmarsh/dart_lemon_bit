import 'dart:io';

import 'package:flutter/material.dart';
import 'sync/functions/sync_all.dart';
import 'sync/ui/sync_ui.dart';

void main(List<String> arguments) {

  if (arguments.any((element) => element == 'sync_all')) {
    syncAll();
    exit(0);
  } else {
    runApp(SyncUI());
  }

}




