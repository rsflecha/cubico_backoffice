import '../domain/component.dart';
import '../domain/component_repository.dart';

class DemoComponentRepository implements ComponentRepository {
  final List<Component> _items = const [
    // componentes: vão dentro do produto
    Component(id: 1, name: "Argola de chaveiro", kind: ComponentKind.component, sizeLabel: "25 mm", weightG: 2, packPrice: 3.00, unitsPerPack: 100),
    Component(id: 2, name: "Íman de neodímio", kind: ComponentKind.component, sizeLabel: "6 × 2 mm", weightG: 1, packPrice: 7.50, unitsPerPack: 100),
    Component(id: 3, name: "Parafuso M3", kind: ComponentKind.component, sizeLabel: "10 mm", weightG: 1, packPrice: 4.20, unitsPerPack: 100),

    // embalagens: servem para enviar
    Component(id: 4, name: "Caixa", kind: ComponentKind.packaging, sizeLabel: "S", weightG: 40, packPrice: 4.80, unitsPerPack: 10),
    Component(id: 5, name: "Papel de seda", kind: ComponentKind.packaging, weightG: 5, packPrice: 3.00, unitsPerPack: 50),
    Component(id: 6, name: "Cartão", kind: ComponentKind.packaging, weightG: 3, packPrice: 3.00, unitsPerPack: 50),
    Component(id: 7, name: "Autocolante", kind: ComponentKind.packaging, weightG: 1, packPrice: 2.00, unitsPerPack: 100),
  ];

  Future<void> _latency() => Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<Component>> fetchAll() async {
    await _latency();
    return List<Component>.of(_items);
  }
}