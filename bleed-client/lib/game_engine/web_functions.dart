import 'package:universal_html/html.dart';

void disableRightClick() {
  document.onContextMenu.listen((event) => event.preventDefault());
}

void fullScreenEnter() {
  document.documentElement.requestFullscreen();
}

void toggleFullScreen(){
  if(fullScreenActive){
    fullScreenExit();
  }else{
    fullScreenEnter();
  }
}

void fullScreenExit() {
  document.exitFullscreen();
}

bool get fullScreenActive => document.fullscreenElement != null;
