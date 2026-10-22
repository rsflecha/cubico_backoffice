import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.go("/orders"),
            child: const Text("Encomendas"),
          ),
        ],
      ),
    );
  }
}
