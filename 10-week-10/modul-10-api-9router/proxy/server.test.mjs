import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createProxy,readConfig,sseEvents} from './server.mjs';
const config = {...readConfig(), key:'dummy-key-for-tests',model:'dummy-model'};
async function withProxy(t, upstream, override = {}) {
  const server = createProxy({...config,...override},upstream);
  await new Promise(resolve => server.listen(0,'127.0.0.1',resolve));
  t.after(() => {server.closeAllConnections();server.close();});
  return `http://127.0.0.1:${server.address().port}`;
}
const post = (url,payload,origin=config.origin) => fetch(url+'/chat',{
  method:'POST',headers:{'Content-Type':'application/json',Origin:origin},body:JSON.stringify(payload),
});
test('konfigurasi menolak HTTP nonlokal dan origin wildcard', () => {
  assert.throws(()=>readConfig({NINE_ROUTER_BASE_URL:'http://example.com/v1'}));
  assert.throws(()=>readConfig({APP_ORIGIN:'*'}));
});
test('SSE menerima Unicode terpotong, CRLF, komentar, dan DONE', async () => {
  const input = Buffer.from(': heartbeat\r\ndata: {"content":"☀"}\r\n\r\ndata: [DONE]\n\n');
  const body = (async function*(){for(const b of input)yield new Uint8Array([b]);})();
  const values=[];for await(const e of sseEvents(body))values.push(e);
  assert.deepEqual(values,['{"content":"☀"}','[DONE]']);
});
test('key hanya ditambahkan proxy dan model klien tidak mengambil alih',async t=>{
  const url=await withProxy(t,async(endpoint,request)=>{
    assert(endpoint.endsWith('/v1/chat/completions'));
    assert.equal(request.headers.Authorization,'Bearer dummy-key-for-tests');
    assert.equal(request.redirect,'error');
    const body=JSON.parse(request.body);
    assert.equal(body.model,'dummy-model');assert.equal(body.messages.length,2);
    assert.equal(body.messages[1].content,'Halo');
    return new Response('data: {"choices":[{"delta":{"content":"Halo ☀"}}]}\n\ndata: [DONE]\n\n', {headers:{'Content-Type':'text/event-stream'}});
  });
  const response=await post(url,{prompt:'Halo',model:'tidak-boleh-mengganti'});
  const body=await response.text();assert.equal(response.status,200);
  assert(body.includes('Halo ☀'));assert(body.includes('"done":true'));
  assert(!body.includes(config.key));
});
test('EOF tanpa DONE menghasilkan error setelah respons parsial',async t=>{
  const url=await withProxy(t,async()=>new Response('data: {"choices":[{"delta":{"content":"parsial"}}]}\n\n', {headers:{'Content-Type':'text/event-stream'}}));
  const text=await(await post(url,{prompt:'x'})).text();
  assert(text.includes('parsial'));assert(text.includes('"error"'));assert(!text.includes('"done":true'));
});
test('origin asing dan prompt kosong ditolak sebelum upstream',async t=>{
  let calls=0;const url=await withProxy(t,async()=>{calls++;return new Response('');});
  assert.equal((await post(url,{prompt:'x'},'https://example.com')).status,403);
  assert.equal((await post(url,{prompt:' '})).status,400);
  assert.equal(calls,0);
});
test('health menyatakan konfigurasi kosong tanpa menampilkan key',async t=>{
  const url=await withProxy(t,async()=>{throw Error('tidak boleh dipanggil');},{key:'',model:''});
  assert.deepEqual(await(await fetch(url+'/health')).json(),{ok:true,configured:false});
  assert.equal((await post(url,{prompt:'x'})).status,503);
});
test('error autentikasi tidak membocorkan body upstream',async t=>{
  const url=await withProxy(t,async()=>new Response('secret-dummy-upstream',{status:401}));
  const response=await post(url,{prompt:'x'});
  assert.equal(response.status,502);assert(!(await response.text()).includes('secret-dummy-upstream'));
});
