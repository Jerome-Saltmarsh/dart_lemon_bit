

import 'package:bleed_client/classes/Timeline.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/user-service-client/firestoreService.dart';
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