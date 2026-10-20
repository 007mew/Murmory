import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class AudioFileManager {
  static const _recordingsDirName = 'recordings';
  static const _tempDirName = 'temp_recordings';

  Future<String> getTemporaryRecordingPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final tempDir = Directory(p.join(appDir.path, _tempDirName));
    if (!await tempDir.exists()) {
      await tempDir.create(recursive: true);
    }
    return p.join(tempDir.path, 'temp_${const Uuid().v4()}.m4a');
  }

  Future<String> commitRecordingToPermanentStorage({
    required String tempPath,
    required String memoryId,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final permDir = Directory(p.join(appDir.path, _recordingsDirName));
    if (!await permDir.exists()) {
      await permDir.create(recursive: true);
    }

    final targetRelativePath = p.join(_recordingsDirName, '$memoryId.m4a');
    final targetFullPath = p.join(appDir.path, targetRelativePath);

    final tempFile = File(tempPath);
    if (!await tempFile.exists()) {
      throw Exception('Temporary recording not found at $tempPath');
    }

    // Atomic move / copy
    await tempFile.rename(targetFullPath);
    return targetRelativePath;
  }

  Future<String> getAbsolutePath(String relativePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    return p.join(appDir.path, relativePath);
  }

  Future<void> deleteAudio(String relativePath) async {
    final fullPath = await getAbsolutePath(relativePath);
    final file = File(fullPath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
