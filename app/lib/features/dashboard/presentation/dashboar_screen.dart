import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class DashboarScreen extends StatelessWidget {
  const DashboarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        centerTitle: true,
        actions: [
          context.go("/orders"),
        ],
      ),
    );
  }
}
