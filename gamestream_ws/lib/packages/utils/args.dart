extension Args on List<String> {
  String? getArg(String name){
    final index = indexOf(name);
    if (index == -1){
      return null;
    }
    if (index >= length){
      return null;
    }
    return this[index + 1];
  }

  int? getArgInt(String name){
    final arg = getArg(name);
    if (arg == null){
      return null;
    }
    return int.tryParse(arg);
  }

  bool? getArgBool(String name){
    final arg = getArg(name);
    if (arg == null){
      return null;
    }
    return bool.tryParse(arg);
  }
}