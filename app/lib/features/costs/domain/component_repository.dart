import 'component.dart';

abstract interface class ComponentRepository {
  Future<List<ComponentRepository>> fetchAll();
}