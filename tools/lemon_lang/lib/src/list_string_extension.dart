extension ListStringExtension on List<String> {

  int? tryGetArgInt(String name){
    final arg = tryGetArgString(name);
    if (arg == null){
      return null;
    }
    return int.tryParse(arg);
  }

  String? tryGetArgString(String name){
    final index = indexOf(name);
    if (index == -1){
      return null;
    }
    if (index >= length){
      return null;
    }
    return this[index + 1];
  }

  int getArgInt(String name){
    final arg = tryGetArgString(name);
    if (arg == null){
      throw Exception('expected int argument --$name');
    }
    final parsedArg = int.tryParse(arg);
    if (parsedArg == null){
      throw Exception('could not be parse argument --$name to an int ($arg)');
    }
    return parsedArg;
  }

  bool? getArgBool(String name){
    final arg = tryGetArgString(name);
    if (arg == null){
      return null;
    }
    return bool.tryParse(arg);
  }
}