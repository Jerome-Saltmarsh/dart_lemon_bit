
import 'package:gamestream_flutter/library.dart';

class EditorState {
   static final windowEnabledScene = Watch(false);
   static final windowEnabledCanvasSize = Watch(false);
   static final windowEnabledGenerate = WatchBool(false);

   static final generateRows = WatchInt(50);
   static final generateColumns = WatchInt(50);
   static final generateHeight = WatchInt(8);
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

class WatchInt extends Watch<int> {
  WatchInt(super.value);

  void increment(){
     value++;
  }

  void decrement(){
     value--;
  }
}