#!/usr/bin/env node

import fs from 'node:fs/promises';
import path from 'node:path';
import process from 'node:process';
import { pathToFileURL } from 'node:url';

const apiBase = process.env.SEO_API_BASE_URL;
const siteOrigin = process.env.SEO_SITE_ORIGIN;
const outputDirectory = path.resolve(process.env.SEO_OUTPUT_DIR || 'build/web');
const allowLocal = process.env.SEO_ALLOW_LOCAL_URLS === 'true';

function requiredUrl(value, name) {
  if (!value) throw new Error(`${name} is required.`);
  let parsed;
  try {
    parsed = new URL(value);
  } catch {
    throw new Error(`${name} must be an absolute URL.`);
  }
  const local = ['localhost', '127.0.0.1', '::1'].includes(parsed.hostname);
  if (parsed.protocol !== 'https:' && !(local && allowLocal && parsed.protocol === 'http:')) {
    throw new Error(`${name} must use HTTPS. HTTP is allowed for localhost only with SEO_ALLOW_LOCAL_URLS=true.`);
  }
  return parsed;
}

export function slugify(value) {
  return String(value || '')
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 80) || 'product';
}

export function escapeHtml(value) {
  return String(value ?? '').replace(/[&<>"']/g, (character) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
  })[character]);
}

function safeImageUrl(value, apiUrl) {
  if (typeof value !== 'string' || !value.trim()) return null;
  try {
    const url = new URL(value, apiUrl);
    const isLocalApi = ['localhost', '127.0.0.1', '::1'].includes(apiUrl.hostname);
    return url.protocol === 'https:' || (url.protocol === 'http:' && isLocalApi && allowLocal)
      ? url.href
      : null;
  } catch {
    return null;
  }
}

function shortDescription(value, name) {
  const clean = String(value || '').replace(/\s+/g, ' ').trim();
  const result = clean || `View ${name} on YoMart. Check current price and availability in the store.`;
  return result.length > 300 ? `${result.slice(0, 297).trimEnd()}…` : result;
}

function productPath(product) {
  const id = String(product._id || product.id || '');
  if (!/^[a-f\d]{24}$/i.test(id)) return null;
  return `/products/${slugify(product.name)}-${id.toLowerCase()}/`;
}

function catalogId(value) {
  const id = String(value?._id || value?.id || value || '');
  return /^[a-f\d]{24}$/i.test(id) ? id.toLowerCase() : null;
}

function categoryPath(category) {
  const id = catalogId(category);
  const name = String(category?.name || '').trim();
  return id && name ? `/categories/${slugify(name)}-${id}/` : null;
}

function isCatalogVerified(product) {
  return product.isSearchVerified === true;
}

export function buildContactActions(settings = {}) {
  const actions = [];
  const phone = String(settings.supportPhone || '').trim();
  if (/^\+?[0-9().\-\s]{5,40}$/.test(phone) && phone.replace(/\D/g, '').length >= 5) {
    actions.push({ label: 'Call YoMart', href: `tel:${phone}` });
  }
  const telegram = String(settings.supportTelegram || '').trim().replace(/^@/, '');
  if (/^[A-Za-z0-9_]{5,32}$/.test(telegram)) actions.push({ label: 'Telegram', href: `https://t.me/${telegram}` });
  const instagram = String(settings.supportInstagram || '').trim().replace(/^@/, '');
  if (/^[A-Za-z0-9._]{1,30}$/.test(instagram)) actions.push({ label: 'Instagram', href: `https://www.instagram.com/${instagram}/` });
  return actions;
}

