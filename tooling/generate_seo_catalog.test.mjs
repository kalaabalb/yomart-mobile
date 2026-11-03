import assert from 'node:assert/strict';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { createServer } from 'node:http';
import { fileURLToPath } from 'node:url';
import test from 'node:test';
import { buildContactActions } from './generate_seo_catalog.mjs';

test('SEO contact actions include only valid configured business contacts', () => {
  assert.deepEqual(buildContactActions({ supportPhone: '+251 911 222 333', supportTelegram: '@yomart_store', supportInstagram: '@yomart.shop' }), [
    { label: 'Call YoMart', href: 'tel:+251 911 222 333' },
    { label: 'Telegram', href: 'https://t.me/yomart_store' },
    { label: 'Instagram', href: 'https://www.instagram.com/yomart.shop/' },
  ]);
  assert.deepEqual(buildContactActions({ supportPhone: 'javascript:alert(1)', supportTelegram: 'https://t.me/fake', supportInstagram: 'https://example.invalid' }), []);
});

const execFileAsync = promisify(execFile);
const generator = fileURLToPath(new URL('./generate_seo_catalog.mjs', import.meta.url));

test('generates escaped, canonical product pages and excludes unverified sample listings', async () => {
  const products = [
    {
      _id: '0123456789abcdef01234567',
      name: 'Samsung Galaxy S24 & Ultra',
      description: 'Premium phone <script>alert("x")</script> & features.',
      price: 64000,
      offerPrice: 60000,
      quantity: 3,
      isSearchVerified: true,
      proBrandId: { name: 'Samsung' },
      proCategoryId: { _id: '3123456789abcdef01234567', name: 'Phones & Tablets' },
      images: [{ image: 1, url: '/uploads/galaxy.webp' }],
    },
    {
      _id: '1123456789abcdef01234567',
      name: 'Illustrative phone listing',
      description: 'Reference listing, stock is unverified.',
      price: 1,
      quantity: 1,
      isSearchVerified: false,
      images: [],
    },
  ];
  const categories = [
    { _id: '3123456789abcdef01234567', name: 'Phones & Tablets', image: '/uploads/phones.webp' },
    { _id: '4123456789abcdef01234567', name: 'Empty Category', image: '' },
  ];
  const server = createServer((request, response) => {
    if (!['/products', '/categories', '/store-settings'].includes(request.url)) {
      response.writeHead(404).end();
      return;
    }
    response.writeHead(200, { 'content-type': 'application/json' });
    const data = request.url === '/products' ? products : request.url === '/categories' ? categories : {
      supportPhone: '+251911222333', supportTelegram: '@yomart_store', supportInstagram: '@yomart.shop',
    };
    response.end(JSON.stringify({ success: true, data }));
  });
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));

  const directory = await fs.mkdtemp(path.join(os.tmpdir(), 'yomart-seo-'));
  const port = server.address().port;
  try {
    await fs.writeFile(path.join(directory, 'index.html'), '<!doctype html><html><head><title>YoMart</title></head><body></body></html>');
    await fs.writeFile(path.join(directory, 'robots.txt'), 'User-agent: *\nAllow: /\n');
    await fs.writeFile(path.join(directory, 'yomart-build-config.json'), JSON.stringify({
      buildEnv: 'local',
      apiOrigin: `http://127.0.0.1:${port}`,
      privacyPolicyUrl: 'https://shop.example.test/privacy-policy.html',
      storefrontOrigin: 'https://shop.example.test',
    }));
    await execFileAsync(process.execPath, [generator], {
      env: {
        ...process.env,
        SEO_API_BASE_URL: `http://127.0.0.1:${port}`,
        SEO_SITE_ORIGIN: 'https://shop.example.test',
        SEO_OUTPUT_DIR: directory,
        SEO_ALLOW_LOCAL_URLS: 'true',
      },
    });

    const productDirectory = path.join(directory, 'products', 'samsung-galaxy-s24-ultra-0123456789abcdef01234567');
    const categoryDirectory = path.join(directory, 'categories', 'phones-tablets-3123456789abcdef01234567');
    const page = await fs.readFile(path.join(productDirectory, 'index.html'), 'utf8');
    const categoryPage = await fs.readFile(path.join(categoryDirectory, 'index.html'), 'utf8');
    const sitemap = await fs.readFile(path.join(directory, 'sitemap.xml'), 'utf8');
    const robots = await fs.readFile(path.join(directory, 'robots.txt'), 'utf8');
    const rootHtml = await fs.readFile(path.join(directory, 'index.html'), 'utf8');

    assert.match(rootHtml, /<link rel="canonical" href="https:\/\/shop\.example\.test\/">/);
    assert.match(page, /<h1>Samsung Galaxy S24 &amp; Ultra<\/h1>/);
    assert.match(page, /&lt;script&gt;alert\(&quot;x&quot;\)&lt;\/script&gt; &amp; features\./);
    assert.match(page, /"priceCurrency":"ETB"/);
    assert.match(page, /https:\/\/schema\.org\/InStock/);
    const schemaScript = page.match(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/);
    assert.ok(schemaScript, 'product page includes structured data');
    const structuredProduct = JSON.parse(schemaScript[1]);
    assert.equal(structuredProduct['@type'], 'Product');
    assert.equal(structuredProduct.offers.price, '60000.00');
    assert.equal(structuredProduct.brand.name, 'Samsung');
    assert.equal('aggregateRating' in structuredProduct, false);
    assert.match(page, /https:\/\/shop\.example\.test\/products\/samsung-galaxy-s24-ultra-0123456789abcdef01234567\//);
    assert.match(page, /href="https:\/\/shop\.example\.test\/categories\/phones-tablets-3123456789abcdef01234567\/"/);
    assert.match(page, /href="tel:\+251911222333">Call YoMart/);
    assert.match(page, /href="https:\/\/t\.me\/yomart_store"/);
    assert.match(page, /href="https:\/\/www\.instagram\.com\/yomart\.shop\/"/);
    assert.match(categoryPage, /<h1>Phones &amp; Tablets<\/h1>/);
    assert.match(categoryPage, /"@type":"CollectionPage"/);
    assert.match(categoryPage, /Samsung Galaxy S24 &amp; Ultra/);
    assert.doesNotMatch(categoryPage, /Illustrative phone listing/);
    const emptyCategoryPage = await fs.readFile(path.join(directory, 'categories', 'empty-category-4123456789abcdef01234567', 'index.html'), 'utf8');
    assert.match(emptyCategoryPage, /No verified products are currently listed in this category/);
    assert.doesNotMatch(emptyCategoryPage, /Birr [0-9]/);
    assert.match(sitemap, /https:\/\/shop\.example\.test\/categories\/phones-tablets-3123456789abcdef01234567\//);
    assert.match(sitemap, /https:\/\/shop\.example\.test\/products\/samsung-galaxy-s24-ultra-0123456789abcdef01234567\//);
    assert.doesNotMatch(sitemap, /illustrative-phone-listing/);
    assert.match(robots, /Sitemap: https:\/\/shop\.example\.test\/sitemap\.xml/);

    await assert.rejects(
      execFileAsync(process.execPath, [generator], {
        env: {
          ...process.env,
          SEO_API_BASE_URL: 'https://wrong-api.stage.test',
          SEO_SITE_ORIGIN: 'https://shop.example.test',
          SEO_OUTPUT_DIR: directory,
        },
      }),
      /SEO_API_BASE_URL does not match the API origin used for this Flutter web build/,
    );
    assert.equal(await fs.readFile(path.join(directory, 'sitemap.xml'), 'utf8'), sitemap);

    await assert.rejects(
      execFileAsync(process.execPath, [generator], {
        env: {
          ...process.env,
          SEO_API_BASE_URL: `http://127.0.0.1:${port}`,
          SEO_SITE_ORIGIN: 'https://wrong-store.stage.test',
          SEO_OUTPUT_DIR: directory,
          SEO_ALLOW_LOCAL_URLS: 'true',
        },
      }),
      /SEO_SITE_ORIGIN does not match the web origin used for the privacy-policy build URL/,
    );
    assert.equal(await fs.readFile(path.join(directory, 'sitemap.xml'), 'utf8'), sitemap);

    products.splice(0, products.length, {
      _id: '2123456789abcdef01234567',
      name: 'Unverified product',
      price: 100,
      quantity: 1,
      isSearchVerified: false,
    });
    await assert.rejects(
      execFileAsync(process.execPath, [generator], {
        env: {
          ...process.env,
          SEO_API_BASE_URL: `http://127.0.0.1:${port}`,
          SEO_SITE_ORIGIN: 'https://shop.example.test',
          SEO_OUTPUT_DIR: directory,
          SEO_ALLOW_LOCAL_URLS: 'true',
        },
      }),
      /No valid public products were returned/,
    );
    assert.equal(await fs.readFile(path.join(directory, 'sitemap.xml'), 'utf8'), sitemap);
    assert.equal(await fs.readFile(path.join(directory, 'robots.txt'), 'utf8'), robots);

    // Exercise the staging policy only against the in-process synthetic API
    // fixture; this never contacts a staging or production service.
    products.splice(0, products.length, {
      _id: '5123456789abcdef01234567',
      name: 'Synthetic staging phone',
      description: 'Synthetic fixture listing.',
      price: 100,
      quantity: 1,
      isSearchVerified: true,
      proCategoryId: { _id: '3123456789abcdef01234567', name: 'Phones & Tablets' },
      images: [],
    });
    await fs.writeFile(path.join(directory, 'yomart-build-config.json'), JSON.stringify({
      buildEnv: 'staging',
      apiOrigin: `http://127.0.0.1:${port}`,
      privacyPolicyUrl: 'https://shop.example.test/privacy-policy.html',
      storefrontOrigin: 'https://shop.example.test',
    }));
    await execFileAsync(process.execPath, [generator], {
      env: {
        ...process.env,
        SEO_API_BASE_URL: `http://127.0.0.1:${port}`,
        SEO_SITE_ORIGIN: 'https://shop.example.test',
        SEO_OUTPUT_DIR: directory,
        SEO_ALLOW_LOCAL_URLS: 'true',
      },
    });
    const stagingIndex = await fs.readFile(path.join(directory, 'index.html'), 'utf8');
    const stagingProduct = await fs.readFile(path.join(directory, 'products', 'synthetic-staging-phone-5123456789abcdef01234567', 'index.html'), 'utf8');
    const stagingCategory = await fs.readFile(path.join(directory, 'categories', 'phones-tablets-3123456789abcdef01234567', 'index.html'), 'utf8');
    const stagingRobots = await fs.readFile(path.join(directory, 'robots.txt'), 'utf8');
    for (const html of [stagingIndex, stagingProduct, stagingCategory]) {
      assert.equal((html.match(/name="robots"/g) || []).length, 1);
      assert.match(html, /name="robots" content="noindex,nofollow,noarchive"/);
      assert.doesNotMatch(html, /name="robots" content="index,follow/);
    }
    assert.equal(stagingRobots, 'User-agent: *\nAllow: /\n');
    await assert.rejects(fs.access(path.join(directory, 'sitemap.xml')));
  } finally {
    await new Promise((resolve, reject) => server.close((error) => error ? reject(error) : resolve()));
    await fs.rm(directory, { recursive: true, force: true });
  }
});
