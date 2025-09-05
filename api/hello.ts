import type { NextRequest, NextResponse } from 'next/server';

const SANITIZED_HEADERS = [
  'host',
  'content-length',
  'cookie',
  'origin',
  'referer',
  'accept-encoding',
];

export const config = {
  runtime: 'edge', // Ensure the Edge Runtime is used for better performance
};

export default async function handler(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const url = searchParams.get('url');

  if (!url) {
    return NextResponse.json({ error: "Missing ?url=" }, { status: 400 });
  }

  let targetUrl: URL;
  try {
    targetUrl = new URL(url);
  } catch {
    return NextResponse.json({ error: "Invalid URL" }, { status: 400 });
  }

  // Build sanitized headers
  const headers = new Headers();
  req.headers.forEach((value, key) => {
    if (!SANITIZED_HEADERS.includes(key.toLowerCase())) {
      headers.set(key, value);
    }
  });

  // Minimal User-Agent
  if (!headers.has('user-agent')) {
    headers.set('user-agent', 'Mozilla/5.0');
  }
  
  try {
    const response = await fetch(targetUrl.toString(), {
      method: req.method,
      headers: headers,
      body: req.method !== 'GET' && req.method !== 'HEAD' ? req.body : null,
      redirect: 'manual',
    });

    // Create a new response with the proxied data
    const newResponse = new NextResponse(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers: new Headers(),
    });

    // Copy original headers, excluding problematic ones
    response.headers.forEach((value, key) => {
      if (!['content-encoding', 'content-length', 'transfer-encoding', 'connection'].includes(key.toLowerCase())) {
        newResponse.headers.set(key, value);
      }
    });

    // Add CORS headers
    newResponse.headers.set('Access-Control-Allow-Origin', '*');
    newResponse.headers.set('Access-Control-Allow-Methods', 'GET,POST,PUT,PATCH,DELETE,OPTIONS');
    newResponse.headers.set('Access-Control-Allow-Headers', '*');

    // Handle preflight requests
    if (req.method === 'OPTIONS') {
      return new NextResponse(null, { status: 204, headers: newResponse.headers });
    }

    return newResponse;

  } catch (err: any) {
    return NextResponse.json({ error: "Proxy failed", details: err.message }, { status: 500 });
  }
}
