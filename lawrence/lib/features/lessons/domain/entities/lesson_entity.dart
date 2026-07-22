class LessonEntity {
  final String id;
  final String moduleId;
  final String courseId;
  final String title;
  final String? description;
  final int orderIndex;
  final int durationSeconds;
  final String hlsStoragePath;
  final String? materialPdfUrl;
  final String status; // 'preview', 'published', 'draft'

  LessonEntity({
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

  bool get isPreview => status == 'preview';
}
