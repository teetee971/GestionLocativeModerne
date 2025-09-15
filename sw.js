self.addEventListener('install', e => self.skipWaiting());
self.addEventListener('activate', e => clients.claim());
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  e.respondWith(caches.open('homygo-v1').then(async c => {
    const r = await c.match(e.request);
    if (r) return r;
    const f = await fetch(e.request);
    c.put(e.request, f.clone());
    return f;
  }));
});
