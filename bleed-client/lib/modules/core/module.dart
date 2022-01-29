
import 'package:bleed_client/modules/core/actions.dart';
import 'package:bleed_client/modules/core/build.dart';
import 'package:bleed_client/modules/core/events.dart';
import 'package:bleed_client/modules/core/properties.dart';
import 'package:bleed_client/modules/core/state.dart';

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