import 'dart:math' as math;

import 'package:cubico_backoffice/core/colors.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:cubico_backoffice/features/stock/domain/filament_stock.dart';
import 'package:cubico_backoffice/features/stock/presentation/stock_providers.dart';
import 'package:cubico_backoffice/features/stock/presentation/widgets/purchase_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// O nome de um filamento para listas: "PLA Black Basic · Bambu Lab".
String filamentLabel(Filament f) {
  final brand = f.brand?.trim() ?? "";
  return brand.isEmpty ? f.displayName : "${f.displayName} · $brand";
}

/// A lista do Stock: cada filamento com uma barra, os rolos e as gramas.
class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  /// A barra enche com este número de rolos (5 rolos = barra cheia).
  static const _fullBarSpools = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stock = ref.watch(filamentStockProvider);
    final filaments = ref.watch(filamentsProvider);
    final isAdmin = ref.watch(sessionProvider)?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock"),
        actions: [
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.icon(
                onPressed: filaments.hasValue
                    ? () => showPurchaseDialog(context, filaments: filaments.requireValue)
                    : null,
                icon: const Icon(Icons.add),
                label: const Text("Registar compra"),
              ),
            ),
        ],
      ),
      body: stock.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Erro: $error")),
        data: (stocks) => filaments.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text("Erro: $error")),
          data: (list) {
            // só os filamentos que a API conhece E têm linha de stock
            final rows = [
              for (final f in list)
                for (final s in stocks)
                  if (s.filamentId == f.id) (f, s),
            ];
            if (rows.isEmpty) {
              return const Center(child: Text("Ainda não há filamentos."));
            }
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Card(
                  child: Column(
                    children: [for (final (f, s) in rows) _tile(context, f, s)],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, Filament f, FilamentStock s) {
    final low = s.stockG <= s.minStockG; // 1 rolo ou menos (limite por filamento)
    final full = math.max(1, f.spoolWeightG) * _fullBarSpools;
    final spools = s.spools.toStringAsFixed(1).replaceAll(".", ",");
    return ListTile(
      leading: CircleAvatar(radius: 10, backgroundColor: colorFromHex(f.colorHex)),
      title: Text(filamentLabel(f), style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: (s.stockG / full).clamp(0.0, 1.0)),
            const SizedBox(height: 4),
            Text("$spools rolos · ${s.stockG.round()} g"),
          ],
        ),
      ),
      trailing: low
          ? const Tooltip(
              message: "1 rolo ou menos",
              child: Icon(Icons.warning_amber_rounded, color: Colors.orange),
            )
          : null,
      onTap: () => context.push("/stock/${f.id}"),
    );
  }
}
