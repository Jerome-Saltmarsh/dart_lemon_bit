
import 'package:bleed_client/modules/core/build.dart';
import 'package:bleed_client/modules/core/events.dart';
import 'package:bleed_client/modules/core/state.dart';

/// Controls the flow of the entire application
class CoreModule {
  final state = CoreState();
  final build = CoreBuild();
  final events = CoreEvents();
}