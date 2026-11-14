import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Uma secção do menu: o ramo do GoRouter (a "gaveta"), o ícone e o nome.
class _Section {
  const _Section(this.branch, this.icon, this.label, {this.costsOnly = false});

  final int
  branch; // a posição no StatefulShellRoute (0 = Dashboard … 6 = Definições)
  final IconData icon;
  final String label;
  final bool costsOnly; // só para quem pode ver custos (o administrador)
}

/// Todas as secções, pela ordem do menu. Os três menus (telemóvel, iPad, PC) leem daqui.
const _sections = [
  _Section(0, Icons.grid_view_outlined, "Início"),
  _Section(1, Icons.receipt_long_outlined, "Encomendas"),
  _Section(2, Icons.print_outlined, "Produção"),
  _Section(3, Icons.inventory_2_outlined, "Produtos"),
  _Section(4, Icons.people_outline, "Clientes"),
  _Section(5, Icons.calculate_outlined, "Custos e preços", costsOnly: true),
  _Section(6, Icons.settings_outlined, "Definições", costsOnly: true),
];

/// No telemóvel, o menu de baixo só tem lugar para estas; as outras vão para o "Mais".
const _phoneBarCount = 4;

/// A partir de que largura entra cada menu.
const _railWidth =
    600; // iPad ao alto, telemóvel deitado: barra lateral estreita
const _sidebarWidth = 900; // PC, iPad deitado: menu lateral completo

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final canSeeCosts = user?.canSeeCosts ?? false;
    final width = MediaQuery.sizeOf(context).width;
    // as secções que este utilizador pode ver (o colaborador não vê Custos nem Definições)
    final sections = [
      for (final s in _sections)
        if (canSeeCosts || !s.costsOnly) s,
    ];

    if (width < _railWidth) return _phone(context, ref, sections, user);
    if (width < _sidebarWidth) return _rail(context, ref, sections);
    return _sidebar(context, ref, user, canSeeCosts);
  }

  /// Telemóvel: menu de baixo com 4 secções + "Mais".
  Widget _phone(
    BuildContext context,
    WidgetRef ref,
    List<_Section> sections,
    AppUser? user,
  ) {
    final current = navigationShell.currentIndex;
    final inBar = sections.take(_phoneBarCount).toList();
    final inMore = sections.skip(_phoneBarCount).toList();
    // se a secção aberta não está no menu de baixo (ex.: Clientes), acende o "Mais"
    final barIndex = inBar.indexWhere((s) => s.branch == current);

    return Scaffold(
      body: navigationShell,
      // com 5 botões num ecrã de 375 px, cada um tem ~75 px: com as letras de origem,
      // "Encomendas" partia-se em duas linhas. A 11 px cabe numa só.
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarTheme.of(context).copyWith(
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: barIndex == -1 ? inBar.length : barIndex,
          onDestinationSelected: (index) {
            if (index < inBar.length) {
              navigationShell.goBranch(inBar[index].branch);
            } else {
              _showMore(context, ref, inMore, user);
            }
          },
          destinations: [
            for (final s in inBar)
              NavigationDestination(icon: Icon(s.icon), label: s.label),
            const NavigationDestination(icon: Icon(Icons.menu), label: "Mais"),
          ],
        ),
      ),
    );
  }

  /// A folha do "Mais": as secções que não couberam em baixo, a conta e o terminar sessão.
  void _showMore(
    BuildContext context,
    WidgetRef ref,
    List<_Section> sections,
    AppUser? user,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final s in sections)
                ListTile(
                  leading: Icon(s.icon),
                  title: Text(s.label),
                  selected: navigationShell.currentIndex == s.branch,
                  onTap: () {
                    Navigator.pop(sheetContext); // fecha a folha
                    navigationShell.goBranch(s.branch);
                  },
                ),
              const Divider(),
              ListTile(
                leading: CircleAvatar(child: Text((user?.name ?? "?")[0])),
                title: Text(user?.name ?? ""),
                subtitle: Text(
                  user?.role == UserRole.admin
                      ? "Administrador"
                      : "Colaborador",
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Terminar sessão"),
                onTap: () {
                  Navigator.pop(sheetContext);
                  ref.read(sessionProvider.notifier).signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// iPad ao alto (e telemóvel deitado): barra lateral estreita, com todas as secções.
  Widget _rail(BuildContext context, WidgetRef ref, List<_Section> sections) {
    final railIndex = sections.indexWhere(
      (s) => s.branch == navigationShell.currentIndex,
    );
    const muted = Color(0xFFA1A1AA);

    return Scaffold(
      body: Row(
        children: [
          // com o telemóvel deitado há pouca altura para 7 secções:
          // o LayoutBuilder + SingleChildScrollView deixam a barra deslizar em vez de "rebentar"
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: NavigationRail(
                    backgroundColor: AppColors.black,
                    indicatorColor: const Color(0xFF3F3F46),
                    labelType: NavigationRailLabelType.all,
                    selectedIconTheme: const IconThemeData(color: Colors.white),
                    unselectedIconTheme: const IconThemeData(color: muted),
                    selectedLabelTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    unselectedLabelTextStyle: const TextStyle(
                      color: muted,
                      fontSize: 12,
                    ),
                    selectedIndex: railIndex == -1 ? null : railIndex,
                    onDestinationSelected: (index) =>
                        navigationShell.goBranch(sections[index].branch),
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Image.asset(
                        "assets/brand/icon-branco.png",
                        height: 32,
                      ),
                    ),
                    trailing: Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: IconButton(
                            tooltip: "Terminar sessão",
                            onPressed: () =>
                                ref.read(sessionProvider.notifier).signOut(),
                            icon: const Icon(Icons.logout, color: muted),
                          ),
                        ),
                      ),
                    ),
                    destinations: [
                      for (final s in sections)
                        NavigationRailDestination(
                          icon: Icon(s.icon),
                          label: Text(s.label),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }

  /// PC e iPad deitado: o menu lateral completo, com a marca e a conta.
  Widget _sidebar(
    BuildContext context,
    WidgetRef ref,
    AppUser? user,
    bool canSeeCosts,
  ) {
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
                        Image.asset("assets/brand/icon-branco.png", height: 36),
                        SizedBox(width: 12),
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
                              style: TextStyle(color: Color(0xFFA1A1AA)),
                            ),
                          ],
                        ),
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
                    if (canSeeCosts)
                      ListTile(
                        leading: Icon(Icons.calculate_outlined),
                        title: Text("Custos e preços"),
                        selected: navigationShell.currentIndex == 5,
                        onTap: () => navigationShell.goBranch(5),
                      ),
                    if (canSeeCosts)
                      ListTile(
                        leading: Icon(Icons.settings_outlined),
                        title: Text("Definições"),
                        selected: navigationShell.currentIndex == 6,
                        onTap: () => navigationShell.goBranch(6),
                      ),
                    const Spacer(),
                    const Divider(color: Color(0xFF3F3F46)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFF3F3F46),
                          child: Text(
                            (user?.name ?? "?")[0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                user?.role == UserRole.admin
                                    ? "Administrador"
                                    : "Colaborador",
                                style: const TextStyle(
                                  color: Color(0xFFA1A1AA),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: "Terminar sessão",
                          onPressed: () =>
                              ref.read(sessionProvider.notifier).signOut(),
                          icon: const Icon(
                            Icons.logout,
                            color: Color(0xFFA1A1AA),
                          ),
                        ),
                      ],
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
