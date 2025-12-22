import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../bloc/backup/backup_bloc.dart';
import '../bloc/backup/backup_event.dart';
import '../bloc/backup/backup_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/preferences_helper.dart';
import '../widgets/common_widgets.dart';
import '../bloc/theme/theme_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  int _defaultWarrantyDuration = 12;
  String _lastBackupDate = 'Never';
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }
  
  void _loadPreferences() {
    setState(() {
      _notificationsEnabled = PreferencesHelper.isNotificationEnabled();
      _defaultWarrantyDuration = PreferencesHelper.getDefaultWarrantyDuration();
      final lastBackup = PreferencesHelper.getLastBackupDate();
      if (lastBackup != null) {
        final date = DateTime.tryParse(lastBackup);
        if (date != null) {
          _lastBackupDate = '${date.day}/${date.month}/${date.year}';
        }
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocListener<BackupBloc, BackupState>(
        listener: (context, state) {
          if (state is BackupExportSuccess) {
            // Share the backup file
            Share.shareXFiles(
              [XFile(state.backupFilePath, mimeType: 'application/octet-stream')],
              subject: 'WarrantyVault Backup',
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Backup created successfully!')),
            );
            
            _loadPreferences();
          }
          
          if (state is BackupImportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            
            // Navigate back to home and reload
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          
          if (state is BackupError) {
            final colorScheme = Theme.of(context).colorScheme;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<BackupBloc, BackupState>(
          builder: (context, state) {
            final isProcessing = state is BackupExporting || state is BackupImporting;
            
            if (isProcessing) {
              return LoadingIndicator(
                message: state is BackupExporting
                    ? 'Creating backup...'
                    : 'Importing backup...',
              );
            }
            
            return ListView(
              children: [
                // Backup & Restore Section
                _buildSectionHeader('Backup & Restore'),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.cloud_upload_outlined),
                        title: const Text('Export Backup'),
                        subtitle: Text('Last backup: $_lastBackupDate'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _exportBackup,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.cloud_download_outlined),
                        title: const Text('Import Backup'),
                        subtitle: const Text('Restore from backup file'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _importBackup,
                      ),
                    ],
                  ),
                ),
                
                // Preferences Section
                _buildSectionHeader('Preferences'),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.contrast_outlined),
                        title: const Text('Theme'),
                        subtitle: Text(_themeModeLabel(context)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _changeThemeMode,
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.notifications_outlined),
                        title: const Text('Notifications'),
                        subtitle: const Text('Warranty expiry reminders'),
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                          PreferencesHelper.setNotificationEnabled(value);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.timer_outlined),
                        title: const Text('Default Warranty Duration'),
                        subtitle: Text('$_defaultWarrantyDuration months'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _changeDefaultWarranty,
                      ),
                    ],
                  ),
                ),
                
                // App Information Section
                _buildSectionHeader('About'),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('App Version'),
                        subtitle: Text(AppConstants.appVersion),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: const Text('About WarrantyVault'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _showAboutDialog,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _themeModeLabel(BuildContext context) {
    final mode = context.watch<ThemeCubit>().state;
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _changeThemeMode() {
    final cubit = context.read<ThemeCubit>();
    ThemeMode selected = cubit.state;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Theme'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    groupValue: selected,
                    title: const Text('System'),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => selected = value);
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: selected,
                    title: const Text('Light'),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => selected = value);
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: selected,
                    title: const Text('Dark'),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => selected = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await cubit.setThemeMode(selected);
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _exportBackup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Export Backup'),
          content: const Text(
            'This will create a backup file with all your products, images, and notes. You can save it to your device or share it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<BackupBloc>().add(ExportBackup());
              },
              child: const Text('Export'),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'wvvault', 'json'],
      );
      
      if (result == null) return;

      final selectedPath = result.files.single.path;
      if (selectedPath == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to import: file path unavailable')),
        );
        return;
      }
        
        if (!mounted) return;
        
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Import Backup'),
              content: const Text(
                'This will replace all your current data with the backup data. This action cannot be undone.\n\nAre you sure?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<BackupBloc>().add(ImportBackup(selectedPath));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Import'),
                ),
              ],
            );
          },
        );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: ${e.toString()}')),
      );
    }
  }
  
  void _changeDefaultWarranty() {
    showDialog(
      context: context,
      builder: (context) {
        int selectedDuration = _defaultWarrantyDuration;
        
        return AlertDialog(
          title: const Text('Default Warranty Duration'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$selectedDuration months'),
                  Slider(
                    value: selectedDuration.toDouble(),
                    min: 3,
                    max: 60,
                    divisions: 19,
                    label: '$selectedDuration months',
                    onChanged: (value) {
                      setState(() {
                        selectedDuration = value.toInt();
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _defaultWarrantyDuration = selectedDuration;
                });
                PreferencesHelper.setDefaultWarrantyDuration(selectedDuration);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About WarrantyVault'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WarrantyVault',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text('Version ${AppConstants.appVersion}'),
                SizedBox(height: 16),
                Text(
                  'An offline-first mobile application for managing product warranties, bills, and receipts.',
                  style: TextStyle(height: 1.5),
                ),
                SizedBox(height: 16),
                Text(
                  'Features:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Scan bills with OCR'),
                Text('• Store product images'),
                Text('• Track warranty expiry'),
                Text('• Get expiry reminders'),
                Text('• Backup & restore data'),
                Text('• 100% offline'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
