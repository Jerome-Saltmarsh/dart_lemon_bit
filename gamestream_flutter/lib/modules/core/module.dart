
import 'actions.dart';
import 'events.dart';
import 'properties.dart';

/// Controls the flow of the entire application
class CoreModule {
  late final events;
  late final properties;
  final actions = CoreActions();

  CoreModule(){
    events = CoreEvents();
    properties = CoreProperties();
  }
}