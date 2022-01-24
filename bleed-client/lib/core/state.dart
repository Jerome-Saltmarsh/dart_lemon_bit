

import 'package:bleed_client/enums/OperationStatus.dart';
import 'package:lemon_watch/watch.dart';

class CoreState {
  final Watch<OperationStatus> operationStatus = Watch(OperationStatus.None);
}