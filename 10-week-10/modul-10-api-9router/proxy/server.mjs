import http from 'node:http';
import {pathToFileURL} from 'node:url';

export function readConfig(env = process.env) {
  const port = Number(env.PROXY_PORT || 8787);
  if (!Number.isInteger(port) || port < 1 || port > 65535) throw Error('PROXY_PORT tidak valid.');
  const origin = env.APP_ORIGIN || 'http://127.0.0.1:7081';
  const ui = new URL(origin);
  if (!['127.0.0.1', 'localhost'].includes(ui.hostname) || ui.origin !== origin) throw Error('APP_ORIGIN harus berupa origin loopback yang tepat.');
  const base = new URL(env.NINE_ROUTER_BASE_URL || 'http://127.0.0.1:20128/v1');
  if (base.username || base.password || base.search || base.hash ||
      !(base.protocol === 'https:' || (base.protocol === 'http:' && ['127.0.0.1', 'localhost'].includes(base.hostname)))) {
    throw Error('Base URL harus HTTPS atau HTTP loopback, tanpa kredensial dan query.');
  }
  return {
    port, origin, endpoint: `${base.href.replace(/\/$/, '')}/chat/completions`,
    key: env.NINE_ROUTER_API_KEY || '', model: env.NINE_ROUTER_MODEL || '',
  };
}

// SSE dapat terpotong pada batas paket dan dapat membawa beberapa baris data.
export async function* sseEvents(body) {
  const decoder = new TextDecoder();
  let buffer = ''; let data = [];
  const line = value => {
    if (value === '') { const event = data.join('\n'); data = []; return event || null; }
    if (value.startsWith('data:')) data.push(value.slice(5).replace(/^ /, ''));
    return null;
  };
  for await (const bytes of body) {
    buffer += decoder.decode(bytes, {stream: true});
    if (buffer.length > 262144) throw Error('SSE event terlalu besar.');
    let pos;
    while ((pos = buffer.indexOf('\n')) !== -1) {
      const event = line(buffer.slice(0, pos).replace(/\r$/, ''));
      buffer = buffer.slice(pos + 1);
      if (event !== null) yield event;
    }
  }
  buffer += decoder.decode();
  if (buffer) line(buffer.replace(/\r$/, ''));
  if (data.length) yield data.join('\n');
}

