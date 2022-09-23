import 'package:bleed_common/control_scheme.dart';
import 'package:gamestream_flutter/events/on_changed_control_scheme.dart';
import 'package:lemon_watch/watch.dart';

final gameOptions = GameOptions();

class GameOptions {
  final controlScheme = Watch(ControlScheme.schemeA, onChanged: onChangedControlScheme);
}