import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/network_client.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._networkClient, this._supabaseClient);

  final NetworkClient _networkClient;
  final SupabaseClient _supabaseClient;

  @override
  Future<String> uploadAvatar({
    required String userId,
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final extension = fileName.split('.').last.toLowerCase();
    final path =
        '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';
    await _supabaseClient.storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );
    return _supabaseClient.storage.from('avatars').getPublicUrl(path);
  }

  @override
  Future<UserProfile> getMyProfile() async {
    final response = await _networkClient.get<Map<String, dynamic>>(
      '/api/v1/profiles/me',
    );
    final data = response.data ?? const <String, dynamic>{};

    return UserProfile(
      id: data['id'] as String,
      email: data['email'] as String,
      role: data['role'] as String,
      fullName: data['full_name'] as String?,
      referredBy: data['referred_by'] as String?,
      avatarUrl: data['avatar_url'] as String?,
      biography: data['bio'] as String?,
      certificateName: data['certificate_name'] as String?,
      urlUsername: data['url_username'] as String?,
      birthDate: data['birth_date'] != null
          ? DateTime.tryParse(data['birth_date'] as String)
          : null,
      occupation: data['occupation'] as String?,
      company: data['company'] as String?,
      jobTitle: data['job_title'] as String?,
      openToOpportunities: data['open_to_opportunities'] as bool? ?? false,
      linkedinUrl: data['linkedin_url'] as String?,
      twitterUrl: data['twitter_url'] as String?,
      githubUrl: data['github_url'] as String?,
      customUrl: data['custom_url'] as String?,
      academicFormations: (data['academic_formations'] as List? ?? [])
          .map(
            (f) => AcademicFormation(
              id: f['id'] as String,
              course: f['course'] as String,
              institution: f['institution'] as String,
              type: f['type'] as String,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    final payload = {
      'full_name': profile.fullName,
      'referred_by': profile.referredBy,
      'avatar_url': profile.avatarUrl,
      'bio': profile.biography,
      'certificate_name': profile.certificateName,
      'url_username': profile.urlUsername,
      'birth_date': profile.birthDate?.toIso8601String().split('T').first,
      'occupation': profile.occupation,
      'company': profile.company,
      'job_title': profile.jobTitle,
      'open_to_opportunities': profile.openToOpportunities,
      'linkedin_url': profile.linkedinUrl,
      'twitter_url': profile.twitterUrl,
      'github_url': profile.githubUrl,
      'custom_url': profile.customUrl,
      'academic_formations': profile.academicFormations
          .map(
            (f) => {
              'id': f.id,
              'course': f.course,
              'institution': f.institution,
              'type': f.type,
            },
          )
          .toList(),
    };

    final response = await _networkClient.put<Map<String, dynamic>>(
      '/api/v1/profiles/me',
      data: payload,
    );

    final dataList = response.data?['data'] as List?;
    final data = (dataList != null && dataList.isNotEmpty)
        ? dataList.first as Map<String, dynamic>
        : const <String, dynamic>{};

    return UserProfile(
      id: data['id'] as String? ?? profile.id,
      email: data['email'] as String? ?? profile.email,
      role: data['role'] as String? ?? profile.role,
      fullName: data['full_name'] as String?,
      referredBy: data['referred_by'] as String?,
      avatarUrl: data['avatar_url'] as String?,
      biography: data['bio'] as String?,
      certificateName: data['certificate_name'] as String?,
      urlUsername: data['url_username'] as String?,
      birthDate: data['birth_date'] != null
          ? DateTime.tryParse(data['birth_date'] as String)
          : null,
      occupation: data['occupation'] as String?,
      company: data['company'] as String?,
      jobTitle: data['job_title'] as String?,
      openToOpportunities: data['open_to_opportunities'] as bool? ?? false,
      linkedinUrl: data['linkedin_url'] as String?,
      twitterUrl: data['twitter_url'] as String?,
      githubUrl: data['github_url'] as String?,
      customUrl: data['custom_url'] as String?,
      academicFormations: (data['academic_formations'] as List? ?? [])
          .map(
            (f) => AcademicFormation(
              id: f['id'] as String,
              course: f['course'] as String,
              institution: f['institution'] as String,
              type: f['type'] as String,
            ),
          )
          .toList(),
    );
  }
}
