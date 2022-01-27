import 'package:universal_html/html.dart';

void requestPointerLock() {
  var canvas = document.getElementById('canvas');
  if (canvas != null) {
    canvas.requestPointerLock();
  }
}

void setDocumentTitle(String value){
  document.title = value;
}

void setFavicon(String filename){
  final link = document.querySelector("link[rel*='icon']");
  if (link == null) return;
  print("setFavicon($filename)");
  link.setAttribute("type", 'image/x-icon');
  link.setAttribute("rel", 'shortcut icon');
  link.setAttribute("href", filename);
  document.getElementsByTagName('head')[0].append(link);
}