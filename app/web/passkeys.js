// Face ID / impressão digital no browser (passkeys, WebAuthn).
// A app Flutter chama estas 3 funções (lib/core/passkeys/passkey_bridge_web.dart).
// O browser só aceita dados binários (ArrayBuffer); a API fala em texto base64url.
// Aqui faz-se a tradução nos dois sentidos, e mais nada: as regras estão na API.
(function () {
  function toBuffer(text) {
    let s = text.replace(/-/g, "+").replace(/_/g, "/");
    while (s.length % 4) s += "=";
    const raw = atob(s);
    const bytes = new Uint8Array(raw.length);
    for (let i = 0; i < raw.length; i++) bytes[i] = raw.charCodeAt(i);
    return bytes.buffer;
  }

  function toText(buffer) {
    const bytes = new Uint8Array(buffer);
    let raw = "";
    for (const b of bytes) raw += String.fromCharCode(b);
    return btoa(raw).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
  }

  // os erros vêm como {"error": "NotAllowedError"}: a app traduz para português
  function failure(e) {
    return JSON.stringify({ error: (e && e.name) || "Error" });
  }

  /** Este browser sabe usar passkeys? (precisa de HTTPS, ou localhost) */
  window.cubicoPasskeysSupported = function () {
    return !!(window.isSecureContext && window.PublicKeyCredential && navigator.credentials);
  };

  /** Ativar: cria a chave no aparelho (pede a cara ou o dedo). */
  window.cubicoPasskeyCreate = async function (optionsJson) {
    try {
      const o = JSON.parse(optionsJson);
      o.challenge = toBuffer(o.challenge);
      o.user.id = toBuffer(o.user.id);
      (o.excludeCredentials || []).forEach(function (c) { c.id = toBuffer(c.id); });
      const cred = await navigator.credentials.create({ publicKey: o });
      return JSON.stringify({
        client_data_json: toText(cred.response.clientDataJSON),
        attestation_object: toText(cred.response.attestationObject),
      });
    } catch (e) {
      return failure(e);
    }
  };

  /** Entrar: o aparelho mostra as contas que tem e assina com a escolhida. */
  window.cubicoPasskeyGet = async function (optionsJson) {
    try {
      const o = JSON.parse(optionsJson);
      o.challenge = toBuffer(o.challenge);
      (o.allowCredentials || []).forEach(function (c) { c.id = toBuffer(c.id); });
      const a = await navigator.credentials.get({ publicKey: o });
      return JSON.stringify({
        id: toText(a.rawId),
        client_data_json: toText(a.response.clientDataJSON),
        authenticator_data: toText(a.response.authenticatorData),
        signature: toText(a.response.signature),
        user_handle: a.response.userHandle ? toText(a.response.userHandle) : "",
      });
    } catch (e) {
      return failure(e);
    }
  };
})();
