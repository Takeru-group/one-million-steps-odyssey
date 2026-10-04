import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../models/artifact_model.dart';
import '../models/history_master_model.dart';

class MasterDataRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final BaseCacheManager _cacheManager;

  static final Map<String, String> _urlMemoryCache = {};

  MasterDataRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    BaseCacheManager? cacheManager,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _cacheManager = cacheManager ?? DefaultCacheManager();

  Future<String> resolveImageUrl(String path) async {
    if (path.isEmpty || path == 'EXCLUDED') return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    if (_urlMemoryCache.containsKey(path)) {
      return _urlMemoryCache[path]!;
    }

    try {
      final ref = _storage.ref(path);
      final downloadUrl = await ref.getDownloadURL().timeout(const Duration(seconds: 2));
      _urlMemoryCache[path] = downloadUrl;

      _backgroundEnsureDiskCache(downloadUrl);

      return downloadUrl;
    } catch (e) {
      print('⚠️ [Storage URL 取得失敗 / オフライン]: $path');
      return _urlMemoryCache[path] ?? '';
    }
  }

  void _backgroundEnsureDiskCache(String httpUrl) async {
    if (httpUrl.isEmpty || !httpUrl.startsWith('http')) return;
    try {
      final FileInfo? fileInfo = await _cacheManager.getFileFromCache(httpUrl);
      if (fileInfo == null || !(await fileInfo.file.exists())) {
        await _cacheManager.getSingleFile(httpUrl);
      }
    } catch (_) {}
  }

  Future<HistoryMasterModel?> getHistoryMaster(String historyId) async {
    DocumentSnapshot<Map<String, dynamic>> docSnap;
    try {
      docSnap = await _firestore.collection('history_master').doc(historyId).get().timeout(const Duration(seconds: 2));
    } catch (_) {
      docSnap = await _firestore.collection('history_master').doc(historyId).get(const GetOptions(source: Source.cache));
    }

    if (!docSnap.exists || docSnap.data() == null) return null;

    final data = Map<String, dynamic>.from(docSnap.data()!);

    data['backgroundImagePath'] =
        await resolveImageUrl(data['backgroundImagePath'] as String? ?? '');
    data['thumbnailPath'] =
        await resolveImageUrl(data['thumbnailPath'] as String? ?? '');

    return HistoryMasterModel.fromDocument(historyId, data);
  }

  Future<ArtifactModel?> getArtifact(String artifactId) async {
    DocumentSnapshot<Map<String, dynamic>> docSnap;
    try {
      docSnap = await _firestore.collection('artifacts').doc(artifactId).get().timeout(const Duration(seconds: 2));
    } catch (_) {
      docSnap = await _firestore.collection('artifacts').doc(artifactId).get(const GetOptions(source: Source.cache));
    }

    if (!docSnap.exists || docSnap.data() == null) return null;

    final data = Map<String, dynamic>.from(docSnap.data()!);

    data['backgroundImagePath'] =
        await resolveImageUrl(data['backgroundImagePath'] as String? ?? '');
    data['thumbnailPath'] =
        await resolveImageUrl(data['thumbnailPath'] as String? ?? '');

    return ArtifactModel.fromDocument(artifactId, data);
  }
}