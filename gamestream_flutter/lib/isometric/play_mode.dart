import 'package:gamestream_flutter/isometric/events/on_mode_changed.dart';
import 'package:lemon_watch/watch.dart';

final playMode = Watch(Mode.Play, onChanged: onModeChanged);

bool get playModeEdit => playMode.value == Mode.Edit;
bool get playModePlay => playMode.value == Mode.Play;

void setPlayModePlay() => playMode.value = Mode.Play;
void setPlayModeEdit() => playMode.value = Mode.Edit;

void actionPlayModeToggle(){
    playModePlay ? setPlayModeEdit() : setPlayModePlay();
}

enum Mode {
    Play,
    Edit,
}

const playModes = Mode.values;

