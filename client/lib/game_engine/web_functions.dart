import 'dart:html';

void disableRightClick(){
  document.onContextMenu.listen((event) => event.preventDefault());
}