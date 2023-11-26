import 'package:file_picker/file_picker.dart';

Future<PlatformFile?> loadFileFromDisk({
  List<String>? allowedExtensions,
  String? dialogTitle,
}) async {
  final result = await FilePicker.platform.pickFiles(
    withData: true,
    dialogTitle: dialogTitle,
    type: FileType.custom,
    allowedExtensions: allowedExtensions,
    allowMultiple: false,
  );
  if (result == null || result.files.isEmpty)
    return null;

  return result.files.first;
}