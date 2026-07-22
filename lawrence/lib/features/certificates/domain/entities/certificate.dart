class Certificate {
  final String id;
  final String studentId;
  final String courseId;
  final String validationCode;
  final String signature;
  final String signatureAlgorithm;
  final int signatureVersion;
  final DateTime? revokedAt;
  final String? revocationReason;
  final Map<String, dynamic> metadata;
  final DateTime issuedAt;

  Certificate({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.validationCode,
    required this.signature,
    required this.signatureAlgorithm,
    required this.signatureVersion,
    this.revokedAt,
    this.revocationReason,
    required this.metadata,
    required this.issuedAt,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      courseId: json['course_id'] as String,
      validationCode: json['validation_code'] as String,
      signature: json['signature'] as String? ?? '',
      signatureAlgorithm:
          json['signature_algorithm'] as String? ?? 'HMAC-SHA256',
      signatureVersion: json['signature_version'] as int? ?? 1,
      revokedAt: json['revoked_at'] != null
          ? DateTime.parse(json['revoked_at'] as String)
          : null,
      revocationReason: json['revocation_reason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      issuedAt: DateTime.parse(json['issued_at'] as String),
    );
  }
}
