import 'package:loading_icon_button/loading_icon_button.dart';

/// DTO Serializer representing real-time Server-Sent Events (SSE) from /leave/submit-stream.
/// Contains the agent's current thinking step, progress, visual orb state, and payload.
class LeaveStreamEventSerializer {
  final String step;
  final OrbState orbState;
  final double progress;
  final String statusText;
  final Map<String, dynamic>? data;
  final String? error;

  const LeaveStreamEventSerializer({
    required this.step,
    required this.orbState,
    required this.progress,
    required this.statusText,
    this.data,
    this.error,
  });

  factory LeaveStreamEventSerializer.fromJson(Map<String, dynamic> json) {
    final rawOrb = (json['orb_state'] as String? ?? 'working').toLowerCase();
    OrbState resolvedOrb;

    switch (rawOrb) {
      case 'searching':
        resolvedOrb = OrbState.searching;
        break;
      case 'solving':
        resolvedOrb = OrbState.solving;
        break;
      case 'connecting':
        resolvedOrb = OrbState.connecting;
        break;
      case 'listening':
        resolvedOrb = OrbState.listening;
        break;
      case 'weaving':
        resolvedOrb = OrbState.weaving;
        break;
      case 'composing':
        resolvedOrb = OrbState.composing;
        break;
      case 'breathing':
        resolvedOrb = OrbState.breathing;
        break;
      case 'shaping':
        resolvedOrb = OrbState.shaping;
        break;
      case 'working':
      default:
        resolvedOrb = OrbState.working;
        break;
    }

    return LeaveStreamEventSerializer(
      step: json['step'] as String? ?? 'init',
      orbState: resolvedOrb,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      statusText: json['status_text'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : json['data'] != null
              ? Map<String, dynamic>.from(json['data'] as Map)
              : null,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step': step,
      'orb_state': orbState.name,
      'progress': progress,
      'status_text': statusText,
      'data': data,
      'error': error,
    };
  }

  bool get isCompleted => step == 'completed';
  bool get isError => step == 'error' || error != null;
  bool get isAutoApproved =>
      data != null && (data!['status'] == 'auto_approved' || data!['ai_recommendation'] == 'AUTO_APPROVE');

  double? get aiRiskScore => (data?['ai_risk_score'] as num?)?.toDouble();
  String? get aiRecommendation => data?['ai_recommendation'] as String?;
  String? get aiReasoning => data?['ai_reasoning'] as String?;
  int? get requestId => data?['request_id'] as int?;
  String? get processInstanceId => data?['process_instance_id'] as String?;
}
