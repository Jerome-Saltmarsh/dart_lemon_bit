import 'package:universal_html/html.dart';

void disableRightClick(){
  document.onContextMenu.listen((event) => event.preventDefault());
}

void requestFullScreen(){
  document.documentElement.requestFullscreen();
}