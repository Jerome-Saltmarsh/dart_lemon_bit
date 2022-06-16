import 'package:lemon_watch/watch.dart';

final textBoxVisible = Watch(false);

void messageBoxToggle(){
  textBoxVisible.value = !textBoxVisible.value;
}

void messageBoxShow(){
  textBoxVisible.value = true;
}

void messageBoxHide(){
  textBoxVisible.value = false;
}