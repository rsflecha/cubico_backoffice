# v0.3.0 — ligada ao servidor e à Etsy

A primeira versão em uso na loja: deixa de ser só uma demo. A app fala com a sua
própria API (PHP + MariaDB, num alojamento cPanel) e as encomendas da Etsy entram sozinhas.
O modo demo continua lá, sem servidor, para quem quiser explorar.

## Novidades desde a v0.2

**Servidor e contas**
- API em PHP 8.3 (Slim 4) com MariaDB: login com palavras-passe cifradas e tokens JWT,
  permissões verificadas no servidor (o colaborador nunca recebe custos, taxas nem lucros).
- "Manter sessão", sair sozinho quando a sessão expira, e mudar a palavra-passe.
- Versão web, para o iPad e o iPhone pelo browser.

**Etsy**
- Ligar a loja pela conta Etsy (OAuth com PKCE; os tokens ficam cifrados no servidor).
- As encomendas entram sozinhas a cada 15 minutos (ou logo, com "Sincronizar agora"):
  cliente, artigos pelo SKU, portes reais e taxas da Etsy. Depois acompanham o pagamento,
  o envio e os cancelamentos.
- Taxas da Etsy como a Etsy as cobra: 6,5% + 4% também sobre os portes, 0,30 € por
  encomenda e a taxa de anúncio por cada unidade vendida.

**Encomendas e produção**
- Uma encomenda paga vai sozinha para produção, com as tarefas em "Por imprimir".
- Portes dos CTT sugeridos pelo peso; um só campo de portes cobrados.

**Produtos**
- SKU automático (CD3-SUP-01) e variantes por nome (CD3-SUP-01-HAMILTON).
- Foto obrigatória ao criar, variantes com várias cores, apagar variantes nunca vendidas.
- Custos fixos mensais (Etsy Plus…) tirados ao lucro do mês no Dashboard.

**Clientes**
- Telemóvel validado (português ou estrangeiro).
- A localidade preenche-se sozinha pelo código postal (base dos CTT).

**Telemóvel e iPad**
- Todos os ecrãs revistos para ecrãs pequenos: cartões em vez de tabelas, menus,
  botões ao alcance do polegar.

## Descarregar

| Ficheiro | Para quê |
|---|---|
| `cubico-backoffice-v0.3.0-windows.zip` | Windows: extrair e abrir `cubico_backoffice.exe` |
| `cubico-backoffice-v0.3.0-android.apk` | Android: instalar no telemóvel (é preciso permitir "fontes desconhecidas") |

Para explorar sem conta: "Explorar em modo demo" no ecrã de entrada.

> O APK está assinado com a chave de testes do Flutter (não vai para a Play Store).
