import 'package:cubico_backoffice/app/shell/app_shell.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/auth/presentation/login_screen.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_screen.dart';
import 'package:cubico_backoffice/features/customers/presentation/customers_screen.dart';
import 'package:cubico_backoffice/features/dashboard/presentation/dashboard_screen.dart';
import 'package:cubico_backoffice/features/orders/presentation/create_order_screen.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_screen.dart';
import 'package:cubico_backoffice/features/production/presentation/production_screen.dart';
import 'package:cubico_backoffice/features/products/presentation/products_screen.dart';
import 'package:cubico_backoffice/features/settings/presentation/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cubico_backoffice/features/orders/presentation/order_detail_screen.dart';
import 'package:cubico_backoffice/features/products/presentation/product_form_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // a "campainha": toca sempre que a sessão muda (entrar ou sair)
  final sessionChanges = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (previous, next) => sessionChanges.value++);
  ref.onDispose(sessionChanges.dispose);
  return GoRouter(
    initialLocation: "/dashboard",
    refreshListenable: sessionChanges,
    redirect: (context, state) {
      final user = ref.read(sessionProvider);
      final atLogin = state.matchedLocation == "/login";

      // sem sessão: só se pode estar no login
      if (user == null) return atLogin ? null : "/login";
      // com sessão: o login já não faz sentido
      if (atLogin) return "/dashboard";
      return null; // pode passar
    },
    routes: [
      GoRoute(
        path: "/login",
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/dashboard",
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/orders",
                builder: (context, state) => const OrdersScreen(),
                routes: [
                  GoRoute(
                    path: "new", // fica /orders/new
                    builder: (context, state) => const CreateOrderScreen(),
                  ),
                  GoRoute(
                    path: ":id", // fica /orders/1
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters["id"]!);
                      return OrderDetailScreen(orderId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/production",
                builder: (context, state) => const ProductionScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/products",
                builder: (context, state) => const ProductsScreen(),
                routes: [
                  GoRoute(
                    path: "new", // fica /products/new
                    builder: (context, state) => const ProductFormScreen(),
                  ),
                  GoRoute(
                    path: ":id", // fica /products/3, /products/7...
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters["id"]!);
                      return ProductFormScreen(productId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/customers",
                builder: (context, state) => const CustomersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/costs",
                builder: (context, state) => const CostsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/settings",
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
