import 'package:cubico_backoffice/features/costs/domain/component.dart';

abstract interface class ComponentRepository {
  Future<List<Component>> fetchAll();
}
