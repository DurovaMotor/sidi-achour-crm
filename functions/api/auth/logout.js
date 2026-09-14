import { clearAdamSessionCookie } from "../../_lib/adam-auth.js";

export function onRequestPost() {
  return Response.json({ ok: true }, {
    headers: {
      "Cache-Control": "no-store",
      "Set-Cookie": clearAdamSessionCookie(),
    },
  });
}
