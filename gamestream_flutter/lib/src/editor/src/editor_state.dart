
import 'package:gamestream_flutter/library.dart';

class EditorState {
   static final windowEnabledScene = Watch(false);
   static final windowEnabledCanvasSize = Watch(false);
   static final windowEnabledGenerate = WatchBool(false);
}

class WatchBool extends Watch<bool> {

   WatchBool(super.value);

   void toggle(){
      value = !value;
   }

   void setFalse(){
      value = false;
   }

   void setTrue(){
      value = true;
   }
}