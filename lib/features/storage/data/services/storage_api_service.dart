import 'dart:io';
import '../../../../core/network/api_client.dart';
import '../models/storage_model.dart';

class StorageApiService {
  final ApiClient _client = ApiClient();

  Future<StorageInfoModel?> getStorageInfo() async {
    final res = await _client.get('/storage/info');
    if (res.data != null && res.data is Map<String, dynamic>) {
      return StorageInfoModel.fromJson(res.data);
    }
    return null;
  }

  Future<StorageTestResultModel?> testStorageConnection() async {
    final res = await _client.post('/settings/storage/test');
    if (res.data != null && res.data is Map<String, dynamic>) {
      return StorageTestResultModel.fromJson(res.data);
    }
    return null;
  }

  Future<UploadedFileModel?> uploadFile(File file, {String directory = 'uploads/files'}) async {
    final res = await _client.uploadMultipart(
      '/storage/upload',
      file: file,
      fields: {'directory': directory},
    );
    if (res.data != null && res.data is Map<String, dynamic>) {
      return UploadedFileModel.fromJson(res.data);
    }
    return null;
  }

  Future<bool> deleteFile(String filePath) async {
    final res = await _client.post('/storage/delete', body: {'file_path': filePath});
    return res.success;
  }
}