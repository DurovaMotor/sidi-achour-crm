import {
  adamSessionCookie,
  createAdamSession,
  verifyAdamPassword,
} from "../../_lib/adam-auth.js";

function loginError() {
  return Response.json({ error: "账号或密码不正确" }, {
    status: 401,
    headers: { "Cache-Control": "no-store" },
  });
}

export async function onRequestPost(context) {
  if (!context.env.ADAM_SESSION_SECRET) {
    return Response.json({ error: "登录服务尚未配置" }, {
      status: 503,
      headers: { "Cache-Control": "no-store" },
    });
  }

  let body;
  try {
    body = await context.request.json();
  } catch {
    return loginError();
  }

  const username = String(body.username ?? "").trim();
  const password = String(body.password ?? "");
  if (!username || !password || username.length > 64 || password.length > 128) return loginError();

  const account = await context.env.DB.prepare(`
    SELECT username, password_salt, password_hash, password_iterations
    FROM admin_users
    WHERE username = ? AND active = 1
    LIMIT 1
  `).bind(username).first();
  if (!account || !await verifyAdamPassword(password, account)) return loginError();

  const token = await createAdamSession(context.env.ADAM_SESSION_SECRET);
  return Response.json({ ok: true, redirect: "/Adam" }, {
    headers: {
      "Cache-Control": "no-store",
      "Set-Cookie": adamSessionCookie(token),
    },
  });
}
