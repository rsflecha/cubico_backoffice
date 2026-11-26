# v0.3.2 — gramas com décimas, cores fixas e avisos de encomendas

A primeira versão de Windows e Android que lê e grava as gramas com 2 casas decimais
(86,4 g já não passa a 86 g). **Quem usa a v0.3.1 deve atualizar:** essa versão corta as
décimas e, se gravar uma variante, grava as gramas sem elas.

## Novidades desde a v0.3.1

**Produtos e custos**
- Gramas com 2 casas decimais na receita e na Cor 2 (migração 014).
  O peso para os portes arredonda para cima (100,4 g contam como 101 g).
- No telemóvel, os campos de gramas abrem o teclado com vírgula.
- Cores fixas em cada variante (ex.: suporte F1): a receita leva várias cores e as gramas de
  cada uma, e o custo faz-se cor a cor.
- Campo **Estado** no produto (Ativo, Rascunho, Arquivado), com etiqueta na lista.

**Encomendas**
- Escolher produto por categoria, com foto e procura; as variantes aparecem por nome, com os
  números pelo valor (Rena 95mm antes de Rena 240mm).
- Marcar como paga depois de criada; ao entregar uma encomenda por pagar, a app pergunta.
- Cancelar uma encomenda.
- No telemóvel, o total e o botão **Criar encomenda** ficam fixos em baixo.

**Avisos e ecrã**
- Avisos de encomendas novas («Nova encomenda #…»), só para administradores e só na versão web.
- Dashboard: gráfico com retas e datas sem se sobreporem.

## Descarregar

| Ficheiro | Para quê |
|---|---|
| `cubico-backoffice-v0.3.2-windows.zip` | Windows: extrair e abrir `cubico_backoffice.exe` |
| `cubico-backoffice-v0.3.2-android.apk` | Android: instalar no telemóvel (é preciso permitir "fontes desconhecidas") |

A versão web (`app.fazendasubmersa.pt`) já está atualizada.

> **Android:** o APK passou a estar assinado com a chave própria da CubicoDesign3D (até à v0.3.1
> era a chave de testes do Flutter). Por isso não instala por cima da versão antiga:
> **desinstala primeiro a app antiga** e depois instala esta. A sessão terá de ser iniciada outra vez.
