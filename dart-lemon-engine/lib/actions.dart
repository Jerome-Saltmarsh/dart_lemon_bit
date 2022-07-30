import 'package:universal_html/html.dart';

void fullScreenEnter() {
  final element = document.documentElement;
  if (element == null){
    return print("fullScreenEnter() error: document.documentElement == null");
  }
  element.requestFullscreen();
}

void refreshPage(){
  final window = document.window;
  if (window == null) return;
  final domain = document.domain;
  if (domain == null) return;
  window.location.href = domain;
}