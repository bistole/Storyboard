import 'dart:io';
import 'package:path/path.dart' as path;

String getResourcePath(String relativePath) {
  int cnt = 0;
  String resourcePath = relativePath;
  while (File(resourcePath).existsSync() != true) {
    resourcePath = path.join("..", resourcePath);
    if (++cnt > 20) {
      throw new Exception("can not find resource file: $relativePath");
    }
  }
  return resourcePath;
}