
import 'package:gamestream_flutter/library.dart';

class EditorState {
   static final windowEnabledScene = Watch(false);
   static final windowEnabledCanvasSize = Watch(false);
   static final windowEnabledGenerate = WatchBool(false);

   static final generateRows = WatchInt(50, min: 5, max: 200);
   static final generateColumns = WatchInt(50, min: 5, max: 200);
   static final generateHeight = WatchInt(8, min: 5, max: 20);
}

// class WatchBool extends Watch<bool> {
//
//    WatchBool(super.value);
//
//    void toggle(){
//       value = !value;
//    }
//
//    void setFalse(){
//       value = false;
//    }
//
//    void setTrue(){
//       value = true;
//    }
// }

// class WatchInt extends Watch<int> {
//
//   WatchInt(super.value, {int? min, int? max}) :super(clamp: (int value){
//      if (min != null && value < min) {
//         return min;
//      }
//      if (max != null && value > max){
//        return max;
//      }
//      return value;
//   });
//
//   void increment(){
//      value++;
//   }
//
//   void decrement(){
//      value--;
//   }
//
//   void toggleSign(){
//     value = -value;
//   }
// }
