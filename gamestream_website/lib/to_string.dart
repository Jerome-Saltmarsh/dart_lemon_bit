String enumString(dynamic value){
  final text = value.toString();
  final index = text.indexOf(".");
  if (index == -1) return text;
  return text.substring(index + 1, text.length).replaceAll("_", " ");
}

T stringEnum<T>(String text, List<T> values){
  final textFixed = text.trim().toLowerCase().replaceAll(" ", "_");
  for(T status in values){
    if (status.toString().toLowerCase().contains(textFixed)){
      return status;
    }
  }
  throw Exception("Could not parse $text");
}
