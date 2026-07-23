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
class Lesson {
  final String id;
  final String moduleId;
  final String courseId;
  final String title;
  final String description;
  final String status;
  final int orderIndex;
  final int durationSeconds;
  final String? hlsStoragePath;
  final AISummary aiSummary;

  const Lesson({
    required this.id,
    required this.moduleId,
    required this.courseId,
    required this.title,
    this.description = '',
    required this.status,
    this.orderIndex = 0,
    required this.durationSeconds,
    this.hlsStoragePath,
    required this.aiSummary,
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
      hlsStoragePath: json['hls_storage_path'] as String?,
      aiSummary: AISummary.fromJson(
        json['ai_summary'] as Map<String, dynamic>?,
      ),
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
    'hls_storage_path': hlsStoragePath,
    'ai_summary': aiSummary.toJson(),
  };
}

@immutable
class Module {
  final String id;
  final String courseId;
  final String title;
  final int orderIndex;
  final List<Lesson> lessons;

  const Module({
    required this.id,
    required this.courseId,
    required this.title,
    required this.orderIndex,
    required this.lessons,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    final lessonsJson = json['lessons'] as List? ?? [];
    return Module(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      orderIndex: json['order_index'] as int? ?? 0,
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
    'lessons': lessons.map((e) => e.toJson()).toList(),
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
    required this.modules,
  });

  bool get isFree => monthlyPrice <= 0;

  int get lessonCount => modules.fold(
    0,
    (total, module) => total + module.lessons.length,
  );

  factory Course.fromJson(Map<String, dynamic> json) {
    final modulesJson = json['modules'] as List? ?? [];
    final rawMonthlyPrice = json['monthly_price'];
    final monthlyPrice = rawMonthlyPrice is num
        ? rawMonthlyPrice.toDouble()
        : double.tryParse(rawMonthlyPrice?.toString() ?? '') ?? 0;
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
    'modules': modules.map((e) => e.toJson()).toList(),
  };

  static List<String> _stringList(dynamic value) =>
      (value as List?)?.map((item) => item.toString()).toList() ?? const [];
}
