import 'package:lemon_watch/watch.dart';

final messageBoxVisible = Watch(false);

void messageBoxToggle(){
  messageBoxVisible.value = !messageBoxVisible.value;
}

void messageBoxShow(){
  messageBoxVisible.value = true;
}

void messageBoxHide(){
  messageBoxVisible.value = false;
}