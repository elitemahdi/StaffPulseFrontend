/// Model Serializer (DTO) for Flowable tasks returned by /leave/tasks/pending
class LeaveTaskSerializer {
  final String taskId;
  final String? taskName;
  final String processInstanceId;
  final String? createdAt;
  final String employeeCode;
  final String department;
  final String leaveType;
  final int durationDays;
  final bool requiresMedicalCertificate;
  final double? aiRiskScore;
  final String? aiRecommendation;
  final String? aiReasoning;

  const LeaveTaskSerializer({
    required this.taskId,
    this.taskName,
    required this.processInstanceId,
    this.createdAt,
    required this.employeeCode,
    required this.department,
    required this.leaveType,
    required this.durationDays,
    required this.requiresMedicalCertificate,
    this.aiRiskScore,
    this.aiRecommendation,
    this.aiReasoning,
  });

  factory LeaveTaskSerializer.fromJson(Map<String, dynamic> json) {
    return LeaveTaskSerializer(
      taskId: json['task_id'] as String? ?? '',
      taskName: json['task_name'] as String?,
      processInstanceId: json['process_instance_id'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      employeeCode: json['employee_code'] as String? ?? '',
      department: json['department'] as String? ?? '',
      leaveType: json['leave_type'] as String? ?? 'استحقاقی',
      durationDays: json['duration_days'] as int? ?? 1,
      requiresMedicalCertificate: json['requires_medical_certificate'] as bool? ?? false,
      aiRiskScore: (json['ai_risk_score'] as num?)?.toDouble(),
      aiRecommendation: json['ai_recommendation'] as String?,
      aiReasoning: json['ai_reasoning'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'task_name': taskName,
      'process_instance_id': processInstanceId,
      'created_at': createdAt,
      'employee_code': employeeCode,
      'department': department,
      'leave_type': leaveType,
      'duration_days': durationDays,
      'requires_medical_certificate': requiresMedicalCertificate,
      'ai_risk_score': aiRiskScore,
      'ai_recommendation': aiRecommendation,
      'ai_reasoning': aiReasoning,
    };
  }
}
