// Replaces legacy Flutter service workers that cached the complete app shell.
// The current Lawrence build does not register a service worker.
self.addEventListener("install", () => self.skipWaiting());

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((names) => Promise.all(names.map((name) => caches.delete(name))))
      .then(() => self.registration.unregister())
      .then(() => self.clients.matchAll({ type: "window" }))
      .then((clients) =>
        Promise.all(clients.map((client) => client.navigate(client.url))),
      ),
  );
});

self.addEventListener("fetch", (event) => {
  event.respondWith(fetch(event.request));
});
