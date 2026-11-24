// O service worker dos avisos de encomendas novas: um pequeno programa que o browser corre em
// segundo plano, mesmo com a app fechada. Recebe o aviso que a API mandou e mostra-o; ao tocar,
// abre a app na encomenda. É registado pelo push.js.
self.addEventListener("install", () => self.skipWaiting());
self.addEventListener("activate", (event) => event.waitUntil(self.clients.claim()));

self.addEventListener("push", (event) => {
  let data = {};
  try {
    data = event.data ? event.data.json() : {};
  } catch (_) {
    data = { body: event.data ? event.data.text() : "" };
  }
  event.waitUntil(
    self.registration.showNotification(data.title || "CubicoDesign3D", {
      body: data.body || "",
      icon: "icons/Icon-192.png",
      badge: "icons/Icon-192.png",
      data: { url: data.url || "/" },
    })
  );
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const url = new URL(event.notification.data && event.notification.data.url || "/", self.registration.scope).href;
  event.waitUntil((async () => {
    const windows = await self.clients.matchAll({ type: "window", includeUncontrolled: true });
    // a app já está aberta: traz para a frente e pede-lhe que vá à encomenda (o push.js ouve)
    for (const client of windows) {
      if ("focus" in client) {
        await client.focus();
        client.postMessage({ type: "cubico-open", url });
        return;
      }
    }
    // fechada: abre-a já no endereço da encomenda
    await self.clients.openWindow(url);
  })());
});
