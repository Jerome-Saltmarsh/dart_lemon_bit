

import 'package:bleed_common/GameStatus.dart';
import 'package:firestore_client/firestoreService.dart';
import 'package:gamestream_flutter/modules/core/events.dart';
import 'package:lemon_watch/watch.dart';

import 'enums.dart';

class CoreState {
  final operationStatus = Watch(OperationStatus.None);
  final error = Watch<String?>(null);
  final account = Watch<Account?>(null);
  final mode = Watch(Mode.Website);
  final region = Watch(Region.LocalHost, onChanged: onChangedRegion);
  final download = Watch(0.0);
  final debug = true;
  final status = Watch(GameStatus.None);
}