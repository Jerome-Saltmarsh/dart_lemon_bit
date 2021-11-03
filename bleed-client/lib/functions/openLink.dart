import "dart:html" as html;

void openLink(String value, {bool newTab = true}){
  html.window.open(value, 'new tab');
}