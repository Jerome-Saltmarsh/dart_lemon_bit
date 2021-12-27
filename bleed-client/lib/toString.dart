String enumString(dynamic value){
  String text = value.toString();
  int index = text.indexOf(".");
  if (index == -1) return text;
  return text.substring(index + 1, text.length).replaceAll("_", " ");
}
