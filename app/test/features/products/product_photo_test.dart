import 'dart:convert';
import 'dart:typed_data';

import 'package:cubico_backoffice/core/photos.dart';
import 'package:cubico_backoffice/features/products/data/demo_product_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Uma imagem PNG de teste, com o tamanho pedido.
Uint8List _png(int width, int height) =>
    img.encodePng(img.Image(width: width, height: height));

void main() {
  group("preparePhoto", () {
    test("reduz uma foto grande para 1600 px no lado maior, e grava-a como JPG", () async {
      final result = await preparePhoto(_png(4000, 3000));

      final photo = img.decodeImage(result!)!;
      expect(photo.width, 1600);
      expect(photo.height, 1200); // a proporção mantém-se (4:3)
      expect(img.findDecoderForData(result), isA<img.JpegDecoder>());
    });

    test("uma foto ao alto é reduzida pela altura", () async {
      final photo = img.decodeImage((await preparePhoto(_png(1000, 3200)))!)!;
      expect(photo.height, 1600);
      expect(photo.width, 500);
    });

    test("uma foto pequena não é aumentada", () async {
      final photo = img.decodeImage((await preparePhoto(_png(800, 600)))!)!;
      expect(photo.width, 800);
      expect(photo.height, 600);
    });

    test("um ficheiro que não é imagem devolve null (a ficha mostra o aviso)", () async {
      final notImage = Uint8List.fromList(utf8.encode("<?php echo 1;"));
      expect(await preparePhoto(notImage), isNull);
    });
  });

  group("DemoProductRepository", () {
    test("criar guarda a foto no próprio endereço (data: URI), sem servidor", () async {
      final repository = DemoProductRepository();
      final photo = Uint8List.fromList([1, 2, 3, 4]);

      final created = await repository.create(name: "Teste", baseSku: "TST-1", categoryId: 1, photo: photo);

      expect(created.photoUrl, startsWith("data:image/jpeg;base64,"));
      expect(UriData.parse(created.photoUrl!).contentAsBytes(), photo);
    });

    test("trocar a foto muda o endereço e mantém o resto do produto", () async {
      final repository = DemoProductRepository();
      final created = await repository.create(
        name: "Teste",
        baseSku: "TST-1",
        categoryId: 1,
        photo: Uint8List.fromList([1]),
      );

      final updated = await repository.replacePhoto(created.id, Uint8List.fromList([9, 9]));

      expect(UriData.parse(updated.photoUrl!).contentAsBytes(), [9, 9]);
      expect(updated.name, "Teste");
      final all = await repository.fetchAll();
      expect(all.firstWhere((p) => p.id == created.id).photoUrl, updated.photoUrl);
    });
  });
}
