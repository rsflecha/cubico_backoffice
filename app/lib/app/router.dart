import 'package:cubico_backoffice/features/dashboard/presentation/dashboard_screen.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: "/dashboard",
    routes: [
      GoRoute(
        path: "/orders",
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
          path: "/dashboard",
          builder: (context, state) => const DashboardScreen(),
      ),
    ]
  );
});