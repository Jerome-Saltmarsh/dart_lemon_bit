import 'package:gamestream_flutter/isometric/events/on_play_mode_changed.dart';
import 'package:lemon_watch/watch.dart';

final playMode = Watch(PlayMode.Play, onChanged: onPlayModeChanged);

bool get playModeEdit => playMode.value == PlayMode.Edit;
bool get playModePlay => playMode.value == PlayMode.Play;
bool get playModeDebug => playMode.value == PlayMode.Debug;

enum PlayMode {
    Play,
    Edit,
    Debug,
    Audio,
    File,
}

const playModes = PlayMode.values;

void playModeToggle() {
    playMode.value = playModes[(playMode.value.index + 1) % playModes.length];
}
