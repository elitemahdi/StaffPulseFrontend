/// Model Serializer (DTO) for leave request responses from /leave/submit and /leave/employee/{code}/requests
class LeaveRequestSerializer {
  final int id;
  final String employeeCode;
  final String processInstanceId;
  final String leaveType;
  final int durationDays;
  final bool requiresMedicalCertificate;
  final bool requiresSeniorApproval;
  final String currentStep;
  final String status;
  final double? aiRiskScore;
  final String? aiRecommendation;
  final String? aiReasoning;
  final String? createdAt;

  const LeaveRequestSerializer({
    required this.id,
    required this.employeeCode,
    required this.processInstanceId,
    required this.leaveType,
    required this.durationDays,
    required this.requiresMedicalCertificate,
    required this.requiresSeniorApproval,
    required this.currentStep,
    required this.status,
    this.aiRiskScore,
    this.aiRecommendation,
    this.aiReasoning,
    this.createdAt,
  });

  factory LeaveRequestSerializer.fromJson(Map<String, dynamic> json) {
    return LeaveRequestSerializer(
      id: json['id'] as int? ?? json['request_id'] as int? ?? 0,
      employeeCode: json['employee_code'] as String? ?? '',
      processInstanceId: json['process_instance_id'] as String? ?? '',
      leaveType: json['leave_type'] as String? ?? 'استحقاقی',
      durationDays: json['duration_days'] as int? ?? 1,
      requiresMedicalCertificate: json['requires_medical_certificate'] as bool? ?? false,
      requiresSeniorApproval: json['requires_senior_approval'] as bool? ?? false,
      currentStep: json['current_step'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      aiRiskScore: (json['ai_risk_score'] as num?)?.toDouble(),
      aiRecommendation: json['ai_recommendation'] as String?,
      aiReasoning: json['ai_reasoning'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_code': employeeCode,
      'process_instance_id': processInstanceId,
      'leave_type': leaveType,
      'duration_days': durationDays,
      'requires_medical_certificate': requiresMedicalCertificate,
      'requires_senior_approval': requiresSeniorApproval,
      'current_step': currentStep,
      'status': status,
      'ai_risk_score': aiRiskScore,
      'ai_recommendation': aiRecommendation,
      'ai_reasoning': aiReasoning,
      'created_at': createdAt,
    };
  }
}
