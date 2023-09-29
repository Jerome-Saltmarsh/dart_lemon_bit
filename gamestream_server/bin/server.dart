import 'dart:io';

import 'package:gamestream_server/database/classes/database_local.dart';
import 'package:gamestream_server/gamestream.dart';
import 'package:gamestream_server/packages/utils/system.dart';

void main() {

  GamestreamServer(
     database: isLocalMachine
         ? DatabaseLocal(path: Directory.current.path)
         : DatabaseFirestore()
  );
}

