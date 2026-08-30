import 'package:flutter/foundation.dart';

@immutable
class KeyTakeaway {
  final String timestamp;
  final int seconds;
  final String topic;
  final String description;

  const KeyTakeaway({
    required this.timestamp,
    required this.seconds,
    required this.topic,
    required this.description,
  });

  factory KeyTakeaway.fromJson(Map<String, dynamic> json) {
    return KeyTakeaway(
      timestamp: json['timestamp'] as String? ?? '00:00',
      seconds: json['seconds'] as int? ?? 0,
      topic: json['topic'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'seconds': seconds,
    'topic': topic,
    'description': description,
  };
}

@immutable
class GlossaryTerm {
  final String term;
  final String definition;

  const GlossaryTerm({required this.term, required this.definition});

  factory GlossaryTerm.fromJson(Map<String, dynamic> json) {
    return GlossaryTerm(
      term: json['term'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'term': term, 'definition': definition};
}

@immutable
class AISummary {
  final String title;
  final String executiveSummary;
  final List<KeyTakeaway> keyTakeaways;
  final List<String> stepByStepExecution;
  final List<GlossaryTerm> technicalGlossary;

  const AISummary({
    required this.title,
    required this.executiveSummary,
    required this.keyTakeaways,
    required this.stepByStepExecution,
    required this.technicalGlossary,
  });

  factory AISummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AISummary(
        title: '',
        executiveSummary: '',
        keyTakeaways: [],
        stepByStepExecution: [],
        technicalGlossary: [],
      );
    }
    return AISummary(
      title: json['title'] as String? ?? '',
      executiveSummary: json['executive_summary'] as String? ?? '',
      keyTakeaways:
          (json['key_takeaways'] as List?)
              ?.map((e) => KeyTakeaway.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      stepByStepExecution:
          (json['step_by_step_execution'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      technicalGlossary:
          (json['technical_glossary'] as List?)
              ?.map((e) => GlossaryTerm.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'executive_summary': executiveSummary,
    'key_takeaways': keyTakeaways.map((e) => e.toJson()).toList(),
    'step_by_step_execution': stepByStepExecution,
    'technical_glossary': technicalGlossary.map((e) => e.toJson()).toList(),
  };
}

@immutable
class LessonBlock {
  final String id;
  final String lessonId;
  final String courseId;
  final String blockType;
  final Map<String, dynamic> content;
  final int orderIndex;
  final String status;

  const LessonBlock({
    required this.id,
    required this.lessonId,
    required this.courseId,
    required this.blockType,
    required this.content,
    this.orderIndex = 0,
    this.status = 'draft',
  });

  factory LessonBlock.fromJson(Map<String, dynamic> json) => LessonBlock(
    id: json['id'] as String,
    lessonId: json['lesson_id'] as String,
    courseId: json['course_id'] as String,
    blockType: json['block_type'] as String,
    content: Map<String, dynamic>.from(json['content'] as Map? ?? const {}),
    orderIndex: json['order_index'] as int? ?? 0,
    status: json['status'] as String? ?? 'draft',
  );
}

@immutable
class Lesson {
  final String id;
  final String moduleId;
  final String courseId;
  final String title;
  final String description;
  final String status;
  final int orderIndex;
  final int durationSeconds;
  final int? estimatedDurationMinutes;
  final bool isRequired;
  final String? hlsStoragePath;
  final String videoSourceType;
  final String? videoJobStatus;
  final AISummary aiSummary;
  final List<LessonBlock> blocks;

  const Lesson({
    required this.id,
    required this.moduleId,
    required this.courseId,
    required this.title,
    this.description = '',
    required this.status,
    this.orderIndex = 0,
    required this.durationSeconds,
    this.estimatedDurationMinutes,
    this.isRequired = true,
    this.hlsStoragePath,
    this.videoSourceType = 'upload',
    this.videoJobStatus,
    required this.aiSummary,
    this.blocks = const [],
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      moduleId: json['module_id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      orderIndex: json['order_index'] as int? ?? 0,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int?,
      isRequired: json['is_required'] as bool? ?? true,
      hlsStoragePath: json['hls_storage_path'] as String?,
      videoSourceType: json['video_source_type'] as String? ?? 'upload',
      videoJobStatus: json['video_job_status'] as String?,
      aiSummary: AISummary.fromJson(
        json['ai_summary'] as Map<String, dynamic>?,
      ),
      blocks:
          ((json['blocks'] ?? json['lesson_blocks']) as List? ?? const [])
              .map((item) => LessonBlock.fromJson(item as Map<String, dynamic>))
              .toList()
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'module_id': moduleId,
    'course_id': courseId,
    'title': title,
    'description': description,
    'status': status,
    'order_index': orderIndex,
    'duration_seconds': durationSeconds,
    'estimated_duration_minutes': estimatedDurationMinutes,
    'is_required': isRequired,
    'hls_storage_path': hlsStoragePath,
    'video_source_type': videoSourceType,
    'video_job_status': videoJobStatus,
    'ai_summary': aiSummary.toJson(),
  };
}

@immutable
class Module {
  final String id;
  final String courseId;
  final String title;
  final int orderIndex;
  final String description;
  final String status;
  final bool isSystem;
  final List<Lesson> lessons;

  const Module({
    required this.id,
    required this.courseId,
    required this.title,
    required this.orderIndex,
    this.description = '',
    this.status = 'draft',
    this.isSystem = false,
    required this.lessons,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    final lessonsJson = json['lessons'] as List? ?? [];
    return Module(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      orderIndex: json['order_index'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      isSystem: json['is_system'] as bool? ?? false,
      lessons:
          lessonsJson
              .map((l) => Lesson.fromJson(l as Map<String, dynamic>))
              .toList()
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'course_id': courseId,
    'title': title,
    'order_index': orderIndex,
    'description': description,
    'status': status,
    'is_system': isSystem,
    'lessons': lessons.map((e) => e.toJson()).toList(),
  };
}

/// Referência tipada a um curso que precisa ser concluído anteriormente.
@immutable
class CoursePrerequisite {
  final String id;
  final String title;
  final String slug;
  final String summary;
  final String category;
  final String status;
  final String? thumbnailUrl;
  final String? coverImagePath;

  const CoursePrerequisite({
    required this.id,
    required this.title,
    required this.slug,
    this.summary = '',
    this.category = 'costura',
    this.status = 'published',
    this.thumbnailUrl,
    this.coverImagePath,
  });

  factory CoursePrerequisite.fromJson(Map<String, dynamic> json) =>
      CoursePrerequisite(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        category: json['category'] as String? ?? 'costura',
        status: json['status'] as String? ?? 'published',
        thumbnailUrl: json['thumbnail_url'] as String?,
        coverImagePath: json['cover_image_path'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
    'summary': summary,
    'category': category,
    'status': status,
    'thumbnail_url': thumbnailUrl,
    'cover_image_path': coverImagePath,
  };
}

@immutable
class Course {
  final String id;
  final String instructorId;
  final String title;
  final String slug;
  final String category;
  final String level;
  final String summary;
  final String description;
  final List<String> requirements;
  final List<CoursePrerequisite> prerequisiteCourses;
  final String courseType;
  final String subtitle;
  final String language;
  final int? estimatedDurationMinutes;
  final List<String> learningObjectives;
  final List<String> targetAudience;
  final List<String> requiredMaterials;
  final List<String> competencies;
  final List<String> expectedOutcomes;
  final String status;
  final double monthlyPrice;
  final double? promotionalMonthlyPrice;
  final DateTime? promotionStartsAt;
  final DateTime? promotionEndsAt;
  final bool certificateEnabled;
  final bool reviewsEnabled;
  final bool commentsEnabled;
  final String visibility;
  final String availability;
  final DateTime? scheduledPublishAt;
  final bool isFeatured;
  final String? coverImagePath;
  final String? coverAltText;
  final double coverFocalX;
  final double coverFocalY;
  final String? trailerHlsPath;
  final String trailerSourceType;
  final String? trailerExternalVideoId;
  final String trailerStatus;
  final int authoringRevision;
  final List<Module> modules;

  const Course({
    required this.id,
    required this.instructorId,
    required this.title,
    required this.slug,
    required this.category,
    required this.level,
    required this.summary,
    this.description = '',
    this.requirements = const [],
    this.prerequisiteCourses = const [],
    this.courseType = 'complete',
    this.subtitle = '',
    this.language = 'pt-BR',
    this.estimatedDurationMinutes,
    this.learningObjectives = const [],
    this.targetAudience = const [],
    this.requiredMaterials = const [],
    this.competencies = const [],
    this.expectedOutcomes = const [],
    required this.status,
    this.monthlyPrice = 0,
    this.promotionalMonthlyPrice,
    this.promotionStartsAt,
    this.promotionEndsAt,
    this.certificateEnabled = true,
    this.reviewsEnabled = true,
    this.commentsEnabled = true,
    this.visibility = 'public',
    this.availability = 'immediate',
    this.scheduledPublishAt,
    this.isFeatured = false,
    this.coverImagePath,
    this.coverAltText,
    this.coverFocalX = 0.5,
    this.coverFocalY = 0.5,
    this.trailerHlsPath,
    this.trailerSourceType = 'upload',
    this.trailerExternalVideoId,
    this.trailerStatus = 'empty',
    this.authoringRevision = 0,
    required this.modules,
  });

  bool get isFree => monthlyPrice <= 0;

  int get lessonCount =>
      modules.fold(0, (total, module) => total + module.lessons.length);

  factory Course.fromJson(Map<String, dynamic> json) {
    final modulesJson = json['modules'] as List? ?? [];
    final rawMonthlyPrice = json['monthly_price'];
    final monthlyPrice = rawMonthlyPrice is num
        ? rawMonthlyPrice.toDouble()
        : double.tryParse(rawMonthlyPrice?.toString() ?? '') ?? 0;
    final rawPromotionalPrice = json['promotional_monthly_price'];
    return Course(
      id: json['id'] as String,
      instructorId: json['instructor_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      category: json['category'] as String? ?? 'costura',
      level: json['level'] as String? ?? 'iniciante',
      summary: json['summary'] as String? ?? '',
      description: json['description'] as String? ?? '',
      requirements:
          (json['requirements'] as List?)
              ?.map((requirement) => requirement.toString())
              .toList() ??
          const [],
      prerequisiteCourses:
          (json['prerequisite_courses'] as List?)
              ?.map(
                (item) => CoursePrerequisite.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList() ??
          const [],
      courseType: json['course_type'] as String? ?? 'complete',
      subtitle: json['subtitle'] as String? ?? '',
      language: json['language'] as String? ?? 'pt-BR',
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int?,
      learningObjectives: _stringList(json['learning_objectives']),
      targetAudience: _stringList(json['target_audience']),
      requiredMaterials: _stringList(json['required_materials']),
      competencies: _stringList(json['competencies']),
      expectedOutcomes: _stringList(json['expected_outcomes']),
      status: json['status'] as String? ?? 'draft',
      monthlyPrice: monthlyPrice,
      promotionalMonthlyPrice: rawPromotionalPrice is num
          ? rawPromotionalPrice.toDouble()
          : double.tryParse(rawPromotionalPrice?.toString() ?? ''),
      promotionStartsAt: _dateTime(json['promotion_starts_at']),
      promotionEndsAt: _dateTime(json['promotion_ends_at']),
      certificateEnabled: json['certificate_enabled'] as bool? ?? true,
      reviewsEnabled: json['reviews_enabled'] as bool? ?? true,
      commentsEnabled: json['comments_enabled'] as bool? ?? true,
      visibility: json['visibility'] as String? ?? 'public',
      availability: json['availability'] as String? ?? 'immediate',
      scheduledPublishAt: _dateTime(json['scheduled_publish_at']),
      isFeatured: json['is_featured'] as bool? ?? false,
      coverImagePath: json['cover_image_path'] as String?,
      coverAltText: json['cover_alt_text'] as String?,
      coverFocalX: (json['cover_focal_x'] as num?)?.toDouble() ?? 0.5,
      coverFocalY: (json['cover_focal_y'] as num?)?.toDouble() ?? 0.5,
      trailerHlsPath: json['trailer_hls_path'] as String?,
      trailerSourceType: json['trailer_source_type'] as String? ?? 'upload',
      trailerExternalVideoId: json['trailer_external_video_id'] as String?,
      trailerStatus: json['trailer_status'] as String? ?? 'empty',
      authoringRevision: json['authoring_revision'] as int? ?? 0,
      modules:
          modulesJson
              .map((m) => Module.fromJson(m as Map<String, dynamic>))
              .toList()
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'instructor_id': instructorId,
    'title': title,
    'slug': slug,
    'category': category,
    'level': level,
    'summary': summary,
    'description': description,
    'requirements': requirements,
    'prerequisite_courses': prerequisiteCourses
        .map((course) => course.toJson())
        .toList(),
    'course_type': courseType,
    'subtitle': subtitle,
    'language': language,
    'estimated_duration_minutes': estimatedDurationMinutes,
    'learning_objectives': learningObjectives,
    'target_audience': targetAudience,
    'required_materials': requiredMaterials,
    'competencies': competencies,
    'expected_outcomes': expectedOutcomes,
    'status': status,
    'monthly_price': monthlyPrice,
    'promotional_monthly_price': promotionalMonthlyPrice,
    'promotion_starts_at': promotionStartsAt?.toUtc().toIso8601String(),
    'promotion_ends_at': promotionEndsAt?.toUtc().toIso8601String(),
    'certificate_enabled': certificateEnabled,
    'reviews_enabled': reviewsEnabled,
    'comments_enabled': commentsEnabled,
    'visibility': visibility,
    'availability': availability,
    'scheduled_publish_at': scheduledPublishAt?.toUtc().toIso8601String(),
    'is_featured': isFeatured,
    'cover_image_path': coverImagePath,
    'cover_alt_text': coverAltText,
    'cover_focal_x': coverFocalX,
    'cover_focal_y': coverFocalY,
    'trailer_hls_path': trailerHlsPath,
    'trailer_source_type': trailerSourceType,
    'trailer_external_video_id': trailerExternalVideoId,
    'trailer_status': trailerStatus,
    'authoring_revision': authoringRevision,
    'modules': modules.map((e) => e.toJson()).toList(),
  };

  static List<String> _stringList(dynamic value) =>
      (value as List?)?.map((item) => item.toString()).toList() ?? const [];

  static DateTime? _dateTime(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}
