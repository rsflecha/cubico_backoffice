import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// Os dois papéis da loja.
enum UserRole {
  @JsonValue("admin")
  admin, // vê tudo
  @JsonValue("staff")
  staff, // colaborador: só a parte operacional
}

/// Quem tem sessão iniciada.
@freezed
abstract class AppUser with _$AppUser {
  const AppUser._();

  const factory AppUser({
    required int id,
    required String name,
    required String email,
    required UserRole role,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

  /// Pode ver custos, lucros e margens?
  bool get canSeeCosts => role == UserRole.admin;
}