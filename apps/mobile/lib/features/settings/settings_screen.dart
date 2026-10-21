import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  bool _liveSttEnabled = true;
  String _groqApiKey = '';
  String _googleApiKey = '';
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
      _googleApiKey = prefs.getString('google_api_key') ?? '';
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

  Future<void> _showGoogleApiKeyDialog() async {
    final controller = TextEditingController(text: _googleApiKey);
    final updated = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Google Speech-to-Text API Key'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your Google Cloud or Gemini API key (AIza...) for high-accuracy speech transcription in English, Hindi & Hinglish with word timestamps.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: controller,
                placeholder: 'AIzaSy...',
                style: const TextStyle(fontSize: 13),
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
      await prefs.setString('google_api_key', updated);
      setState(() => _googleApiKey = updated);
    }
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
                style: const TextStyle(fontSize: 13),
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
    try {
      final memoriesDao = ref.read(memoriesDaoProvider);
      final count = await memoriesDao.countAll();

      final docDir = await getApplicationDocumentsDirectory();
      int totalBytes = 0;
      if (docDir.existsSync()) {
        for (final file in docDir.listSync(recursive: true)) {
          if (file is File) {
            totalBytes += await file.length();
          }
        }
      }

      final mb = totalBytes / (1024 * 1024);
      final formatted = mb < 1 ? '${(totalBytes / 1024).round()} KB' : '${mb.toStringAsFixed(1)} MB';

      if (mounted) {
        setState(() {
          _memoriesCount = count;
          _vaultSizeStr = formatted;
        });
      }
    } catch (_) {}
  }

  Future<void> _exportData() async {
    unawaited(showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CupertinoActivityIndicator(radius: 16),
      ),
    ));

    try {
      final exportService = ref.read(vaultExportServiceProvider);
      final result = await exportService.exportFullVault();

      if (mounted) {
        Navigator.pop(context); // pop loading spinner
        final sizeFormatted = (result.totalSizeBytes / (1024 * 1024)).toStringAsFixed(2) + ' MB';
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
      backgroundColor: MurmoryColors.background,
      body: SafeArea(
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
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: MurmoryColors.textPrimary,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vault Storage Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: MurmoryColors.cardBorder),
                        boxShadow: MurmoryColors.softShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: MurmoryColors.pastelBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  CupertinoIcons.waveform_circle_fill,
                                  color: MurmoryColors.primaryBlue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Encrypted Local Vault',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: MurmoryColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$_memoriesCount notes stored • $_vaultSizeStr on disk',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: MurmoryColors.textSecondary,
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
                                  color: MurmoryColors.primaryBlue,
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
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'TRANSCRIPTION ENGINE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: MurmoryColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: MurmoryColors.cardBorder),
                        boxShadow: MurmoryColors.softShadow,
                      ),
                      child: Column(
                        children: [
                          _buildSwitchTile(
                            icon: CupertinoIcons.mic,
                            title: 'On-Device Live Speech',
                            subtitle: 'Dictate in real-time as you record',
                            value: _liveSttEnabled,
                            onChanged: _setLiveSttEnabled,
                          ),
                          const Divider(color: MurmoryColors.cardBorder, height: 1, indent: 54),
                          _buildActionTile(
                            icon: CupertinoIcons.sparkles,
                            title: 'Google Speech API Key',
                            subtitle: _googleApiKey.isNotEmpty ? 'Key Configured (Active)' : 'Gemini / Cloud Speech',
                            onTap: _showGoogleApiKeyDialog,
                          ),
                          const Divider(color: MurmoryColors.cardBorder, height: 1, indent: 54),
                          _buildActionTile(
                            icon: CupertinoIcons.lock,
                            title: 'Groq Whisper Cloud Key',
                            subtitle: _groqApiKey.isNotEmpty ? 'Key Configured' : 'Optional cloud transcription',
                            onTap: _showApiKeyDialog,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'PRIVACY & SECURITY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: MurmoryColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: MurmoryColors.cardBorder),
                        boxShadow: MurmoryColors.softShadow,
                      ),
                      child: _buildSwitchTile(
                        icon: CupertinoIcons.shield_lefthalf_fill,
                        title: 'Strict Local Isolation',
                        subtitle: 'Zero cloud telemetry or data leakage',
                        value: _localOnlyMode,
                        onChanged: _setLocalOnlyMode,
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'DANGER ZONE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: MurmoryColors.iconCoral,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: MurmoryColors.cardBorder),
                        boxShadow: MurmoryColors.softShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Clear Vault Storage',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: MurmoryColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Permanently erase all recordings, indexed transcripts, and SQLite tables from this phone.',
                            style: TextStyle(
                              fontSize: 13,
                              color: MurmoryColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          CupertinoButton(
                            color: MurmoryColors.pastelCoral,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            borderRadius: BorderRadius.circular(12),
                            onPressed: _wipeLocalVault,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.trash, color: MurmoryColors.iconCoral, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Wipe All Local Data',
                                  style: TextStyle(
                                    color: MurmoryColors.iconCoral,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: MurmoryColors.primaryBlue, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: MurmoryColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: MurmoryColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: MurmoryColors.primaryBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: MurmoryColors.primaryBlue, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: MurmoryColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: MurmoryColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_forward, color: MurmoryColors.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
