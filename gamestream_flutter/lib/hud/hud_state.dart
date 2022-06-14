import 'package:lemon_watch/watch.dart';

final hud = _HudState();

class _HudState {
  final editToolsEnabled = Watch(true);

  void toggleEditToolsEnabled() => editToolsEnabled.value = !editToolsEnabled.value;
}