import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Dashboard'),
          ),
        ],
      ),
    );
  }
}
