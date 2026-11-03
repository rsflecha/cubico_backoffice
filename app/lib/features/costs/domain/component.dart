import 'package:freezed_annotation/freezed_annotation.dart';

part 'component.freezed.dart';
part 'component.g.dart';

/// Vai dentro do produto, ou serve para o embalar.
enum ComponentKind {
  @JsonValue("component")
  component,
  @JsonValue("packaging")
  packaging,
}

@freezed
abstract class Component with _$Component {
  const factory Component({
    required int id,
    required String name,
    required ComponentKind kind,
    String? sizeLabel,             // "25 mm", "S", "A5"…
    @Default(0) int weightG,       // peso de uma unidade, conta para os portes
    required double packPrice,     // quanto custa o pack
    @Default(1) int unitsPerPack,  // quantas unidades traz o pack
    @Default(0) int stockQty,
    @Default(0) int minStockQty,
  }) = _Component;

  factory Component.fromJson(Map<String, dynamic> json) =>
      _$ComponentFromJson(json);
}