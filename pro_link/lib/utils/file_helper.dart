import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class FileHelper {
  const FileHelper._();

  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickImagePath({
    ImageSource source = ImageSource.gallery,
  }) async {
    final file = await _picker.pickImage(source: source);
    return file?.path;
  }

  static Future<String?> pickDocumentPath() async {
    final result = await FilePicker.platform.pickFiles();
    return result?.files.single.path;
  }
}
