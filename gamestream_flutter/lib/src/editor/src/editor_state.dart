
import 'package:gamestream_flutter/library.dart';

class EditorState {
   static final windowEnabledScene = Watch(false);
   static final windowEnabledCanvasSize = Watch(false);
   static final windowEnabledGenerate = WatchBool(false);

   static final generateRows = WatchInt(50, min: 5, max: 200);
   static final generateColumns = WatchInt(50, min: 5, max: 200);
   static final generateHeight = WatchInt(8, min: 5, max: 20);
   static final generateOctaves = WatchInt(8, min: 0, max: 100);
   static final generateFrequency = WatchInt(1, min: 0, max: 100);
}

