import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        destinations: [
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), label: "Início"),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: "Encomendas"),
          NavigationDestination(icon: Icon(Icons.print_outlined), label: "Produção"),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: "Produtos")
        ],
      ),
    );
  }
}
