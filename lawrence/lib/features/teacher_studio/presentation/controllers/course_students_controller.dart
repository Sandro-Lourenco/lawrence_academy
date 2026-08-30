import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/service_repositories.dart';
import '../../domain/entities/teacher_course_student.dart';

final courseStudentsProvider = FutureProvider.autoDispose
    .family<List<TeacherCourseStudent>, String>((ref, courseId) {
      return ref
          .read(teacherCourseUseCasesProvider)
          .listCourseStudents(courseId);
    });
