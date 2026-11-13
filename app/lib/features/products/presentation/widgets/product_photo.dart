import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

/// A foto de um produto, num quadrado de cantos redondos.
///
/// Sabe mostrar três coisas, por esta ordem:
///   1. [bytes]: uma foto acabada de escolher, que ainda não foi gravada;
///   2. [url]: a foto gravada — um endereço da API, ou um "data:" URI no modo demo;
///   3. nada: um ícone no lugar da foto (os produtos antigos, de antes de a foto ser obrigatória).
class ProductPhoto extends StatelessWidget {
  const ProductPhoto({super.key, this.url, this.bytes, this.size = 48});

  final String? url;
  final Uint8List? bytes;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Icon(Icons.image_outlined, size: size * 0.45, color: colors.onSurfaceVariant),
    );

    final Widget image;
    final picked = bytes;
    final address = url;
    if (picked != null) {
      image = Image.memory(picked, fit: BoxFit.cover);
    } else if (address != null && address.startsWith("data:")) {
      // modo demo: a imagem está dentro do próprio texto
      image = Image.memory(UriData.parse(address).contentAsBytes(), fit: BoxFit.cover, gaplessPlayback: true);
    } else if (address != null) {
      image = Image.network(
        address,
        fit: BoxFit.cover,
        // cacheWidth: descodifica a imagem já do tamanho do quadrado, e não a 1600 px —
        // numa lista com muitos produtos poupa muita memória
        cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
        // se falhar (sem rede, ficheiro apagado), mostra o ícone em vez de um erro vermelho
        errorBuilder: (context, error, stack) => placeholder,
      );
    } else {
      image = placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(size >= 120 ? 12 : 8),
      child: SizedBox.square(dimension: size, child: image),
    );
  }
}
