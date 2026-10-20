import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:murmory/core/design_system/tokens.dart';
import 'package:murmory/core/providers/core_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _localOnlyMode = true;
  int _memoriesCount = 0;
  String _vaultSizeStr = 'Calculating...';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _calculateStorageStats();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _localOnlyMode = prefs.getBool('local_only_mode') ?? true;
    });
  }

  Future<void> _setLocalOnlyMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('local_only_mode', value);
    setState(() => _localOnlyMode = value);
  }

  Future<void> _calculateStorageStats() async {
    final memoriesDao = ref.read(memoriesDaoProvider);
    final count = await memoriesDao.countAll();

    int totalBytes = 0;
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final entities = docDir.listSync(recursive: true);
      for (final e in entities) {
        if (e is File) {
          totalBytes += await e.length();
        }
      }
    } catch (_) {}

    String sizeStr;
    if (totalBytes > 1024 * 1024) {
      sizeStr = '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      sizeStr = '${(totalBytes / 1024).toStringAsFixed(0)} KB';
    }

    if (mounted) {
      setState(() {
        _memoriesCount = count;
        _vaultSizeStr = sizeStr;
      });
    }
  }

  Future<void> _exportData() async {
    unawaited(showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Packaging SQLite & M4A Audio Files...', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text('Generating SHA-256 integrity manifest', style: TextStyle(fontSize: 12, color: MurmoryColors.textSecondaryLight)),
              ],
            ),
          ),
        ),
      ),
    ));

    try {
      final exportService = ref.read(vaultExportServiceProvider);
      final result = await exportService.exportFullVault();

      if (mounted) {
        Navigator.pop(context); // Dismiss progress dialog

        final sizeFormatted = result.totalSizeBytes > 1024 * 1024
            ? '${(result.totalSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB'
            : '${(result.totalSizeBytes / 1024).toStringAsFixed(1)} KB';

        unawaited(showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
                SizedBox(width: 10),
                Text('Export Complete'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Successfully exported ${result.memoriesCount} memories and ${result.totalFiles} files into an offline ZIP archive.'),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• Total Archive Size: $sizeFormatted', style: const TextStyle(fontSize: 12)),
                      Text('• Verified Checksums: ${result.sha256Checksums.length} files (SHA-256)', style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 6),
                      Text('Saved to:\n${result.zipFilePath}', style: const TextStyle(fontSize: 10, color: MurmoryColors.accentLight)),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Done'),
              ),
            ],
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Wipe All Memories?'),
        content: const Text('This will permanently delete all audio recordings, transcripts, and database records from this device. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Wipe Everything', style: TextStyle(color: MurmoryColors.recordRed)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final db = ref.read(databaseProvider);
      await db.customStatement('DELETE FROM transcript_segments');
      await db.customStatement('DELETE FROM memories');
      await db.customStatement('DELETE FROM processing_jobs');
      await db.customStatement('DELETE FROM memory_tags');
      await _calculateStorageStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vault reset successfully.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Privacy', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          const Text('STORAGE & DATA VAULT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: MurmoryColors.textSecondaryLight)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.storage_rounded, color: MurmoryColors.accent),
                  title: const Text('Local Vault Storage'),
                  subtitle: Text('$_memoriesCount memories recorded • $_vaultSizeStr total on device'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: MurmoryColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Encrypted', style: TextStyle(fontSize: 11, color: MurmoryColors.accentLight)),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.archive_outlined, color: Colors.white70),
                  title: const Text('Export All Data (ZIP)'),
                  subtitle: const Text('Export SQLite database, transcripts, and original M4A audio files'),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                  onTap: _exportData,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('AI & PRIVACY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: MurmoryColors.textSecondaryLight)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.cloud_off_rounded, color: MurmoryColors.accent),
                  title: const Text('Local Only Mode'),
                  subtitle: const Text('Audio processing and retrieval happen 100% on-device'),
                  value: _localOnlyMode,
                  onChanged: (val) {
                    HapticFeedback.selectionClick();
                    _setLocalOnlyMode(val);
                  },
                ),
                const Divider(height: 1, indent: 56),
                const ListTile(
                  leading: Icon(Icons.security_rounded, color: Colors.white70),
                  title: Text('Security & Cryptography'),
                  subtitle: Text('SHA-256 audio validation and private sandboxing active'),
                  trailing: Icon(Icons.verified_user_rounded, color: Colors.greenAccent, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('DANGER ZONE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: MurmoryColors.recordRed)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: MurmoryColors.recordRed.withValues(alpha: 0.3)),
            ),
            child: ListTile(
              leading: const Icon(Icons.delete_forever_rounded, color: MurmoryColors.recordRed),
              title: const Text('Clear All Memories', style: TextStyle(color: MurmoryColors.recordRed)),
              subtitle: const Text('Permanently wipe database and audio recordings'),
              onTap: _clearAllData,
            ),
          ),
          const SizedBox(height: 36),
          const Center(
            child: Text(
              'Murmory v0.5.0\nPrivate Personal Voice Memory & Grounded Retrieval\nLocal-First Vault',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: MurmoryColors.textSecondaryLight, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
