import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:murmory/core/database/daos/memories_dao.dart';
import 'package:murmory/core/database/daos/transcript_dao.dart';

class ExportResult {
  final String zipFilePath;
  final int totalFiles;
  final int totalSizeBytes;
  final int memoriesCount;
  final Map<String, String> sha256Checksums;

  const ExportResult({
    required this.zipFilePath,
    required this.totalFiles,
    required this.totalSizeBytes,
    required this.memoriesCount,
    required this.sha256Checksums,
  });
}

class VaultExportService {
  final MemoriesDao _memoriesDao;
  final TranscriptDao _transcriptDao;

  VaultExportService({
    required MemoriesDao memoriesDao,
    required TranscriptDao transcriptDao,
  })  : _memoriesDao = memoriesDao,
        _transcriptDao = transcriptDao;

  Future<ExportResult> exportFullVault() async {
    final archive = Archive();
    final checksums = <String, String>{};

    final memories = await _memoriesDao.watchAll(limit: 500).first;
    final exportData = <Map<String, dynamic>>[];
    final markdownBuffer = StringBuffer();

    markdownBuffer.writeln('# Murmory Personal Voice Memory Export');
    markdownBuffer.writeln('Export Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    markdownBuffer.writeln('Total Memories: ${memories.length}\n');
    markdownBuffer.writeln('---\n');

    for (final memory in memories) {
      final segments = await _transcriptDao.getSegmentsForMemory(memory.id);

      final memoryDict = {
        'id': memory.id,
        'title': memory.title,
        'createdAt': memory.createdAt.toIso8601String(),
        'updatedAt': memory.updatedAt.toIso8601String(),
        'durationMs': memory.durationMs,
        'audioFilePath': memory.audioFilePath,
        'isFavorite': memory.isFavorite,
        'segments': segments.map((s) => {
          'id': s.id,
          'startMs': s.startMs,
          'endMs': s.endMs,
          'content': s.content,
          'confidence': s.confidence,
        }).toList(),
      };
      exportData.add(memoryDict);

      markdownBuffer.writeln('## ${memory.title}');
      markdownBuffer.writeln('- **Date:** ${DateFormat('yyyy-MM-dd HH:mm').format(memory.createdAt)}');
      markdownBuffer.writeln('- **Duration:** ${(memory.durationMs / 1000).toStringAsFixed(1)} seconds');
      markdownBuffer.writeln('- **Audio File:** ${p.basename(memory.audioFilePath)}');
      markdownBuffer.writeln('\n### Transcript:');
      for (final s in segments) {
        final startSec = (s.startMs / 1000).toStringAsFixed(1);
        final endSec = (s.endMs / 1000).toStringAsFixed(1);
        markdownBuffer.writeln('[$startSec - $endSec] ${s.content}');
      }
      markdownBuffer.writeln('\n---\n');

      // Include physical audio file if it exists
      if (memory.audioFilePath.isNotEmpty) {
        final audioFile = File(memory.audioFilePath);
        if (await audioFile.exists()) {
          final audioBytes = await audioFile.readAsBytes();
          final audioName = 'audio/${p.basename(memory.audioFilePath)}';
          archive.addFile(ArchiveFile(audioName, audioBytes.length, audioBytes));

          final hash = sha256.convert(audioBytes).toString();
          checksums[audioName] = hash;
        }
      }
    }

    // Add JSON database export
    final jsonStr = const JsonEncoder.withIndent('  ').convert(exportData);
    final jsonBytes = utf8.encode(jsonStr);
    archive.addFile(ArchiveFile('memories_database.json', jsonBytes.length, jsonBytes));
    checksums['memories_database.json'] = sha256.convert(jsonBytes).toString();

    // Add Markdown human-readable export
    final mdBytes = utf8.encode(markdownBuffer.toString());
    archive.addFile(ArchiveFile('memories_summary.md', mdBytes.length, mdBytes));
    checksums['memories_summary.md'] = sha256.convert(mdBytes).toString();

    // Add Checksums Manifest
    final manifestStr = const JsonEncoder.withIndent('  ').convert({
      'exportTimestamp': DateTime.now().toIso8601String(),
      'algorithm': 'SHA-256',
      'files': checksums,
    });
    final manifestBytes = utf8.encode(manifestStr);
    archive.addFile(ArchiveFile('manifest_sha256.json', manifestBytes.length, manifestBytes));

    // Encode ZIP archive
    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);

    final appDir = await getApplicationDocumentsDirectory();
    final exportsDir = Directory(p.join(appDir.path, 'exports'));
    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }

    final timestampStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final exportPath = p.join(exportsDir.path, 'murmory_vault_backup_$timestampStr.zip');
    final exportFile = File(exportPath);
    await exportFile.writeAsBytes(zipData);

    return ExportResult(
      zipFilePath: exportPath,
      totalFiles: archive.length,
      totalSizeBytes: zipData.length,
      memoriesCount: memories.length,
      sha256Checksums: checksums,
    );
  }
}
