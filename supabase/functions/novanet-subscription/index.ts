import { createClient } from 'npm:@supabase/supabase-js@2'

const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SECRET_KEY')!)
const headers = {
  'access-control-allow-origin': '*',
  'access-control-allow-methods': 'GET, OPTIONS',
  'access-control-allow-headers': 'x-novanet-token, content-type',
  'content-type': 'application/json; charset=utf-8',
}

async function sha256(value: string) {
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(value))
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, '0')).join('')
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers })
  if (req.method !== 'GET') return new Response(JSON.stringify({ error: 'method_not_allowed' }), { status: 405, headers })
  const token = req.headers.get('x-novanet-token') ?? new URL(req.url).searchParams.get('token') ?? ''
  if (token.length < 24) return new Response(JSON.stringify({ error: 'invalid_token' }), { status: 401, headers })
  const { data, error } = await supabase.from('novanet_subscriptions').select('name,description,traffic_used_mb,traffic_limit_mb,version,expires_at,profiles,updated_at').eq('access_token_hash', await sha256(token)).maybeSingle()
  if (error) return new Response(JSON.stringify({ error: 'database_error' }), { status: 500, headers })
  if (!data) return new Response(JSON.stringify({ error: 'not_found' }), { status: 404, headers })
  if (data.expires_at && new Date(data.expires_at).getTime() <= Date.now()) return new Response(JSON.stringify({ error: 'expired' }), { status: 410, headers })
  return new Response(JSON.stringify({ subscriptionName: data.name, description: data.description, trafficUsedMb: data.traffic_used_mb, trafficLimitMb: data.traffic_limit_mb, version: data.version, updatedAt: data.updated_at, profiles: data.profiles }), { headers })
})
