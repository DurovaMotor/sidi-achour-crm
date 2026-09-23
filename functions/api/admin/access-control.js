import { loadAccessControlSettings } from "../../_lib/access-control.js";
import { readAdamSession, unauthorizedResponse } from "../../_lib/adam-auth.js";

async function isAdam(context) {
  return Boolean(await readAdamSession(context.request, context.env.ADAM_SESSION_SECRET));
}

export async function onRequestGet(context) {
  if (!await isAdam(context)) return unauthorizedResponse();
  return Response.json(await loadAccessControlSettings(context.env.DB), {
    headers: { "Cache-Control": "no-store" },
  });
}

export async function onRequestPatch(context) {
  if (!await isAdam(context)) return unauthorizedResponse();
  const body = await context.request.json();
  await context.env.DB.prepare(`
    UPDATE access_control_settings
    SET
      enabled = ?,
      block_chinese_language = ?,
      block_china_timezone = ?,
      block_china_ip = ?,
      product_image_blur_px = ?,
      show_all_french_specifications = ?,
      updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
    WHERE id = 1
  `).bind(
    Number(body.enabled === true),
    Number(body.blockChineseLanguage === true),
    Number(body.blockChinaTimezone === true),
    Number(body.blockChinaIp === true),
    Number(body.productImageBlurPx),
    Number(body.showAllFrenchSpecifications === true),
  ).run();
  return Response.json(await loadAccessControlSettings(context.env.DB), {
    headers: { "Cache-Control": "no-store" },
  });
}