const STAGING_ROBOTS_DIRECTIVE = 'noindex,nofollow,noarchive';
const ROBOTS_META_PATTERN = /<meta\b(?=[^>]*\bname\s*=\s*['"]robots['"])[^>]*>/gi;

function setRobotsDirective(html, directive) {
  const meta = `<meta name="robots" content="${directive}">`;
  return html.replace(ROBOTS_META_PATTERN, '').replace(/<\/head\s*>/i, `${meta}\n</head>`);
}

function buildProductHtml(product, { siteUrl, apiUrl, contactActions = [], robotsDirective = 'index,follow,max-image-preview:large' }) {
  const name = String(product.name || '').trim();
  const route = productPath(product);
  if (!name || !route) return null;

  const url = new URL(route, siteUrl).href;
  const description = shortDescription(product.description, name);
  const primaryPrice = Number(product.offerPrice) > 0 && Number(product.offerPrice) < Number(product.price)
    ? Number(product.offerPrice)
    : Number(product.price);
  const hasPrice = Number.isFinite(primaryPrice) && primaryPrice > 0;
  const inStock = Number(product.quantity) > 0;
  const images = (Array.isArray(product.images) ? product.images : [])
    .map((entry) => safeImageUrl(entry?.url, apiUrl))
    .filter(Boolean);
  const brandName = typeof product.proBrandId === 'object' ? product.proBrandId?.name : null;
  const categoryName = typeof product.proCategoryId === 'object' ? product.proCategoryId?.name : null;
  const categoryUrlPath = categoryPath(product.proCategoryId);
  const categoryUrl = categoryUrlPath ? new URL(categoryUrlPath, siteUrl).href : null;
  const schema = {
    '@context': 'https://schema.org',
    '@type': 'Product',
    name,
    description,
    ...(brandName ? { brand: { '@type': 'Brand', name: brandName } } : {}),
    ...(categoryName ? { category: categoryName } : {}),
    ...(images.length ? { image: images } : {}),
    ...(hasPrice ? {
      offers: {
        '@type': 'Offer',
        url,
        priceCurrency: 'ETB',
        price: primaryPrice.toFixed(2),
        availability: `https://schema.org/${inStock ? 'InStock' : 'OutOfStock'}`,
        itemCondition: 'https://schema.org/NewCondition',
      },
    } : {}),
  };
  const jsonLd = JSON.stringify(schema).replace(/</g, '\\u003c');
  const priceText = hasPrice ? `Birr ${new Intl.NumberFormat('en-ET', { maximumFractionDigits: 2 }).format(primaryPrice)}` : 'Check price in store';
  const stockText = inStock ? 'Available' : 'Currently out of stock';
  const gallery = images.map((image, index) =>
    `<img src="${escapeHtml(image)}" alt="${escapeHtml(name)}${index ? ` — image ${index + 1}` : ''}"${index ? ' loading="lazy"' : ''}>`,
  ).join('\n');

  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="${robotsDirective}">
    <meta name="description" content="${escapeHtml(description)}">
    <meta name="theme-color" content="#071426">
    <meta property="og:type" content="product">
    <meta property="og:site_name" content="YoMart">
    <meta property="og:title" content="${escapeHtml(name)} | YoMart">
    <meta property="og:description" content="${escapeHtml(description)}">
    ${images[0] ? `<meta property="og:image" content="${escapeHtml(images[0])}">` : ''}
    <meta property="og:url" content="${escapeHtml(url)}">
    <link rel="canonical" href="${escapeHtml(url)}">
    <title>${escapeHtml(name)} | YoMart</title>
    <script type="application/ld+json">${jsonLd}</script>
    <style>
      :root{color-scheme:light dark;font:16px/1.55 system-ui,sans-serif;background:#071426;color:#edf4ff}
      *{box-sizing:border-box}body{margin:0}header,main,footer{width:min(100% - 32px,960px);margin-inline:auto}
      header{padding:24px 0}header a,footer a{color:#72b8ff;text-decoration:none;font-weight:650}
      main{padding:16px 0 48px}.product{display:grid;grid-template-columns:minmax(0,1.1fr) minmax(280px,.9fr);gap:32px;align-items:start}
      .gallery{display:grid;grid-template-columns:repeat(auto-fit,minmax(120px,1fr));gap:12px}.gallery img{width:100%;aspect-ratio:1/1;object-fit:contain;background:#101f33;border:1px solid #233a57;border-radius:18px;padding:10px}
      h1{font-size:clamp(1.7rem,4vw,2.6rem);line-height:1.15;margin:8px 0 16px}.eyebrow,.availability{color:#a8bad3}.price{font-size:1.5rem;font-weight:750;margin:20px 0 4px}.button{display:inline-flex;margin-top:24px;padding:13px 20px;border-radius:14px;background:#0878f9;color:#fff;text-decoration:none;font-weight:700}
      footer{border-top:1px solid #20344d;padding:20px 0 36px;color:#a8bad3}.contacts{display:flex;flex-wrap:wrap;gap:8px;margin-top:12px}.contacts a{border:1px solid #38516f;border-radius:12px;padding:9px 12px;color:#edf4ff;text-decoration:none;font-weight:650} @media(max-width:680px){.product{grid-template-columns:1fr;gap:22px}}
    </style>
  </head>
  <body>
    <header><a href="${escapeHtml(siteUrl.href)}" aria-label="YoMart home">YoMart</a></header>
    <main>
      <article class="product">
        <div class="gallery" aria-label="${escapeHtml(name)} product images">${gallery || '<p>Product images are not available.</p>'}</div>
        <div>
          ${categoryName ? `<p class="eyebrow">${categoryUrl ? `<a href="${escapeHtml(categoryUrl)}">${escapeHtml(categoryName)}</a>` : escapeHtml(categoryName)}</p>` : ''}
          <h1>${escapeHtml(name)}</h1>
          ${brandName ? `<p class="eyebrow">Brand: ${escapeHtml(brandName)}</p>` : ''}
          <p class="price">${escapeHtml(priceText)}</p>
          <p class="availability">${stockText}</p>
          <p>${escapeHtml(description)}</p>
          <a class="button" href="${escapeHtml(siteUrl.href)}">Open YoMart store</a>
          ${contactActions.length ? `<nav class="contacts" aria-label="Contact YoMart">${contactActions.map((action) => `<a href="${escapeHtml(action.href)}"${action.href.startsWith('https:') ? ' target="_blank" rel="noopener noreferrer"' : ''}>${escapeHtml(action.label)}</a>`).join('')}</nav>` : ''}
        </div>
      </article>
    </main>
    <footer><a href="${escapeHtml(siteUrl.href)}">Browse more products</a></footer>
  </body>
</html>`;
}

function buildCategoryHtml(category, products, { siteUrl, apiUrl, robotsDirective = 'index,follow,max-image-preview:large' }) {
  const name = String(category.name || '').trim();
  const route = categoryPath(category);
  if (!name || !route) return null;
  const url = new URL(route, siteUrl).href;
  const image = safeImageUrl(category.image, apiUrl);
  const productItems = products.map((product) => {
    const productRoute = productPath(product);
    if (!productRoute) return '';
    const productUrl = new URL(productRoute, siteUrl).href;
    const productName = String(product.name || '').trim();
    const productImage = (Array.isArray(product.images) ? product.images : [])
      .map((entry) => safeImageUrl(entry?.url, apiUrl)).find(Boolean);
    const price = Number(product.offerPrice) > 0 && Number(product.offerPrice) < Number(product.price)
      ? Number(product.offerPrice)
      : Number(product.price);
    const priceText = Number.isFinite(price) && price > 0
      ? `Birr ${new Intl.NumberFormat('en-ET', { maximumFractionDigits: 2 }).format(price)}`
      : '';
    return `<li><a href="${escapeHtml(productUrl)}">${productImage ? `<img src="${escapeHtml(productImage)}" alt="">` : ''}<span>${escapeHtml(productName)}</span>${priceText ? `<strong>${escapeHtml(priceText)}</strong>` : ''}</a></li>`;
  }).filter(Boolean);
  const itemList = {
    '@context': 'https://schema.org',
    '@type': 'CollectionPage',
    name,
    url,
    mainEntity: {
      '@type': 'ItemList',
      itemListElement: products.map((product, index) => {
        const productRoute = productPath(product);
        return productRoute ? {
          '@type': 'ListItem',
          position: index + 1,
          url: new URL(productRoute, siteUrl).href,
          name: String(product.name || '').trim(),
        } : null;
      }).filter(Boolean),
    },
  };
  const description = `Browse ${name} products listed on YoMart.`;
  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="${robotsDirective}">
    <meta name="description" content="${escapeHtml(description)}">
    <meta property="og:type" content="website">
    <meta property="og:site_name" content="YoMart">
    <meta property="og:title" content="${escapeHtml(name)} | YoMart">
    <meta property="og:description" content="${escapeHtml(description)}">
    ${image ? `<meta property="og:image" content="${escapeHtml(image)}">` : ''}
    <meta property="og:url" content="${escapeHtml(url)}">
    <link rel="canonical" href="${escapeHtml(url)}">
    <title>${escapeHtml(name)} | YoMart</title>
    <script type="application/ld+json">${JSON.stringify(itemList).replace(/</g, '\\u003c')}</script>
    <style>
      :root{color-scheme:light dark;font:16px/1.55 system-ui,sans-serif;background:#071426;color:#edf4ff}*{box-sizing:border-box}body{margin:0}header,main,footer{width:min(100% - 32px,960px);margin-inline:auto}header{padding:24px 0}a{color:#72b8ff;text-decoration:none}main{padding:16px 0 48px}h1{font-size:clamp(1.7rem,4vw,2.6rem)}ul{list-style:none;margin:24px 0;padding:0;display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:16px}li a{display:grid;gap:8px;padding:14px;border:1px solid #233a57;border-radius:16px;color:inherit}li img{width:100%;aspect-ratio:1/1;object-fit:contain;background:#101f33;border-radius:12px}footer{border-top:1px solid #20344d;padding:20px 0 36px}
    </style>
  </head>
  <body><header><a href="${escapeHtml(siteUrl.href)}">YoMart</a></header><main><h1>${escapeHtml(name)}</h1>${image ? `<img src="${escapeHtml(image)}" alt="${escapeHtml(name)}" width="160" height="160">` : ''}<p>${escapeHtml(description)}</p><ul>${productItems.join('') || '<li>No verified products are currently listed in this category.</li>'}</ul></main><footer><a href="${escapeHtml(siteUrl.href)}">Browse the YoMart store</a></footer></body>
</html>`;
}

async function main() {
  const apiUrl = requiredUrl(apiBase, 'SEO_API_BASE_URL');
  const siteUrl = requiredUrl(siteOrigin, 'SEO_SITE_ORIGIN');
  if (apiUrl.pathname !== '/' || apiUrl.search || apiUrl.hash || siteUrl.pathname !== '/' || siteUrl.search || siteUrl.hash) {
    throw new Error('SEO_API_BASE_URL and SEO_SITE_ORIGIN must be origin URLs without a path, query, or hash.');
  }
  let buildMetadata;
  try {
    buildMetadata = JSON.parse(await fs.readFile(path.join(outputDirectory, 'yomart-build-config.json'), 'utf8'));
  } catch {
    throw new Error('The web output is missing valid yomart-build-config.json; build it with tooling/build_web.mjs first.');
  }
  if (apiUrl.origin !== buildMetadata.apiOrigin) {
    throw new Error('SEO_API_BASE_URL does not match the API origin used for this Flutter web build.');
  }
  if (siteUrl.origin !== buildMetadata.storefrontOrigin) {
    throw new Error('SEO_SITE_ORIGIN does not match the web origin used for the privacy-policy build URL.');
  }
  if (!['local', 'staging', 'production'].includes(buildMetadata.buildEnv)) {
    throw new Error('Web build metadata contains an unsupported environment.');
  }
  const isStagingBuild = buildMetadata.buildEnv === 'staging';
  const robotsDirective = isStagingBuild ? STAGING_ROBOTS_DIRECTIVE : 'index,follow,max-image-preview:large';

  const response = await fetch(new URL('/products', apiUrl), {
    headers: { accept: 'application/json' },
    signal: AbortSignal.timeout(20_000),
  });
  if (!response.ok) throw new Error(`Catalog request failed with HTTP ${response.status}.`);
  const payload = await response.json();
  if (!payload?.success || !Array.isArray(payload.data)) throw new Error('The public products endpoint returned an unexpected response.');

  const categoryResponse = await fetch(new URL('/categories', apiUrl), {
    headers: { accept: 'application/json' },
    signal: AbortSignal.timeout(20_000),
  });
  if (!categoryResponse.ok) throw new Error(`Category request failed with HTTP ${categoryResponse.status}.`);
  const categoryPayload = await categoryResponse.json();
  if (!categoryPayload?.success || !Array.isArray(categoryPayload.data)) {
    throw new Error('The public categories endpoint returned an unexpected response.');
  }

  const settingsResponse = await fetch(new URL('/store-settings', apiUrl), {
    headers: { accept: 'application/json' },
    signal: AbortSignal.timeout(20_000),
  });
  if (!settingsResponse.ok) throw new Error(`Store settings request failed with HTTP ${settingsResponse.status}.`);
  const settingsPayload = await settingsResponse.json();
  if (!settingsPayload?.success || !settingsPayload.data || typeof settingsPayload.data !== 'object') {
    throw new Error('The public store settings endpoint returned an unexpected response.');
  }
  const contactActions = buildContactActions(settingsPayload.data);

  const productsRoot = path.join(outputDirectory, 'products');
  const indexPath = path.join(outputDirectory, 'index.html');
  const indexHtml = await fs.readFile(indexPath, 'utf8');
  if (!indexHtml.includes('</head>')) throw new Error('Built index.html is missing its closing head element.');
  const sitemapUrls = [new URL('/', siteUrl).href];
  const seen = new Set();
  const seenCategories = new Set();
  let generated = 0;
  const stagingRoot = await fs.mkdtemp(path.join(outputDirectory, '.seo-products-'));
  const stagedProductsRoot = path.join(stagingRoot, 'products');
  await fs.mkdir(stagedProductsRoot, { recursive: true });
  await fs.mkdir(path.join(stagingRoot, 'categories'), { recursive: true });

  try {
    for (const product of payload.data) {
      // Even active catalog records stay out of search until an admin confirms them.
      if (!isCatalogVerified(product)) continue;
      const route = productPath(product);
      if (!route || seen.has(route)) continue;
      const html = buildProductHtml(product, { siteUrl, apiUrl, contactActions, robotsDirective });
      if (!html) continue;
      seen.add(route);
      const destination = path.join(stagedProductsRoot, route.slice('/products/'.length), 'index.html');
      await fs.mkdir(path.dirname(destination), { recursive: true });
      await fs.writeFile(destination, html, 'utf8');
      sitemapUrls.push(new URL(route, siteUrl).href);
      generated += 1;
    }

    if (generated === 0) throw new Error('No valid public products were returned; refusing to write an empty product sitemap.');
    for (const category of categoryPayload.data) {
      const route = categoryPath(category);
      if (!route || seenCategories.has(route)) continue;
      const categoryId = catalogId(category);
      const categoryProducts = payload.data.filter((product) =>
        isCatalogVerified(product) && catalogId(product.proCategoryId) === categoryId && productPath(product));
      const html = buildCategoryHtml(category, categoryProducts, { siteUrl, apiUrl, robotsDirective });
      if (!html) continue;
      seenCategories.add(route);
      const destination = path.join(stagingRoot, 'categories', route.slice('/categories/'.length), 'index.html');
      await fs.mkdir(path.dirname(destination), { recursive: true });
      await fs.writeFile(destination, html, 'utf8');
      sitemapUrls.push(new URL(route, siteUrl).href);
    }
    const rootUrl = new URL('/', siteUrl).href;
    const rootMeta = `\n  <meta property="og:url" content="${rootUrl}">\n  <link rel="canonical" href="${rootUrl}">`;
    const canonicalIndexHtml = indexHtml.includes('rel="canonical"')
      ? indexHtml
      : indexHtml.replace('</head>', `${rootMeta}\n</head>`);
    const finalIndexHtml = isStagingBuild
      ? setRobotsDirective(canonicalIndexHtml, STAGING_ROBOTS_DIRECTIVE)
      : canonicalIndexHtml;
    const xml = `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${sitemapUrls.map((url) => `  <url><loc>${escapeHtml(url)}</loc></url>`).join('\n')}\n</urlset>\n`;
    const stagedSitemapPath = path.join(stagingRoot, 'sitemap.xml');
    const robotsPath = path.join(outputDirectory, 'robots.txt');
    const stagedRobotsPath = path.join(stagingRoot, 'robots.txt');
    let robots = await fs.readFile(robotsPath, 'utf8').catch((error) => {
      if (error.code === 'ENOENT') return 'User-agent: *\nAllow: /\n';
      throw error;
    });
    if (isStagingBuild) {
      // Keep crawling enabled so crawlers can fetch and observe each noindex
      // directive. A disallow could leave linked URLs indexable without content.
      robots = 'User-agent: *\nAllow: /\n';
      await fs.rm(path.join(outputDirectory, 'sitemap.xml'), { force: true });
    } else {
      robots = `${robots.replace(/^Sitemap:\s*.*\r?\n?/gim, '').trimEnd()}\nSitemap: ${new URL('/sitemap.xml', siteUrl).href}\n`;
      await fs.writeFile(stagedSitemapPath, xml, 'utf8');
    }
    await fs.writeFile(stagedRobotsPath, robots, 'utf8');
    await fs.writeFile(indexPath, finalIndexHtml, 'utf8');
    await fs.rm(productsRoot, { recursive: true, force: true });
    await fs.rename(stagedProductsRoot, productsRoot);
    const categoriesRoot = path.join(outputDirectory, 'categories');
    await fs.rm(categoriesRoot, { recursive: true, force: true });
    await fs.rename(path.join(stagingRoot, 'categories'), categoriesRoot);
    if (!isStagingBuild) await fs.rename(stagedSitemapPath, path.join(outputDirectory, 'sitemap.xml'));
    await fs.rename(stagedRobotsPath, robotsPath);
    console.log(`Generated ${generated} product pages and ${seenCategories.size} category pages${isStagingBuild ? ' with staging noindex and no sitemap' : ' with sitemap.xml'} in ${outputDirectory}.`);
  } finally {
    await fs.rm(stagingRoot, { recursive: true, force: true });
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  main().catch((error) => {
    console.error(`SEO catalog generation failed: ${error.message}`);
    process.exitCode = 1;
  });
}
