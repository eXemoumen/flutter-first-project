import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/constants.dart';
import 'database_service.dart';
import 'supabase_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(
    client: ref.watch(supabaseClientProvider),
    databaseService: ref.watch(databaseServiceProvider),
  );
});

class StorageService {
  StorageService({
    required SupabaseClient? client,
    required DatabaseService databaseService,
  })  : _client = client,
        _databaseService = databaseService;

  final SupabaseClient? _client;
  final DatabaseService _databaseService;

  bool get _enabled => _client != null;

  Future<String> uploadAvatar({
    required String userId,
    required String localPath,
  }) {
    return _uploadFile(
      bucket: AppConstants.avatarsBucket,
      localPath: localPath,
      folder: userId,
    );
  }

  Future<String> uploadSchedule(String localPath) {
    return _uploadFile(
      bucket: AppConstants.schedulesBucket,
      localPath: localPath,
      folder: 'schedule',
    );
  }

  Future<String> uploadTrainingFile(String localPath) {
    return _uploadFile(
      bucket: AppConstants.trainingBucket,
      localPath: localPath,
      folder: 'training',
    );
  }

  Future<String> uploadPolicyFile(String localPath) {
    return _uploadFile(
      bucket: AppConstants.policiesBucket,
      localPath: localPath,
      folder: 'policies',
    );
  }

  Future<String> _uploadFile({
    required String bucket,
    required String localPath,
    required String folder,
  }) async {
    if (!_enabled) {
      return 'https://mock-storage.prolink.local/${_databaseService.createId()}';
    }

    final file = File(localPath);
    final bytes = await file.readAsBytes();
    final extension = _fileExtension(localPath);
    final path = '$folder/${DateTime.now().millisecondsSinceEpoch}_${_databaseService.createId()}.$extension';

    await _client!.storage
        .from(bucket)
        .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));

    return _client!.storage.from(bucket).getPublicUrl(path);
  }

  String _fileExtension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot <= 0 || dot == path.length - 1) return 'bin';
    return path.substring(dot + 1).toLowerCase();
  }
}
