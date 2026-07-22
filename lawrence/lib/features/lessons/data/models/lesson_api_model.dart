class LessonApiModel {
  final String id;
  final String moduleId;
  final String courseId;
  final String title;
  final String? description;
  final int orderIndex;
  final int durationSeconds;
  final String hlsStoragePath;
  final String? materialPdfUrl;
  final String status;

  LessonApiModel({
    required this.id,
    required this.moduleId,
    required this.courseId,
    required this.title,
    this.description,
    required this.orderIndex,
    required this.durationSeconds,
    required this.hlsStoragePath,
    this.materialPdfUrl,
    required this.status,
  });

  factory LessonApiModel.fromJson(Map<String, dynamic> json) {
    return LessonApiModel(
      id: json['id'] as String,
      moduleId: json['module_id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      hlsStoragePath: json['hls_storage_path'] as String? ?? '',
      materialPdfUrl: json['material_pdf_url'] as String?,
      status: json['status'] as String? ?? 'draft',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module_id': moduleId,
      'course_id': courseId,
      'title': title,
      'description': description,
      'order_index': orderIndex,
      'duration_seconds': durationSeconds,
      'hls_storage_path': hlsStoragePath,
      'material_pdf_url': materialPdfUrl,
      'status': status,
    };
  }
}
