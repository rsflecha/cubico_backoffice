import 'package:cubico_backoffice/features/costs/presentation/tabs/energy_tab.dart';
import 'package:cubico_backoffice/features/costs/presentation/tabs/margins_tab.dart';
import 'package:material_ui/material_ui.dart';

class CostsScreen extends StatelessWidget {
  const CostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Custos e preços"),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: "Energia e impressoras"),
              Tab(text: "Filamentos"),
              Tab(text: "Embalagens e componentes"),
              Tab(text: "Portes de envio"),
              Tab(text: "Taxas"),
              Tab(text: "Margens e custos fixos"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            EnergyTab(),
            _Placeholder("Filamentos"),
            _Placeholder("Embalagens e componentes"),
            _Placeholder("Portes de envio"),
            _Placeholder("Taxas"),
            MarginsTab(),
          ],
        ),
      ),
    );
  }
}

/// Página provisória de um separador, até ser feita.
class _Placeholder extends StatelessWidget {
  const _Placeholder(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("$title — em construção"));
  }
}