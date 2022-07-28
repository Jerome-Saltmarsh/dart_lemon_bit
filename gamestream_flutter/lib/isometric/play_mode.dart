import 'package:gamestream_flutter/isometric/events/on_changed_mode.dart';
import 'package:lemon_watch/watch.dart';

final playMode = Watch(Mode.Play, onChanged: onChangedMode);

bool get playModeEdit => playMode.value == Mode.Edit;
bool get modeIsPlay => playMode.value == Mode.Play;

void setPlayModePlay() => playMode.value = Mode.Play;
void setPlayModeEdit() => playMode.value = Mode.Edit;

void actionPlayModeToggle(){
    modeIsPlay ? setPlayModeEdit() : setPlayModePlay();
}

enum Mode {
    Play,
    Edit,
}

const playModes = Mode.values;

