class AcademicFormation {
  final String id;
  final String course;
  final String institution;
  final String type;

  const AcademicFormation({
    required this.id,
    required this.course,
    required this.institution,
    required this.type,
  });

  AcademicFormation copyWith({
    String? id,
    String? course,
    String? institution,
    String? type,
  }) {
    return AcademicFormation(
      id: id ?? this.id,
      course: course ?? this.course,
      institution: institution ?? this.institution,
      type: type ?? this.type,
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    this.referredBy,
    this.certificateName,
    this.urlUsername,
    this.biography,
    this.birthDate,
    this.occupation,
    this.company,
    this.jobTitle,
    this.openToOpportunities = false,
    this.linkedinUrl,
    this.twitterUrl,
    this.githubUrl,
    this.customUrl,
    this.academicFormations = const [],
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String role;
  final String? fullName;
  final String? referredBy;
  final String? certificateName;
  final String? urlUsername;
  final String? biography;
  final DateTime? birthDate;
  final String? occupation;
  final String? company;
  final String? jobTitle;
  final bool openToOpportunities;
  final String? linkedinUrl;
  final String? twitterUrl;
  final String? githubUrl;
  final String? customUrl;
  final List<AcademicFormation> academicFormations;
  final String? avatarUrl;

  UserProfile copyWith({
    String? id,
    String? email,
    String? role,
    String? fullName,
    String? referredBy,
    String? certificateName,
    String? urlUsername,
    String? biography,
    DateTime? birthDate,
    String? occupation,
    String? company,
    String? jobTitle,
    bool? openToOpportunities,
    String? linkedinUrl,
    String? twitterUrl,
    String? githubUrl,
    String? customUrl,
    List<AcademicFormation>? academicFormations,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      referredBy: referredBy ?? this.referredBy,
      certificateName: certificateName ?? this.certificateName,
      urlUsername: urlUsername ?? this.urlUsername,
      biography: biography ?? this.biography,
      birthDate: birthDate ?? this.birthDate,
      occupation: occupation ?? this.occupation,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      openToOpportunities: openToOpportunities ?? this.openToOpportunities,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      customUrl: customUrl ?? this.customUrl,
      academicFormations: academicFormations ?? this.academicFormations,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
