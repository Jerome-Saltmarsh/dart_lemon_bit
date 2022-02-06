

import 'actions.dart';
import 'constants.dart';
import 'events.dart';
import 'instances.dart';
import 'maps.dart';
import 'properties.dart';
import 'queries.dart';
import 'render.dart';
import 'state.dart';
import 'subscriptions.dart';
import 'update.dart';

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
    properties = IsometricProperties(state);
    queries = IsometricQueries(state);
    actions = IsometricActions(state, queries, constants, properties);
    events = IsometricEvents(state, actions, properties);
    update = IsometricUpdate(queries);
    render = IsometricRender(state, properties, queries, map);
  }
}