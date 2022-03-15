

import 'package:firestore_client/firestoreService.dart';
import 'package:gamestream_flutter/classes/Timeline.dart';
import 'package:gamestream_flutter/common/GameStatus.dart';
import 'package:lemon_watch/watch.dart';

import 'enums.dart';

class CoreState {
  final Watch<OperationStatus> operationStatus = Watch(OperationStatus.None);
  final Watch<String?> error = Watch(null);
  final Watch<Account?> account = Watch(null);
  final Watch<Mode> mode = Watch(Mode.Website);
  final Watch<Region> region = Watch(Region.Australia);
  final String title = "GAMESTREAM";
  final Watch<double> download = Watch(0);
  final Timeline timeline = Timeline();
  final debug = true;
  final Watch<GameStatus> status = Watch(GameStatus.None);
  final Watch<GameStatus> statusPrevious = Watch(GameStatus.None);
}