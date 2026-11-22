# v0.3.1 — associar à mão e histórico das encomendas

Uma versão pequena, preparada antes da primeira venda na Etsy.

## Novidades desde a v0.3.0

**Etsy**
- "Conferir os SKU": um artigo de um anúncio que não liga a nenhuma variante (SKU diferente,
  ou sem SKU num anúncio com várias variações) tem agora o botão **Associar**: escolhe-se a
  variante da app e as vendas desse artigo passam a entrar sozinhas. "Desfazer" tira a associação.
  Só o administrador pode associar (migração 012, tabela `etsy_links`).
- A sincronização procura primeiro pelo SKU, depois pela associação feita à mão, e só no fim
  pelo anúncio (quando ele tem uma só variante).

**Encomendas**
- Novo cartão **Histórico** no detalhe da encomenda: o que mudou (estado, pagamento, método de
  pagamento, transportadora, código de seguimento, data de envio, notas), quando e quem
  — a pessoa, a Etsy, ou a app sozinha.
- Nova janela **Escolher produto**: produtos por categoria (com botões para filtrar), foto em
  miniatura, variantes à vista pela ordem em que foram criadas, e procura opcional (nome,
  variante ou SKU, sem ligar a acentos). No telemóvel ocupa o ecrã todo.
- Corrigido: no ecrã largo, os cartões da direita apareciam duas vezes.

## Descarregar

| Ficheiro | Para quê |
|---|---|
| `cubico-backoffice-v0.3.1-windows.zip` | Windows: extrair e abrir `cubico_backoffice.exe` |
| `cubico-backoffice-v0.3.1-android.apk` | Android: instalar no telemóvel (é preciso permitir "fontes desconhecidas") |

A versão web (`app.fazendasubmersa.pt`) já está atualizada.

> O APK está assinado com a chave de testes do Flutter (não vai para a Play Store).
