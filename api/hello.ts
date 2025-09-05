// File: api/proxy.ts

import type { VercelRequest, VercelResponse } from '@vercel/node';

const SANITIZED_HEADERS = new Set([
  'host',
  'content-length',
  'cookie',
  'origin',
  'referer',
  'accept-encoding',
]);

export default async function handler(req: VercelRequest, res: VercelResponse) {
  // Add CORS headers first to handle preflight requests immediately
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', '*');

  // Handle preflight (OPTIONS) request
  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  const { url } = req.query;
  if (!url || typeof url !== 'string') {
    return res.status(400).json({ error: "Missing or invalid '?url=' query parameter" });
  }

  let targetUrl: URL;
  try {
    targetUrl = new URL(url);
  } catch {
    return res.status(400).json({ error: 'Invalid URL' });
  }

  // Build sanitized headers
  const headers: Record<string, string> = {};
  for (const [key, value] of Object.entries(req.headers)) {
    if (value && !SANITIZED_HEADERS.has(key.toLowerCase())) {
      headers[key] = Array.isArray(value) ? value.join(',') : value;
    }
  }

  // Ensure a minimal User-Agent is set
  if (!headers['user-agent']) {
    headers['user-agent'] = 'Mozilla/5.0';
  }

  try {
    const response = await fetch(targetUrl.toString(), {
      method: req.method,
      headers,
      body: req.method !== 'GET' && req.method !== 'HEAD' ? req.body : undefined,
      redirect: 'manual',
    });

    // Copy response headers
    response.headers.forEach((value, key) => {
      if (!['content-encoding', 'content-length', 'transfer-encoding', 'connection'].includes(key.toLowerCase())) {
        res.setHeader(key, value);
      }
    });

    // Read the response body as a buffer
    const body = await response.arrayBuffer();

    // Set the content type from the original response or default
    const contentType = response.headers.get('content-type') || 'application/octet-stream';
    res.setHeader('Content-Type', contentType);

    // Send the buffered body with the status code
    return res.status(response.status).send(Buffer.from(body));
  } catch (err) {
    const errorMessage = err instanceof Error ? err.message : 'An unknown error occurred.';
    return res.status(500).json({ error: 'Proxy failed', details: errorMessage });
  }
}
