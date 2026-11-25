import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();
  final _prefs = SharedPreferencesAsync();
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    unawaited(_loadAvatar());
  }

  Future<void> _loadAvatar() async {
    final path = await _prefs.getString('avatarPath');
    if (path == null) return;
    final exists = await File(path).exists();
    if (!exists || !mounted) return;
    setState(() => _avatarPath = path);
  }

  Future<void> _chooseFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    await _useFile(picked);
  }

  Future<void> _takePhoto() async {
    // Ask at the moment of the tap, never in initState.
    final status = await Permission.camera.request();
    if (!mounted) return;
    switch (status) {
      case PermissionStatus.granted ||
          PermissionStatus.limited ||
          PermissionStatus.provisional:
        final picked = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          imageQuality: 85,
        );
        await _useFile(picked);
      case PermissionStatus.denied:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The camera is needed to take a photo. You can still choose one from the gallery.',
            ),
          ),
        );
      case PermissionStatus.permanentlyDenied || PermissionStatus.restricted:
        await _showSettingsDialog();
    }
  }

  Future<void> _useFile(XFile? picked) async {
    if (picked == null) return; // Cancel
    final dir = await getApplicationDocumentsDirectory();
    final saved = await File(picked.path)
        .copy('${dir.path}${Platform.pathSeparator}avatar.jpg');
    await _prefs.setString('avatarPath', saved.path);
    await FileImage(saved).evict(); // same path, so drop the old picture
    if (!mounted) return;
    setState(() => _avatarPath = saved.path);
  }

  Future<void> _showSettingsDialog() async {
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Camera is blocked'),
        content: const Text(
          'Camera access was refused for good. You can turn it on in the app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (open == true) await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final path = _avatarPath;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundImage: path == null ? null : FileImage(File(path)),
              child: path == null
                  ? const Text('Me', style: TextStyle(fontSize: 32))
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose photo'),
              onPressed: _chooseFromGallery,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.photo_camera),
              label: const Text('Take photo'),
              onPressed: _takePhoto,
            ),
          ],
        ),
      ),
    );
  }
}
