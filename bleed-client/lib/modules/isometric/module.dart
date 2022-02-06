

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
  final constants = IsometricConstants();
  final subscriptions = IsometricSubscriptions();
  final map = IsometricMaps();
  late final IsometricProperties properties;
  late final IsometricRender render;
  late final IsometricActions actions;
  late final IsometricUpdate update;
  late final IsometricInstances instances;
  late final IsometricEvents events;
  late final IsometricQueries queries;

  IsometricModule(){
    instances = IsometricInstances(state);
    queries = IsometricQueries(state);
    actions = IsometricActions(queries, constants);
    events = IsometricEvents(state, actions);
    update = IsometricUpdate(queries);
    properties = IsometricProperties(state);
    render = IsometricRender(state, properties);
  }
}