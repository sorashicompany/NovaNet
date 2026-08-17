interface Env {
  SUPABASE_FUNCTION_URL: string
}

function tokenKey(token: string) {
  // Do not put the raw subscription token into a cache key or URL.
  return crypto.subtle.digest('SHA-256', new TextEncoder().encode(token)).then((buf) =>
    [...new Uint8Array(buf)].map((b) => b.toString(16).padStart(2, '0')).join('')
  )
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url)
    if (url.pathname !== '/subscription') return new Response('Not found', { status: 404 })
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: {
        'access-control-allow-origin': '*',
        'access-control-allow-methods': 'GET, OPTIONS',
        'access-control-allow-headers': 'x-novanet-token'
      }})
    }
    if (request.method !== 'GET') return new Response('Method not allowed', { status: 405 })

    const token = request.headers.get('x-novanet-token') ?? url.searchParams.get('token') ?? ''
    if (token.length < 24) return new Response(JSON.stringify({ error: 'invalid_token' }), { status: 401 })

    const key = await tokenKey(token)
    const cache = caches.default
    const cacheRequest = new Request(`https://${url.hostname}/subscription/${key}`)
    let response = await cache.match(cacheRequest)
    if (!response) {
      response = await fetch(env.SUPABASE_FUNCTION_URL, {
        headers: { 'x-novanet-token': token, accept: 'application/json' },
      })
      response = new Response(response.body, response)
      if (response.ok) {
        response.headers.set('Cache-Control', 's-maxage=30, max-age=0')
        ctx.waitUntil(cache.put(cacheRequest, response.clone()))
      }
    }

    const out = new Response(response.body, response)
    out.headers.set('access-control-allow-origin', '*')
    out.headers.set('content-type', 'application/json; charset=utf-8')
    return out
  },
} satisfies ExportedHandler<Env>
