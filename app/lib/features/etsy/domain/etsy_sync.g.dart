// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'etsy_sync.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EtsySyncRun _$EtsySyncRunFromJson(Map<String, dynamic> json) => _EtsySyncRun(
  status: json['status'] as String,
  startedAt: DateTime.parse(json['started_at'] as String),
  finishedAt: json['finished_at'] == null
      ? null
      : DateTime.parse(json['finished_at'] as String),
  createdCount: (json['created_count'] as num?)?.toInt() ?? 0,
  updatedCount: (json['updated_count'] as num?)?.toInt() ?? 0,
  skippedCount: (json['skipped_count'] as num?)?.toInt() ?? 0,
  errorMessage: json['error_message'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$EtsySyncRunToJson(_EtsySyncRun instance) =>
    <String, dynamic>{
      'status': instance.status,
      'started_at': instance.startedAt.toIso8601String(),
      'finished_at': instance.finishedAt?.toIso8601String(),
      'created_count': instance.createdCount,
      'updated_count': instance.updatedCount,
      'skipped_count': instance.skippedCount,
      'error_message': instance.errorMessage,
      'notes': instance.notes,
    };

_EtsySyncInfo _$EtsySyncInfoFromJson(Map<String, dynamic> json) =>
    _EtsySyncInfo(
      connected: json['connected'] as bool? ?? false,
      last: json['last'] == null
          ? null
          : EtsySyncRun.fromJson(json['last'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EtsySyncInfoToJson(_EtsySyncInfo instance) =>
    <String, dynamic>{
      'connected': instance.connected,
      'last': instance.last?.toJson(),
    };
