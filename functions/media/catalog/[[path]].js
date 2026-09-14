export function onRequest(context) {
  const value = context.params.path;
  const segments = Array.isArray(value) ? value : [value];
  const requestedFile = segments.at(-1) ?? "";
  if (!requestedFile.endsWith(".bin")) {
    return new Response("Not found", {
      status: 404,
      headers: {
        "Cache-Control": "no-store",
        "Content-Type": "text/plain; charset=utf-8",
        "X-Content-Type-Options": "nosniff",
        "X-Robots-Tag": "noindex, noarchive",
      },
    });
  }
  return context.next();
}
