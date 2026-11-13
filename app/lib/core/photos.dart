import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// O lado maior de uma foto depois de reduzida, em píxeis. Chega e sobra para a Etsy e para a app.
const photoMaxSide = 1600;

/// Prepara uma foto para enviar: endireita-a, reduz-a e grava-a como JPG.
///
/// Porquê: uma foto de telemóvel tem facilmente 4–8 MB, e a API só aceita 2 MB.
/// Reduzida a 1600 px fica com uns 200–500 KB, e o envio é muito mais rápido.
/// Devolve null se o ficheiro não for uma imagem que se consiga ler (ex.: HEIC do iPhone).
Future<Uint8List?> preparePhoto(Uint8List original) {
  // compute() faz o trabalho pesado noutro "isolate" (outra linha de execução),
  // para o ecrã não congelar enquanto a foto é reduzida. Na web corre na mesma linha.
  return compute(_prepare, original);
}

Uint8List? _prepare(Uint8List original) {
  final decoded = img.decodeImage(original);
  if (decoded == null) return null;

  // as fotos de telemóvel vêm muitas vezes "deitadas", com a rotação guardada à parte (EXIF):
  // bakeOrientation roda os píxeis a sério, para a foto não aparecer de lado
  var photo = img.bakeOrientation(decoded);

  final longest = photo.width > photo.height ? photo.width : photo.height;
  if (longest > photoMaxSide) {
    photo = photo.width >= photo.height
        ? img.copyResize(photo, width: photoMaxSide)
        : img.copyResize(photo, height: photoMaxSide);
  }
  return img.encodeJpg(photo, quality: 85);
}
