import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:murmory/core/design_system/tokens.dart';
import 'package:murmory/core/design_system/widgets/liquid_glass.dart';
import 'package:murmory/core/providers/core_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _localOnlyMode = true;
  bool _liveSttEnabled = true;
  String _groqApiKey = '';
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
      _liveSttEnabled = prefs.getBool('live_stt_enabled') ?? true;
      _groqApiKey = prefs.getString('groq_api_key') ?? '';
    });
  }

  Future<void> _setLocalOnlyMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('local_only_mode', value);
    setState(() => _localOnlyMode = value);
  }

  Future<void> _setLiveSttEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('live_stt_enabled', value);
    setState(() => _liveSttEnabled = value);
  }

  Future<void> _showApiKeyDialog() async {
    final controller = TextEditingController(text: _groqApiKey);
    final updated = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Groq / Whisper API Key'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your free Groq API key for instant Whisper Large v3 speech transcription of your recordings.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: controller,
                placeholder: 'gsk_...',
                placeholderStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Clear'),
            onPressed: () => Navigator.pop(ctx, ''),
          ),
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Save'),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          ),
        ],
      ),
    );

    if (updated != null && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('groq_api_key', updated);
      setState(() => _groqApiKey = updated);
    }
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
    unawaited(showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: LiquidGlass(
          blur: 20,
          borderRadius: 20,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoActivityIndicator(radius: 16, color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Packaging SQLite & M4A Audio Files...',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
              ),
              SizedBox(height: 6),
              Text(
                'Generating SHA-256 integrity manifest',
                style: TextStyle(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    ));

    try {
      final exportService = ref.read(vaultExportServiceProvider);
      final result = await exportService.exportFullVault();

      if (mounted) {
        Navigator.pop(context);

        final sizeFormatted = result.totalSizeBytes > 1024 * 1024
            ? '${(result.totalSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB'
            : '${(result.totalSizeBytes / 1024).toStringAsFixed(1)} KB';

        unawaited(showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Export Complete'),
            content: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Exported ${result.memoriesCount} memories ($sizeFormatted) with verified SHA-256 checksums.\n\nArchive location:\n${result.zipFilePath}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('Done'),
                onPressed: () => Navigator.pop(ctx),
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

  Future<void> _wipeLocalVault() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Wipe All Local Data?'),
        content: const Text(
          'This will permanently delete all audio recordings, transcripts, search indexes, and custom tags from this device. This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Wipe Vault'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final db = ref.read(databaseProvider);
        await db.delete(db.transcriptSegments).go();
        await db.delete(db.memories).go();
        await db.delete(db.processingJobs).go();
        await db.delete(db.tags).go();

        final docDir = await getApplicationDocumentsDirectory();
        if (docDir.existsSync()) {
          for (final f in docDir.listSync()) {
            if (f is File && f.path.endsWith('.m4a')) {
              try {
                await f.delete();
              } catch (_) {}
            }
          }
        }

        await _calculateStorageStats();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vault wiped clean.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to clear vault: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Ambient background glow
          Positioned(
            top: 200,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    MurmoryColors.accent.withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vault Storage Card (Liquid Glass)
                        LiquidGlass(
                          blur: 20,
                          borderRadius: 22,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: MurmoryColors.accent.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.waveform_circle_fill,
                                      color: MurmoryColors.accentLight,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Encrypted Local Vault',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '$_memoriesCount memories stored • $_vaultSizeStr on disk',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: CupertinoButton(
                                      color: MurmoryColors.accent,
                                      borderRadius: BorderRadius.circular(14),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      onPressed: _exportData,
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(CupertinoIcons.arrow_down_doc_fill, size: 16, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                            'Export Vault (ZIP)',
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.only(left: 8, bottom: 8),
                          child: Text(
                            'TRANSCRIPTION ENGINE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white60,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),

                        // Transcription Settings (Liquid Glass Group)
                        LiquidGlass(
                          blur: 18,
                          borderRadius: 22,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(CupertinoIcons.mic_fill, size: 20, color: MurmoryColors.accentLight),
                                      SizedBox(width: 12),
                                      Text(
                                        'On-Device Live Speech',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  CupertinoSwitch(
                                    value: _liveSttEnabled,
                                    activeTrackColor: MurmoryColors.accent,
                                    onChanged: _setLiveSttEnabled,
                                  ),
                                ],
                              ),
                              Divider(color: Colors.white.withValues(alpha: 0.08)),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: _showApiKeyDialog,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(CupertinoIcons.lock_fill, size: 20, color: Colors.amberAccent),
                                          SizedBox(width: 12),
                                          Text(
                                            'Groq Whisper Cloud Key',
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            _groqApiKey.isNotEmpty ? 'Active' : 'Configure',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: _groqApiKey.isNotEmpty ? Colors.greenAccent : Colors.white54,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(CupertinoIcons.chevron_right, size: 14, color: Colors.white38),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.only(left: 8, bottom: 8),
                          child: Text(
                            'PRIVACY & SECURITY',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white60,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),

                        // Privacy Settings
                        LiquidGlass(
                          blur: 18,
                          borderRadius: 22,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(CupertinoIcons.lock_shield_fill, size: 20, color: Colors.greenAccent),
                                      SizedBox(width: 12),
                                      Text(
                                        'Strict Local Isolation',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  CupertinoSwitch(
                                    value: _localOnlyMode,
                                    activeTrackColor: MurmoryColors.accent,
                                    onChanged: _setLocalOnlyMode,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.only(left: 8, bottom: 8),
                          child: Text(
                            'DANGER ZONE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.redAccent,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),

                        // Danger Zone Card
                        LiquidGlass(
                          blur: 18,
                          borderRadius: 22,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Clear Vault Storage',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Permanently erase all recordings, indexed transcripts, and SQLite tables from this phone.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 12),
                              CupertinoButton(
                                color: Colors.redAccent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                onPressed: _wipeLocalVault,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(CupertinoIcons.trash_fill, size: 16, color: Colors.redAccent),
                                    SizedBox(width: 8),
                                    Text(
                                      'Wipe All Local Data',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
