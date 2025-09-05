import type { VercelRequest, VercelResponse } from '@vercel/node';

const SANITIZED_HEADERS = [
  'host',
  'content-length',
  'cookie',
  'origin',
  'referer',
  'accept-encoding', // let node-fetch handle encoding
];

export default async function handler(req: VercelRequest, res: VercelResponse) {
  const url = req.query.url as string;
  if (!url) return res.status(400).json({ error: "Missing ?url=" });

  let targetUrl: URL;
  try {
    targetUrl = new URL(url);
  } catch {
    return res.status(400).json({ error: "Invalid URL" });
  }

  // Build sanitized headers
  const headers: Record<string, string> = {};
  for (const [key, value] of Object.entries(req.headers)) {
    if (value && !SANITIZED_HEADERS.includes(key.toLowerCase())) {
      headers[key] = Array.isArray(value) ? value.join(',') : value;
    }
  }

  // Minimal User-Agent
  if (!headers['user-agent']) headers['user-agent'] = 'Mozilla/5.0';

  try {
    const response = await fetch(targetUrl.toString(), {
      method: req.method,
      headers,
      body: req.method !== 'GET' && req.method !== 'HEAD' ? req.body : undefined,
      redirect: 'manual',
    });

    // Copy response headers (excluding problematic ones)
    response.headers.forEach((value, key) => {
      if (!['content-encoding', 'content-length', 'transfer-encoding', 'connection'].includes(key.toLowerCase())) {
        res.setHeader(key, value);
      }
    });

    // Add CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,PATCH,DELETE,OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', '*');

    // Handle preflight
    if (req.method === 'OPTIONS') return res.status(204).send('');

    const contentType = response.headers.get('content-type') || 'text/html';
    const body = await response.arrayBuffer();

    res.setHeader('Content-Type', contentType);
    res.status(response.status).send(Buffer.from(body));
  } catch (err) {
    res.status(500).json({ error: "Proxy failed", details: (err as Error).message });
  }
}
