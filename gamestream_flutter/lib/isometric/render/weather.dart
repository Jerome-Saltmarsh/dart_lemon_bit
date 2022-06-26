import 'package:lemon_watch/watch.dart';


var raining = false;

var rainingWatch = Watch(false, onChanged: (value){
  raining = value;
});

void toggleRaining(){
   rainingWatch.value = !rainingWatch.value;
}