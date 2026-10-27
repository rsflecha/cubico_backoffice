import 'package:cubico_backoffice/app/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {

    final isWide = MediaQuery.sizeOf(context).width >= 900;

    if(!isWide) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex < 4 ? navigationShell.currentIndex : 0,
          onDestinationSelected: (index) => navigationShell.goBranch(index),
          destinations: [
            NavigationDestination(
                icon: Icon(Icons.grid_view_outlined), label: "Início"),
            NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined), label: "Encomendas"),
            NavigationDestination(
                icon: Icon(Icons.print_outlined), label: "Produção"),
            NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined), label: "Produtos")
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Row(
          children: [
            Container(
              width: 240,
              color: AppColors.black,
              child: ListTileTheme(
                data: ListTileThemeData(
                  textColor: Color(0xFFA1A1AA),
                  iconColor: Color(0xFFA1A1AA),
                  selectedColor: Colors.white,
                  selectedTileColor: Color(0xFF27272A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/brand/icon-branco.png', height: 36),
                          SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                "CubicoDesign3D",
                                style: AppTextStyles.brand.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                                ),
                              ),
                              Text(
                                "Backoffice",
                                style: TextStyle(
                                  color: Color(0xFFA1A1AA)
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        leading: Icon(Icons.grid_view_outlined),
                        title: Text("Dashboard"),
                        selected: navigationShell.currentIndex == 0,
                        onTap: () => navigationShell.goBranch(0),
                      ),
                      ListTile(
                        leading: Icon(Icons.receipt_long_outlined),
                        title: Text("Encomendas"),
                        selected: navigationShell.currentIndex == 1,
                        onTap: () => navigationShell.goBranch(1),
                      ),
                      ListTile(
                        leading: Icon(Icons.print_outlined),
                        title: Text("Produção"),
                        selected: navigationShell.currentIndex == 2,
                        onTap: () => navigationShell.goBranch(2),
                      ),
                      ListTile(
                        leading: Icon(Icons.inventory_2_outlined),
                        title: Text("Produtos"),
                        selected: navigationShell.currentIndex == 3,
                        onTap: () => navigationShell.goBranch(3),
                      ),
                      ListTile(
                        leading: Icon(Icons.people_outline),
                        title: Text("Clientes"),
                        selected: navigationShell.currentIndex == 4,
                        onTap: () => navigationShell.goBranch(4),
                      ),
                      ListTile(
                        leading: Icon(Icons.calculate_outlined),
                        title: Text("Custos e preços"),
                        selected: navigationShell.currentIndex == 5,
                        onTap: () => navigationShell.goBranch(5),
                      ),
                      ListTile(
                        leading: Icon(Icons.settings_outlined),
                        title: Text("Definições"),
                        selected: navigationShell.currentIndex == 6,
                        onTap: () => navigationShell.goBranch(6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }
  }
}
