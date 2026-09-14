const TIMEZONE_COOKIE = "sidi_client_timezone";
const BYPASS_COOKIE = "sidi_access_bypass";
const CHINA_TIMEZONES = new Set([
  "Asia/Shanghai",
  "Asia/Urumqi",
  "Asia/Chongqing",
  "Asia/Harbin",
  "Asia/Kashgar",
  "Asia/Hong_Kong",
  "Asia/Macao",
  "Asia/Macau",
]);

function cookie(request, name) {
  const header = request.headers.get("Cookie") ?? "";
  for (const item of header.split(";")) {
    const [cookieName, ...value] = item.trim().split("=");
    if (cookieName === name) return decodeURIComponent(value.join("="));
  }
  return null;
}

function browserUsesChinese(request) {
  return (request.headers.get("Accept-Language") ?? "")
    .split(",")
    .some((part) => {
      const [tag, ...parameters] = part.trim().split(";");
      const quality = parameters.find((parameter) => parameter.trim().startsWith("q="));
      return tag.toLowerCase().startsWith("zh") && (!quality || Number(quality.trim().slice(2)) > 0);
    });
}

export async function loadAccessControlSettings(database) {
  const row = await database.prepare(`
    SELECT enabled, block_chinese_language, block_china_timezone, block_china_ip, updated_at
    FROM access_control_settings
    WHERE id = 1
  `).first();
  return {
    enabled: Boolean(row.enabled),
    blockChineseLanguage: Boolean(row.block_chinese_language),
    blockChinaTimezone: Boolean(row.block_china_timezone),
    blockChinaIp: Boolean(row.block_china_ip),
    updatedAt: row.updated_at,
  };
}

export function hasAccessBypass(request) {
  return cookie(request, BYPASS_COOKIE) === "1";
}

export function accessBypassCookie() {
  return `${BYPASS_COOKIE}=1; Path=/; Secure; SameSite=Lax`;
}

export function requiresTimezoneProbe(request, settings) {
  return settings.enabled && settings.blockChinaTimezone && cookie(request, TIMEZONE_COOKIE) === null;
}

export function accessIsBlocked(request, settings) {
  if (!settings.enabled) return false;
  if (settings.blockChineseLanguage && browserUsesChinese(request)) return true;
  if (settings.blockChinaIp && String(request.cf?.country ?? "").toUpperCase() === "CN") return true;
  if (settings.blockChinaTimezone && CHINA_TIMEZONES.has(cookie(request, TIMEZONE_COOKIE))) return true;
  return false;
}

export function timezoneProbeResponse() {
  return new Response(`<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="robots" content="noindex,noarchive">
  <title>Sidi Achour</title>
  <style>body{min-height:100vh;margin:0;display:grid;place-items:center;background:#f7f7f7;color:#1a1a1a;font:16px "Segoe UI",Arial,sans-serif}.mark{width:38px;height:38px;border:3px solid #ccc;border-top-color:#d42a1d;border-radius:50%;animation:r .8s linear infinite}@keyframes r{to{transform:rotate(360deg)}}</style>
</head>
<body><div class="mark" aria-label="Chargement"></div>
<script>
  const zone = Intl.DateTimeFormat().resolvedOptions().timeZone || "Unknown";
  document.cookie = "${TIMEZONE_COOKIE}=" + encodeURIComponent(zone) + "; Path=/; Max-Age=2592000; Secure; SameSite=Lax";
  location.reload();
</script></body></html>`, {
    headers: {
      "Content-Type": "text/html; charset=utf-8",
      "Cache-Control": "no-store",
      "X-Robots-Tag": "noindex, noarchive",
    },
  });
}

export function blockedResponse(isApi) {
  if (isApi) {
    return Response.json({ error: "Access unavailable" }, {
      status: 403,
      headers: { "Cache-Control": "no-store" },
    });
  }
  return new Response(`<!doctype html><html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex,noarchive"><title>Page indisponible</title><style>body{min-height:100vh;margin:0;display:grid;place-items:center;padding:24px;background:#f7f7f7;color:#1a1a1a;font:16px "Segoe UI",Arial,sans-serif;text-align:center}h1{font-size:24px}p{color:#6b6b6b}</style></head><body><main><h1>Page indisponible</h1><p>Cette page n’est pas disponible.</p></main></body></html>`, {
    status: 403,
    headers: {
      "Content-Type": "text/html; charset=utf-8",
      "Cache-Control": "no-store",
      "X-Robots-Tag": "noindex, noarchive",
    },
  });
}
