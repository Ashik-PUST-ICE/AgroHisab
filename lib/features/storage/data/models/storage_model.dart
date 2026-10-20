class StorageInfoModel {
  final String provider;
  final bool enabled;
  final String? root;
  final String? publicUrl;
  final List<String> configuredDrivers;

  StorageInfoModel({
    required this.provider,
    required this.enabled,
    this.root,
    this.publicUrl,
    required this.configuredDrivers,
  });

  factory StorageInfoModel.fromJson(Map<String, dynamic> json) {
    return StorageInfoModel(
      provider: json['provider'] ?? 'local',
      enabled: json['enabled'] ?? true,
      root: json['root'],
      publicUrl: json['public_url'],
      configuredDrivers: (json['configured_drivers'] as List?)?.map((e) => e.toString()).toList() ?? ['local'],
    );
  }
}

class UploadedFileModel {
  final String path;
  final String url;
  final String filename;
  final String mime;
  final int size;
  final String provider;

  UploadedFileModel({
    required this.path,
    required this.url,
    required this.filename,
    required this.mime,
    required this.size,
    required this.provider,
  });

  factory UploadedFileModel.fromJson(Map<String, dynamic> json) {
    return UploadedFileModel(
      path: json['path'] ?? '',
      url: json['url'] ?? '',
      filename: json['filename'] ?? '',
      mime: json['mime'] ?? '',
      size: (json['size'] as num?)?.toInt() ?? 0,
      provider: json['provider'] ?? 'local',
    );
  }
}

class StorageTestResultModel {
  final String status;
  final String provider;
  final double latencyMs;
  final String message;

  StorageTestResultModel({
    required this.status,
    required this.provider,
    required this.latencyMs,
    required this.message,
  });

  factory StorageTestResultModel.fromJson(Map<String, dynamic> json) {
    return StorageTestResultModel(
      status: json['status'] ?? 'unknown',
      provider: json['provider'] ?? 'local',
      latencyMs: (json['latency_ms'] as num?)?.toDouble() ?? 0.0,
      message: json['message'] ?? '',
    );
  }
}