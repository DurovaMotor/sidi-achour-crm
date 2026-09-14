import { readAdamSession } from "./_lib/adam-auth.js";
import {
  accessBypassCookie,
  accessIsBlocked,
  blockedResponse,
  hasAccessBypass,
  loadAccessControlSettings,
  requiresTimezoneProbe,
  timezoneProbeResponse,
} from "./_lib/access-control.js";

const ADAM_PATHS = new Set(["/adam", "/adam/", "/adam.html"]);
const CUSTOMER_PATHS = new Set(["/", "/index.html", "/sidi", "/sidi/", "/sidi.html"]);
const BYPASS_PATHS = new Set(["/key", "/key/", "/key.html", "/sidi/key", "/sidi/key/", "/sidi/key.html"]);

export async function onRequest(context) {
  const url = new URL(context.request.url);
  const path = url.pathname.toLowerCase();
  const isApi = path.startsWith("/api/");

  if (BYPASS_PATHS.has(path)) {
    const response = await context.next();
    const headers = new Headers(response.headers);
    headers.append("Set-Cookie", accessBypassCookie());
    headers.set("Cache-Control", "private, no-store");
    return new Response(response.body, { status: response.status, statusText: response.statusText, headers });
  }

  if (ADAM_PATHS.has(path)) {
    const session = await readAdamSession(context.request, context.env.ADAM_SESSION_SECRET);
    if (!session) {
      return new Response(null, {
        status: 302,
        headers: {
          Location: "/login?next=%2FAdam",
          "Cache-Control": "no-store",
        },
      });
    }

    if (path === "/adam.html") {
      return new Response(null, {
        status: 302,
        headers: { Location: "/Adam", "Cache-Control": "no-store" },
      });
    }

    const response = await context.next();
    const headers = new Headers(response.headers);
    headers.set("Cache-Control", "private, no-store");
    return new Response(response.body, { status: response.status, statusText: response.statusText, headers });
  }

  if (isApi && (path.startsWith("/api/auth/") || path.startsWith("/api/admin/"))) return context.next();

  if (CUSTOMER_PATHS.has(path) || isApi) {
    if (hasAccessBypass(context.request)) return context.next();
    if (isApi && await readAdamSession(context.request, context.env.ADAM_SESSION_SECRET)) return context.next();

    const settings = await loadAccessControlSettings(context.env.DB);
    if (accessIsBlocked(context.request, settings)) return blockedResponse(isApi);
    if (requiresTimezoneProbe(context.request, settings)) {
      return isApi ? blockedResponse(true) : timezoneProbeResponse();
    }
  }

  return context.next();
}
