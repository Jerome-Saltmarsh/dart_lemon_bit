import 'package:file_picker/file_picker.dart';

Future<PlatformFile?> loadFileFromDisk() async {
  final result = await FilePicker.platform.pickFiles(
    withData: true,
    dialogTitle: 'Load Image',
    type: FileType.custom,
    allowedExtensions: ['png'],
    allowMultiple: false,
  );
  if (result == null || result.files.isEmpty)
    return null;

  return result.files.first;
}