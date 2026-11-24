// Avisos de encomendas novas (Web Push) no browser.
// A app Flutter chama estas 3 funções (lib/core/push/push_bridge_web.dart); as regras
// (quem recebe, o texto do aviso) estão na API (api/src/push.php).
(function () {
  // mudar o ?v= quando o push_sw.js mudar: o browser vai buscar o novo
  const WORKER = "push_sw.js?v=1";

  const isIos = /iPad|iPhone|iPod/.test(navigator.userAgent) ||
    (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1); // o iPad diz que é um Mac
  const fromHomeScreen = window.matchMedia("(display-mode: standalone)").matches || navigator.standalone === true;
  const supported = !!(window.isSecureContext && "serviceWorker" in navigator && "PushManager" in window && "Notification" in window);

  let registering = null;
  function registration() {
    registering = registering || navigator.serviceWorker.register(WORKER, { scope: "./" })
      .then(() => navigator.serviceWorker.ready);
    return registering;
  }
  // com os avisos já autorizados, regista logo (assim o service worker atualiza-se sozinho)
  if (supported && Notification.permission === "granted") registration().catch(() => {});

  // ao tocar no aviso com a app aberta: o service worker pede para ir à encomenda
  if ("serviceWorker" in navigator) {
    navigator.serviceWorker.addEventListener("message", function (e) {
      if (e.data && e.data.type === "cubico-open") window.location.href = e.data.url;
    });
  }

  function key(base64url) {
    let s = base64url.replace(/-/g, "+").replace(/_/g, "/");
    while (s.length % 4) s += "=";
    const raw = atob(s);
    const bytes = new Uint8Array(raw.length);
    for (let i = 0; i < raw.length; i++) bytes[i] = raw.charCodeAt(i);
    return bytes;
  }

  function failure(e) {
    return JSON.stringify({ error: (e && (e.name || e.message)) || "Error" });
  }

  /**
   * Em que pé estão os avisos neste aparelho:
   * unsupported · home-screen (iPhone/iPad fora do ecrã principal) · denied · off · on
   */
  window.cubicoPushState = async function () {
    try {
      if (isIos && !fromHomeScreen) return JSON.stringify({ state: "home-screen" });
      if (!supported) return JSON.stringify({ state: "unsupported" });
      if (Notification.permission === "denied") return JSON.stringify({ state: "denied" });
      if (Notification.permission !== "granted") return JSON.stringify({ state: "off" });
      const reg = await registration();
      const sub = await reg.pushManager.getSubscription();
      return JSON.stringify(sub ? { state: "on", endpoint: sub.endpoint } : { state: "off" });
    } catch (e) {
      return failure(e);
    }
  };

  /**
   * Ligar: pede autorização e inscreve o aparelho. Devolve {endpoint, keys: {p256dh, auth}}.
   * O pedido de autorização vem PRIMEIRO, antes de qualquer espera: o Safari só o mostra
   * logo a seguir a um toque (por isso a app já traz a chave pública consigo).
   */
  window.cubicoPushEnable = async function (publicKey) {
    try {
      const permission = await Notification.requestPermission();
      if (permission !== "granted") return JSON.stringify({ error: "denied" });
      const reg = await registration();
      let sub = await reg.pushManager.getSubscription();
      if (!sub) sub = await reg.pushManager.subscribe({ userVisibleOnly: true, applicationServerKey: key(publicKey) });
      return JSON.stringify(sub.toJSON());
    } catch (e) {
      return failure(e);
    }
  };

  /** Desligar: esquece a inscrição neste aparelho. Devolve {endpoint} (para a API a apagar). */
  window.cubicoPushDisable = async function () {
    try {
      if (!supported) return JSON.stringify({ endpoint: null });
      const reg = await registration();
      const sub = await reg.pushManager.getSubscription();
      if (!sub) return JSON.stringify({ endpoint: null });
      const endpoint = sub.endpoint;
      await sub.unsubscribe();
      return JSON.stringify({ endpoint });
    } catch (e) {
      return failure(e);
    }
  };
})();
