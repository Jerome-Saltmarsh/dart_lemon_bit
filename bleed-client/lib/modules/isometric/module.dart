

import 'package:bleed_client/modules/isometric/actions.dart';
import 'package:bleed_client/modules/isometric/constants.dart';
import 'package:bleed_client/modules/isometric/events.dart';
import 'package:bleed_client/modules/isometric/instances.dart';
import 'package:bleed_client/modules/isometric/maps.dart';
import 'package:bleed_client/modules/isometric/properties.dart';
import 'package:bleed_client/modules/isometric/render.dart';
import 'package:bleed_client/modules/isometric/state.dart';
import 'package:bleed_client/modules/isometric/subscriptions.dart';
import 'package:bleed_client/modules/isometric/update.dart';

class IsometricModule {
  final state = IsometricState();
  final actions = IsometricActions();
  final subscriptions = IsometricSubscriptions();
  final events = IsometricEvents();
  final properties = IsometricProperties();
  final constants = IsometricConstants();
  final map = IsometricMaps();
  final render = IsometricRender();
  final update = IsometricUpdate();
  late final IsometricInstances instances;

  IsometricModule(){
    instances = IsometricInstances(state);
  }
}