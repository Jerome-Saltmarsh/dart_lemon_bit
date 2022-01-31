

import 'actions.dart';
import 'constants.dart';
import 'events.dart';
import 'instances.dart';
import 'maps.dart';
import 'properties.dart';
import 'queries.dart';
import 'render.dart';
import 'subscriptions.dart';
import 'update.dart';
import 'state.dart';

class IsometricModule {
  final state = IsometricState();
  final actions = IsometricActions();
  final subscriptions = IsometricSubscriptions();
  final properties = IsometricProperties();
  final constants = IsometricConstants();
  final map = IsometricMaps();
  final render = IsometricRender();
  final update = IsometricUpdate();
  late final IsometricInstances instances;
  late final IsometricEvents events;
  late final IsometricQueries queries;

  IsometricModule(){
    instances = IsometricInstances(state);
    events = IsometricEvents(state, actions);
    queries = IsometricQueries(state);
  }
}