export function createProxy(config, fetcher = fetch) {
  let active = false;
  return http.createServer(async (req, res) => {
    const json = (status, value) => {
      res.writeHead(status, {'Content-Type': 'application/json; charset=utf-8'});
      res.end(JSON.stringify(value));
    };
    const host = (req.headers.host || '').split(':')[0];
    if (!['127.0.0.1', 'localhost'].includes(host)) return json(403, {error:'Host tidak diizinkan.'});
    const origin = req.headers.origin;
    res.setHeader('Vary', 'Origin');
    res.setHeader('Cache-Control', 'no-store');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    if (origin && origin !== config.origin) return json(403, {error:'Origin tidak diizinkan.'});
    if (origin) res.setHeader('Access-Control-Allow-Origin', config.origin);
    if (req.method === 'OPTIONS' && req.url === '/chat') {
      res.writeHead(204, {'Access-Control-Allow-Methods':'POST, OPTIONS','Access-Control-Allow-Headers':'Content-Type'});
      return res.end();
    }
    if (req.method === 'GET' && req.url === '/health') return json(200, {ok:true, configured:Boolean(config.key && config.model)});
    if (req.method !== 'POST' || req.url !== '/chat') return json(404, {error:'Rute tidak ditemukan.'});
    if (!config.key || !config.model) return json(503, {error:'Isi API key dan model pada konfigurasi proxy.'});
    if (!req.headers['content-type']?.startsWith('application/json')) return json(415, {error:'Gunakan application/json.'});
    if (active) return json(429, {error:'Satu permintaan sedang berjalan. Tunggu hingga selesai.'});
    active = true;
    const abort = new AbortController();
    const deadline = setTimeout(() => abort.abort(), 90000);
    req.on('aborted', () => abort.abort());
    res.on('close', () => { if (!res.writableEnded) abort.abort(); });
    try {
      const chunks = []; let bytes = 0;
      for await (const chunk of req) {
        bytes += chunk.length;
        if (bytes > 20000) { json(413, {error:'Input terlalu besar.'}); return; }
        chunks.push(chunk);
      }
      let input;
      try { input = JSON.parse(Buffer.concat(chunks).toString('utf8')); } catch { json(400,{error:'JSON tidak valid.'}); return; }
      const prompt = input?.prompt;
      if (typeof prompt !== 'string' || !prompt.trim() || prompt.length > 4000) {
        json(400, {error:'Pertanyaan harus berisi 1–4000 karakter.'}); return;
      }
      const upstream = await fetcher(config.endpoint, {
        method:'POST', redirect:'error', signal:abort.signal,
        headers:{'Content-Type':'application/json', Authorization:`Bearer ${config.key}`},
        body:JSON.stringify({model:config.model, stream:true, max_tokens:256,
          messages:[
            {role:'system', content:'Anda asisten belajar Flutter. Jawab ringkas dalam bahasa Indonesia. Nyatakan ketidakpastian dan jangan mengklaim telah menjalankan kode.'},
            {role:'user', content:prompt},
          ]}),
      });
      if (!upstream.ok) {
        // Jangan teruskan body error upstream yang mungkin memuat kredensial.
        const status = upstream.status;
        await upstream.body?.cancel();
        json(status === 429 ? 429 : 502, {error:status === 401 || status === 403
          ? '9router menolak autentikasi. Periksa API key pada proxy.'
          : status === 429 ? 'Kuota atau batas layanan tercapai.'
          : '9router menolak permintaan. Periksa model, endpoint, dan status layanan.'});
        return;
      }
      if (!upstream.headers.get('content-type')?.includes('text/event-stream') || !upstream.body) {
        await upstream.body?.cancel();
        json(502, {error:'Endpoint harus mendukung Chat Completions streaming SSE.'}); return;
      }
      res.writeHead(200, {'Content-Type':'application/x-ndjson; charset=utf-8'});
      let done = false; let size = 0; let contentSeen = false;
      for await (const event of sseEvents(upstream.body)) {
        if (event === '[DONE]') { done = true; break; }
        const value = JSON.parse(event);
        if (value.error) throw Error('Upstream stream error.');
        const text = value.choices?.[0]?.delta?.content;
        if (text !== undefined && text !== null && typeof text !== 'string') throw Error('Konten nonteks.');
        if (text) {
          size += text.length;
          if (size > 32000) throw Error('Output terlalu panjang.');
          contentSeen = true;
          res.write(JSON.stringify({text}) + '\n');
        }
      }
      if (!done || !contentSeen) throw Error('Stream tidak lengkap atau kosong.');
      res.end(JSON.stringify({done:true})+'\n');
    } catch {
      const error = {error:'Koneksi API gagal, melewati 90 detik, atau stream tidak lengkap.'};
      if (!res.destroyed) {
        if (res.headersSent) res.end(JSON.stringify(error)+'\n');
        else json(502,error);
      }
    } finally {
      clearTimeout(deadline);
      abort.abort();
      active = false;
    }
  });
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const config = readConfig();
  const server = createProxy(config);
  server.requestTimeout = 100000;
  server.headersTimeout = 15000;
  server.listen(config.port,'127.0.0.1',() => {
    console.log(`Proxy dosen: http://127.0.0.1:${config.port}. Key dan prompt tidak dicetak.`);
    if (!config.key || !config.model) console.log('Konfigurasi belum lengkap. Isi NINE_ROUTER_API_KEY dan NINE_ROUTER_MODEL.');
  });
}
