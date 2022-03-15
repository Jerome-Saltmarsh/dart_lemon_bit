
import 'package:gamestream_flutter/modules/core/state.dart';

import 'actions.dart';
import 'build.dart';
import 'events.dart';
import 'properties.dart';

/// Controls the flow of the entire application
class CoreModule {
  late final events;
  late final properties;
  final state = CoreState();
  final build = CoreBuild();
  final actions = CoreActions();

  CoreModule(){
    events = CoreEvents(state);
    properties = CoreProperties(state);
  }
}