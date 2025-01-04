'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"assets/assets/images/background.png": "a57b65a4081d9cd689716795085e3e54",
"assets/assets/images/Sword%2520Man/Attack1.png": "2ccd5b1efcf56f3c1e094264cc74fff9",
"assets/assets/images/Sword%2520Man/Attack2.png": "02a5fcc9a71695c2dc741ba2226eb4d0",
"assets/assets/images/Sword%2520Man/Get%2520Hit.png": "33f4156a9c399faec8fc4351b8c5d791",
"assets/assets/images/Sword%2520Man/Death.png": "97f629f5b9f8143551cedd54bcfef2ac",
"assets/assets/images/Sword%2520Man/Fall.png": "cea1a1cbce86b21166d8eb751e138914",
"assets/assets/images/Sword%2520Man/Attack.png": "0cd60aea7a28090ed60c047c56c99439",
"assets/assets/images/Sword%2520Man/Idle.png": "da637c3b3b2534702e995fda214abdda",
"assets/assets/images/Sword%2520Man/Run.png": "2946a34c781c0aebe6c765490e4cedb2",
"assets/assets/images/Sword%2520Man/Jump.png": "031bf680eb184b2f251ce04b97a3d7af",
"assets/assets/images/heart.png": "d84e72f8ddfb350e7bacb2fb829d0dcb",
"assets/assets/images/gameBackground.png": "edb6bee2ca2ba5dc77d114bed425d9a8",
"assets/assets/images/Enemies/Flying%2520eye/Take%2520Hit.png": "7bddad04c1dd7a84696a3e4874b6f945",
"assets/assets/images/Enemies/Flying%2520eye/Death.png": "4217101ba835fac4f879346ff76a07bc",
"assets/assets/images/Enemies/Flying%2520eye/Attack.png": "e1106fe653e8b41da7727eb9803a75eb",
"assets/assets/images/Enemies/Flying%2520eye/Flight.png": "fdddab58259f6be90b849d15442b744f",
"assets/assets/images/Enemies/Goblin/Take%2520Hit.png": "e26b702d3f3f4d109b98bfc47ae332c7",
"assets/assets/images/Enemies/Goblin/Death.png": "515438d4dbd3ba18294f34e319625aa1",
"assets/assets/images/Enemies/Goblin/Attack.png": "ea3ac52db0e71747b06976f297dc841c",
"assets/assets/images/Enemies/Goblin/Idle.png": "4d5f9de73b68ac2591b57cf0c8ab7126",
"assets/assets/images/Enemies/Goblin/Run.png": "addec75f47a658fead08f14da43983b3",
"assets/assets/images/Enemies/Mushroom/Take%2520Hit.png": "c3e33d503b39f746d4f95a6fdfbfa670",
"assets/assets/images/Enemies/Mushroom/Death.png": "a05da7ea014ed4320a0fa5384d786035",
"assets/assets/images/Enemies/Mushroom/Attack.png": "899a5d92d4a1790fdced14c68855f53c",
"assets/assets/images/Enemies/Mushroom/Idle.png": "4c8781aa227026f6ae7b299c31c478f5",
"assets/assets/images/Enemies/Mushroom/Run.png": "ff8dba64ffc3dc3925974514ab87333f",
"assets/assets/images/Enemies/Skeleton/Take%2520Hit.png": "7f72c713201c151c6a42c4469d4eaf99",
"assets/assets/images/Enemies/Skeleton/Death.png": "9706c79119fb2a53b66ed8cb40cb4dfa",
"assets/assets/images/Enemies/Skeleton/Attack.png": "d71cbed98afa0e56cdb149f093a24810",
"assets/assets/images/Enemies/Skeleton/Idle.png": "7533e38841f677c3b26efd998c370ae5",
"assets/assets/images/Enemies/Skeleton/Walk.png": "cc401ab1a57271cb3598cb44346603c0",
"assets/assets/images/Enemies/Skeleton/Shield.png": "7e9eb4fc87cfe6f617de16a33eddba39",
"assets/assets/images/Archer/Arrow/Static.png": "1f183170eb5b2faea1bd30741a4b6fdf",
"assets/assets/images/Archer/Arrow/Move.png": "397bca314b49244d4fab5769dee38a77",
"assets/assets/images/Archer/Character/Get%2520Hit.png": "1248349b273644f49d0e66db821cc96c",
"assets/assets/images/Archer/Character/DeathStatic.png": "9d307601387fac5f01a7b1d8249f4e49",
"assets/assets/images/Archer/Character/Death.png": "44c08ae8f523e01b817663fca97bd111",
"assets/assets/images/Archer/Character/Fall.png": "7b8e94b7058cf874540b3884595e91b8",
"assets/assets/images/Archer/Character/Attack.png": "fae7f4e44fdc899cbe070598099a5362",
"assets/assets/images/Archer/Character/Idle.png": "417f9d24968d7078c6dfa65bc76ea853",
"assets/assets/images/Archer/Character/Run.png": "091924fd5c2888bb206b267953308c78",
"assets/assets/images/Archer/Character/JumpAndFall.png": "f422d3204125ff76e39e5514ff0fb4d9",
"assets/assets/images/Archer/Character/Jump.png": "34b24de07aa55044bb8cd48d6a4da919",
"assets/assets/fonts/VINQUE.OTF": "5c612ee86f4d60d4000c4ba77e2e4328",
"assets/assets/audio/skeletonDeath.mp3": "1860e508eee7c6405f04b4dd6bed8090",
"assets/assets/audio/shield.mp3": "aa776b6059e01b1f7ba6be0c21899069",
"assets/assets/audio/skeletonDeath2.mp3": "a9fea3825c715718d205ccc1e92c45cc",
"assets/assets/audio/powerUp.mp3": "7b8d36cbf14a372e4c7cc6afaf00e218",
"assets/assets/audio/bgm.mp3": "6e99d2af8e1aa1ef96555ef37c9f5e75",
"assets/assets/audio/lose.mp3": "95b231965d62325ebcbe24edf53eff62",
"assets/assets/audio/flyingEyeDeath.mp3": "00eafc33257b857b1309e70827ff5709",
"assets/assets/audio/hurt.mp3": "6d006a8be94f1bcdfcfadb8dea146ffa",
"assets/assets/audio/monsterDeath.mp3": "ea93f00389127fcded1e550c6ca19e85",
"assets/assets/audio/death.mp3": "11c549253cf86e942e8d19fd09e00615",
"assets/assets/audio/win.mp3": "f6770e81732fb5ca80c374cf73c36c95",
"assets/assets/audio/arrow.mp3": "22457047798a79c3267e1007cafdeaa0",
"assets/assets/audio/running.mp3": "9132ef0c5c42a104e5cc348201d626a3",
"assets/assets/audio/mushroomDeath.mp3": "bd55be4e6a5859aa266ae8e3847d5a79",
"assets/AssetManifest.bin": "b834da228cd7ce0cd587adaea78ba5b1",
"assets/NOTICES": "e78f5e62b3fa03773bfe1b3bbd310a3a",
"assets/AssetManifest.json": "680d92b51c6f9d5766c3ccc2dcad2baf",
"assets/fonts/MaterialIcons-Regular.otf": "c353cfdebf45331ec24bff09ed0af05e",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/FontManifest.json": "04e44d9e05ff9e21abbe793664bd9262",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "a639202255d82874236d4dbe8d37cbfd",
"version.json": "e422da752c892f61bc7b993519a1ec27",
"manifest.json": "60a56e75b73dbd25d55e1ed8cf494217",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"index.html": "3d855dea757dc5fa5b78be853d12d1bb",
"/": "3d855dea757dc5fa5b78be853d12d1bb",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter_bootstrap.js": "47248089f1a0d62208b783d10db322d3",
"main.dart.js": "c6c4f7f614497697d65056998ba367b7"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
