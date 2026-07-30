{{flutter_js}}
{{flutter_build_config}}

const lawrenceBuildVersion = "20260729-public-course-v2";

// Flutter keeps a stable `main.dart.js` filename. Version the entrypoint so a
// browser that ignored cache revalidation cannot keep an older application
// after the Docker image is replaced.
for (const build of _flutter.buildConfig.builds) {
  if (build.mainJsPath) {
    build.mainJsPath = `${build.mainJsPath}?v=${lawrenceBuildVersion}`;
  }
}

async function loadLawrence() {
  const versionKey = "lawrence-web-build";
  const previousVersion = localStorage.getItem(versionKey);

  if (previousVersion !== lawrenceBuildVersion) {
    localStorage.setItem(versionKey, lawrenceBuildVersion);

    if ("serviceWorker" in navigator) {
      const registrations = await navigator.serviceWorker.getRegistrations();
      await Promise.all(registrations.map((registration) => registration.unregister()));
    }

    if ("caches" in window) {
      const cacheNames = await caches.keys();
      await Promise.all(
        cacheNames
          .filter((name) => name.startsWith("flutter-"))
          .map((name) => caches.delete(name)),
      );
    }

    if (navigator.serviceWorker?.controller) {
      window.location.reload();
      return;
    }
  }

  _flutter.loader.load({
    config: {
      renderer: "canvaskit",
      useColorEmoji: true,
    },
  });
}

loadLawrence();
