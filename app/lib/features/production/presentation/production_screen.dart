import 'package:material_ui/material_ui.dart';

class ProductionScreen extends StatelessWidget {
  const ProductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Produção"),
        centerTitle: true,
      ),
    );
  }
}
