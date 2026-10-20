class DocumentModel {
  final int id;
  final String title;
  final String? documentType;
  final String? fileUrl;
  final String? fileName;
  final String? notes;
  final String? createdAt;

  DocumentModel({
    required this.id,
    required this.title,
    this.documentType,
    this.fileUrl,
    this.fileName,
    this.notes,
    this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      documentType: json['document_type'],
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      notes: json['notes'],
      createdAt: json['created_at'],
    );
  }
}