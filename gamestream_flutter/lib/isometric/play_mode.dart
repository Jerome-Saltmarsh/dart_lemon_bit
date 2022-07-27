import 'package:gamestream_flutter/isometric/events/on_play_mode_changed.dart';
import 'package:lemon_watch/watch.dart';

final playMode = Watch(PlayMode.Play, onChanged: onPlayModeChanged);

bool get playModeEdit => playMode.value == PlayMode.Edit;
bool get playModePlay => playMode.value == PlayMode.Play;

void setPlayModePlay() => playMode.value = PlayMode.Play;
void setPlayModeEdit() => playMode.value = PlayMode.Edit;

void actionPlayModeToggle(){
    playModePlay ? setPlayModeEdit() : setPlayModePlay();
}

enum PlayMode {
    Play,
    Edit,
}

const playModes = PlayMode.values;

