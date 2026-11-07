// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrintJob _$PrintJobFromJson(Map<String, dynamic> json) => _PrintJob(
  id: (json['id'] as num).toInt(),
  orderLineId: (json['order_line_id'] as num?)?.toInt(),
  orderId: (json['order_id'] as num?)?.toInt(),
  orderNumber: (json['order_number'] as num?)?.toInt(),
  variantId: (json['variant_id'] as num).toInt(),
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  status:
      $enumDecodeNullable(_$PrintJobStatusEnumMap, json['status']) ??
      PrintJobStatus.queued,
  estimatedMin: (json['estimated_min'] as num).toInt(),
  startedAt: json['started_at'] == null
      ? null
      : DateTime.parse(json['started_at'] as String),
  finishedAt: json['finished_at'] == null
      ? null
      : DateTime.parse(json['finished_at'] as String),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$PrintJobToJson(_PrintJob instance) => <String, dynamic>{
  'id': instance.id,
  'order_line_id': instance.orderLineId,
  'order_id': instance.orderId,
  'order_number': instance.orderNumber,
  'variant_id': instance.variantId,
  'quantity': instance.quantity,
  'status': _$PrintJobStatusEnumMap[instance.status]!,
  'estimated_min': instance.estimatedMin,
  'started_at': instance.startedAt?.toIso8601String(),
  'finished_at': instance.finishedAt?.toIso8601String(),
  'notes': instance.notes,
};

const _$PrintJobStatusEnumMap = {
  PrintJobStatus.queued: 'queued',
  PrintJobStatus.printing: 'printing',
  PrintJobStatus.postProcessing: 'post_processing',
  PrintJobStatus.done: 'done',
};
