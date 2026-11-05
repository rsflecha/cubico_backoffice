import 'package:freezed_annotation/freezed_annotation.dart';

part 'printer.freezed.dart';
part 'printer.g.dart';

/// Uma impressora e os números para calcular quanto custa uma hora a imprimir.
@freezed
abstract class Printer with _$Printer {
  const factory Printer({
    required int id,
    required String name,
    required int powerW,              // consumo médio a imprimir
    required double purchasePrice,
    required int lifespanHours,       // horas até precisar de outra
    @Default(0) double yearlyMaintenance,
    @Default(1000) int yearlyHours,   // horas de impressão por ano
    @Default(false) bool isDefault,   // a impressora principal
  }) = _Printer;

  factory Printer.fromJson(Map<String, dynamic> json) => _$PrinterFromJson(json);
}