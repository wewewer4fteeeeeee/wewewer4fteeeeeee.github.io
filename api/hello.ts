import type { VercelRequest, VercelResponse } from '@vercel/node';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  const url = req.query.url as string;
  if (!url) return res.status(400).json({ error: "Missing ?url=" });

  try {
    const response = await fetch(url, {
      method: req.method,
      headers: {
        ...req.headers,
        host: new URL(url).host
      },
    });

    const contentType = response.headers.get("content-type") || "text/html";
    const body = await response.text();

    res.setHeader("Content-Type", contentType);
    res.status(response.status).send(body);
  } catch (err) {
    res.status(500).json({ error: "Proxy failed", details: (err as Error).message });
  }
}
