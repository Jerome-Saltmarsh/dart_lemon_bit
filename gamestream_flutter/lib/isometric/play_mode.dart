import 'package:gamestream_flutter/isometric/events/on_play_mode_changed.dart';
import 'package:lemon_watch/watch.dart';

final playMode = Watch(PlayMode.Play, onChanged: onPlayModeChanged);

bool get playModeEdit => playMode.value == PlayMode.Edit;
bool get playModePlay => playMode.value == PlayMode.Play;

enum PlayMode {
    Play,
    Edit,
}

void playModeToggle(){
    if (playModePlay) {
        playModeSetEdit();
    } else {
        playModeSetPlay();
    }
}

void playModeSetPlay(){
    playMode.value = PlayMode.Play;
}

void playModeSetEdit(){
    playMode.value = PlayMode.Edit;
}