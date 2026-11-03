import '../domain/component.dart';

abstract interface class ComponentRepository {
  Future<List<Component>> fetchAll();
}