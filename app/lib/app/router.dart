import 'package:cubico_backoffice/app/shell/app_shell.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_screen.dart';
import 'package:cubico_backoffice/features/customers/presentation/customers_screen.dart';
import 'package:cubico_backoffice/features/dashboard/presentation/dashboard_screen.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_screen.dart';
import 'package:cubico_backoffice/features/production/presentation/production_screen.dart';
import 'package:cubico_backoffice/features/products/presentation/products_screen.dart';
import 'package:cubico_backoffice/features/settings/presentation/settings_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: "/dashboard",
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/production',
                builder: (context, state) => const ProductionScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                builder: (context, state) => const ProductsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/customers',
                builder: (context, state) => const CustomersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/costs',
                builder: (context, state) => const CostsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ]
  );
});