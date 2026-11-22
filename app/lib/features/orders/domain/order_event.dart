/// Uma linha do histórico de uma encomenda: o que mudou, quando, e quem mudou.
class OrderEvent {
  const OrderEvent({
    required this.id,
    required this.description,
    required this.source,
    required this.createdAt,
    this.newStatus,
    this.userName,
  });

  factory OrderEvent.fromJson(Map<String, dynamic> json) => OrderEvent(
        id: json["id"] as int,
        description: json["description"] as String,
        source: json["source"] as String,
        createdAt: DateTime.parse(json["created_at"] as String),
        newStatus: json["new_status"] as String?,
        userName: json["user_name"] as String?,
      );

  final int id;
  final String description; // "Estado: Pendente → Em produção", "Pagamento: Por pagar → Pago"…
  final String source; // user (alguém na app), sync (a Etsy), system (a app sozinha)
  final DateTime createdAt;
  final String? newStatus; // o estado novo, quando o estado mudou
  final String? userName; // quem mudou (só quando foi alguém na app)

  /// Quem fez, em português: o nome da pessoa, "Etsy" ou "Automático".
  String get who => switch (source) {
        "user" => userName ?? "Alguém",
        "sync" => "Etsy",
        _ => "Automático",
      };
}
