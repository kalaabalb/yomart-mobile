import fs from 'node:fs/promises';
import path from 'node:path';
import { isIP } from 'node:net';

export const ACCOUNT_DELETION_CONFIG = 'account-deletion-config.js';
export const BUILD_METADATA_FILE = 'yomart-build-config.json';

// These legacy deployment hosts have appeared in repository documentation.
// Staging builds reject them as an additional guard against a copied prod URL.
export const KNOWN_PRODUCTION_API_HOSTS = new Set([
  'yonasmarketplace-backend.onrender.com',
  'ecommerce-backend-api-jet.vercel.app',
]);

const PLACEHOLDER_HOST_PARTS = [
  'replace-with', 'placeholder', 'your-api-domain',
  'example.com', 'example.org', 'example.net', 'example.invalid',
];

function isLoopbackHost(hostname) {
  const host = hostname.toLowerCase().replace(/^\[|\]$/g, '');
  if (host === 'localhost' || host.endsWith('.localhost') || host === '::1') return true;
  if (isIP(host) === 4 && Number(host.split('.')[0]) === 127) return true;
  return false;
}

function parseUrl(value, name) {
  if (typeof value !== 'string' || !value.trim()) {
    throw new Error(`${name} is required.`);
  }
  let parsed;
  try {
    parsed = new URL(value.trim());
  } catch {
    throw new Error(`${name} must be an absolute HTTP(S) URL.`);
  }
  if (!['http:', 'https:'].includes(parsed.protocol) || parsed.username || parsed.password) {
    throw new Error(`${name} must use HTTP(S) and cannot contain credentials.`);
  }
  if (parsed.search || parsed.hash) {
    throw new Error(`${name} cannot contain a query string or fragment.`);
  }
  const rawValue = value.toLowerCase();
  const hostname = parsed.hostname.toLowerCase();
  if (/[<>]/.test(value) || rawValue.includes('replace-with') ||
      hostname === 'example' || hostname.endsWith('.example') ||
      PLACEHOLDER_HOST_PARTS.some((part) => hostname.includes(part))) {
    throw new Error(`${name} contains a placeholder host.`);
  }
  return parsed;
}

function parseOrigin(value, name, { allowLocalHttp = false } = {}) {
  const parsed = parseUrl(value, name);
  if (parsed.pathname !== '/' && parsed.pathname !== '') {
    throw new Error(`${name} must be an origin without a path.`);
  }
  const loopback = isLoopbackHost(parsed.hostname);
  if (parsed.protocol !== 'https:' && !(loopback && allowLocalHttp && parsed.protocol === 'http:')) {
    throw new Error(`${name} must use HTTPS; HTTP is allowed only for local loopback builds.`);
  }
  return { origin: parsed.origin, hostname: parsed.hostname.toLowerCase(), loopback };
}

function parsePolicyUrl(value, buildEnv) {
  const parsed = parseUrl(value, 'PRIVACY_POLICY_URL');
  const loopback = isLoopbackHost(parsed.hostname);
  if (buildEnv !== 'local' && (parsed.protocol !== 'https:' || loopback)) {
    throw new Error('PRIVACY_POLICY_URL must use HTTPS and cannot point to localhost for staging/production builds.');
  }
  if (parsed.protocol !== 'https:' && !(buildEnv === 'local' && loopback && parsed.protocol === 'http:')) {
    throw new Error('PRIVACY_POLICY_URL must use HTTPS; local HTTP is allowed only for local builds.');
  }
  return parsed.href;
}

function parseOriginList(value, name) {
  if (typeof value !== 'string' || !value.trim()) {
    throw new Error(`${name} is required for environment separation.`);
  }
  const origins = value.split(',').map((entry) => parseOrigin(entry.trim(), name).origin);
  return new Set(origins);
}

export function resolveBuildConfig(env) {
  const buildEnv = env.YOMART_BUILD_ENV;
  if (!['local', 'staging', 'production'].includes(buildEnv)) {
    throw new Error('YOMART_BUILD_ENV must be local, staging, or production.');
  }

  const api = parseOrigin(env.MAIN_URL, 'MAIN_URL', { allowLocalHttp: buildEnv === 'local' });
  const expected = parseOrigin(
    env.YOMART_EXPECTED_API_ORIGIN,
    'YOMART_EXPECTED_API_ORIGIN',
    { allowLocalHttp: buildEnv === 'local' },
  );
  if (api.origin !== expected.origin) {
    throw new Error('MAIN_URL must exactly match YOMART_EXPECTED_API_ORIGIN for the selected build environment.');
  }

  if (buildEnv === 'local' && !api.loopback) {
    throw new Error('Local builds must target localhost or a loopback IP.');
  }
  if (buildEnv !== 'local' && api.loopback) {
    throw new Error(`${buildEnv} builds cannot target localhost or a loopback IP.`);
  }
  if (buildEnv === 'staging' && KNOWN_PRODUCTION_API_HOSTS.has(api.hostname)) {
    throw new Error('A known production API host cannot be used for a staging build.');
  }
  if (buildEnv === 'staging') {
    const productionOrigins = parseOriginList(env.YOMART_PRODUCTION_API_ORIGINS, 'YOMART_PRODUCTION_API_ORIGINS');
    for (const productionHost of KNOWN_PRODUCTION_API_HOSTS) {
      productionOrigins.add(`https://${productionHost}`);
    }
    if (productionOrigins.has(api.origin)) {
      throw new Error('A production API origin cannot be used for a staging build.');
    }
  }
  if (buildEnv === 'production') {
    const stagingOrigins = parseOriginList(env.YOMART_STAGING_API_ORIGINS, 'YOMART_STAGING_API_ORIGINS');
    if (stagingOrigins.has(api.origin)) {
      throw new Error('A staging API origin cannot be used for a production build.');
    }
  }
  const privacyPolicyUrl = parsePolicyUrl(env.PRIVACY_POLICY_URL, buildEnv);
  const siteOrigin = new URL(privacyPolicyUrl).origin;
  if (buildEnv === 'staging') {
    const productionSites = parseOriginList(env.YOMART_PRODUCTION_SITE_ORIGINS, 'YOMART_PRODUCTION_SITE_ORIGINS');
    if (productionSites.has(siteOrigin)) {
      throw new Error('A production site origin cannot be used for a staging build.');
    }
  }
  if (buildEnv === 'production') {
    const stagingSites = parseOriginList(env.YOMART_STAGING_SITE_ORIGINS, 'YOMART_STAGING_SITE_ORIGINS');
    if (stagingSites.has(siteOrigin)) {
      throw new Error('A staging site origin cannot be used for a production build.');
    }
  }

  return Object.freeze({
    buildEnv,
    apiOrigin: api.origin,
    privacyPolicyUrl,
    allowInsecureLocalApi: buildEnv === 'local' && api.origin.startsWith('http:'),
    productionApiOrigins: buildEnv === 'staging' ? env.YOMART_PRODUCTION_API_ORIGINS : '',
    stagingApiOrigins: buildEnv === 'production' ? env.YOMART_STAGING_API_ORIGINS : '',
    productionSiteOrigins: buildEnv === 'staging' ? env.YOMART_PRODUCTION_SITE_ORIGINS : '',
    stagingSiteOrigins: buildEnv === 'production' ? env.YOMART_STAGING_SITE_ORIGINS : '',
  });
}

export function accountDeletionConfigSource(apiOrigin, siteOrigin) {
  return `// Generated by tooling/build_web.mjs. Do not edit or commit environment URLs.\nwindow.YOMART_API_BASE_URL = ${JSON.stringify(apiOrigin)};\nwindow.YOMART_EXPECTED_SITE_ORIGIN = ${JSON.stringify(siteOrigin)};\n`;
}

async function listFiles(root) {
  const entries = await fs.readdir(root, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const filePath = path.join(root, entry.name);
    if (entry.isDirectory()) files.push(...await listFiles(filePath));
    else if (entry.isFile()) files.push(filePath);
  }
  return files;
}

const TEXT_EXTENSIONS = new Set(['.html', '.js', '.json', '.txt', '.xml', '.css', '.webmanifest']);
const LOCAL_ENDPOINT = /https?:\/\/(?:localhost|[^/\s"'\\]*\.localhost|127(?:\.\d{1,3}){3}|\[::1\])(?::\d+)?/i;
const PLACEHOLDER_ENDPOINT = /REPLACE-WITH-YOUR-API-DOMAIN|https?:\/\/(?:your-api-domain|placeholder(?:\.[^/\s"']+)?|[^/\s"']*\.example(?:[:/]|$)|example\.(?:com|org|net|invalid))/i;

async function htmlFiles(directory) {
  const entries = await fs.readdir(directory, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const filePath = path.join(directory, entry.name);
    if (entry.isDirectory()) files.push(...await htmlFiles(filePath));
    else if (entry.isFile() && path.extname(entry.name).toLowerCase() === '.html') files.push(filePath);
  }
  return files;
}

const ROBOTS_META = /<meta\b(?=[^>]*\bname\s*=\s*['"]robots['"])[^>]*>/gi;
const STAGING_ROBOTS_META = '<meta name="robots" content="noindex,nofollow,noarchive">';

/** Applies a staging-only crawler policy after the Flutter build. */
export async function applyStagingNoIndex(outputDirectory, buildEnv) {
  if (buildEnv !== 'staging') return;
  const pages = await htmlFiles(outputDirectory);
  if (!pages.length) throw new Error('Staging web artifact contains no HTML pages to protect from indexing.');
  for (const pagePath of pages) {
    const html = await fs.readFile(pagePath, 'utf8');
    if (!/<\/head\s*>/i.test(html)) {
      throw new Error(`Staging HTML page is missing a head element: ${path.relative(outputDirectory, pagePath)}.`);
    }
    const protectedHtml = html.replace(ROBOTS_META, '').replace(/<\/head\s*>/i, `${STAGING_ROBOTS_META}\n</head>`);
    await fs.writeFile(pagePath, protectedHtml, 'utf8');
  }

  // Keep crawling allowed so crawlers can fetch each page and observe noindex.
  // A disallow rule could hide the meta directive while still allowing a URL
  // discovered elsewhere to appear in search results.
  await fs.writeFile(path.join(outputDirectory, 'robots.txt'), 'User-agent: *\nAllow: /\n', 'utf8');
  await fs.rm(path.join(outputDirectory, 'sitemap.xml'), { force: true });
}

export async function validateBuiltArtifact(outputDirectory, config) {
  const files = await listFiles(outputDirectory);
  const configPath = path.join(outputDirectory, ACCOUNT_DELETION_CONFIG);
  const generatedConfig = await fs.readFile(configPath, 'utf8').catch(() => {
    throw new Error(`Built artifact is missing ${ACCOUNT_DELETION_CONFIG}.`);
  });
  if (generatedConfig !== accountDeletionConfigSource(config.apiOrigin, new URL(config.privacyPolicyUrl).origin)) {
    throw new Error('Built account-deletion API configuration does not match the validated API origin.');
  }
  const metadataPath = path.join(outputDirectory, BUILD_METADATA_FILE);
  let metadata;
  try {
    metadata = JSON.parse(await fs.readFile(metadataPath, 'utf8'));
  } catch {
    throw new Error(`Built artifact is missing valid ${BUILD_METADATA_FILE}.`);
  }
  if (metadata.buildEnv !== config.buildEnv || metadata.apiOrigin !== config.apiOrigin ||
      metadata.privacyPolicyUrl !== config.privacyPolicyUrl ||
      metadata.storefrontOrigin !== new URL(config.privacyPolicyUrl).origin) {
    throw new Error('Built deployment metadata does not match the validated build configuration.');
  }

  const textFiles = files.filter((filePath) => TEXT_EXTENSIONS.has(path.extname(filePath).toLowerCase()));
  const contents = await Promise.all(textFiles.map(async (filePath) => [filePath, await fs.readFile(filePath, 'utf8')]));
  // main.dart.js contains the production-origin denylist by design; its active
  // API define must match this origin, while localhost/placeholders are banned
  // from all published text artifacts below.
  const flutterEntrypoint = contents.find(([filePath]) => path.basename(filePath) === 'main.dart.js');
  if (flutterEntrypoint && (!flutterEntrypoint[1].includes(config.apiOrigin) ||
      !flutterEntrypoint[1].includes(config.privacyPolicyUrl))) {
    throw new Error('Flutter web entrypoint does not contain the validated API and site configuration.');
  }
  for (const [filePath, content] of contents) {
    if (PLACEHOLDER_ENDPOINT.test(content)) {
      throw new Error(`Built artifact contains a placeholder API endpoint: ${path.relative(outputDirectory, filePath)}.`);
    }
    if (config.buildEnv !== 'local' && LOCAL_ENDPOINT.test(content)) {
      throw new Error(`Built artifact contains a localhost API endpoint: ${path.relative(outputDirectory, filePath)}.`);
    }
  }
  if (config.buildEnv === 'staging') {
    const pages = await htmlFiles(outputDirectory);
    if (!pages.length) throw new Error('Staging artifact contains no HTML pages.');
    for (const pagePath of pages) {
      const html = await fs.readFile(pagePath, 'utf8');
      const directives = [...html.matchAll(ROBOTS_META)].map((match) => match[0]);
      if (directives.length !== 1 || !/\bcontent\s*=\s*['"]noindex\s*,\s*nofollow\s*,\s*noarchive['"]/i.test(directives[0])) {
        throw new Error(`Staging HTML page is not protected by the required robots meta: ${path.relative(outputDirectory, pagePath)}.`);
      }
    }
    const robots = await fs.readFile(path.join(outputDirectory, 'robots.txt'), 'utf8').catch(() => '');
    if (!/^User-agent:\s*\*\s*\nAllow:\s*\/\s*$/im.test(robots.trim()) || /^Sitemap:/im.test(robots)) {
      throw new Error('Staging robots.txt must allow crawlers to observe noindex and must not advertise a sitemap.');
    }
    try {
      await fs.access(path.join(outputDirectory, 'sitemap.xml'));
      throw new Error('Staging artifacts must not include a sitemap.');
    } catch (error) {
      if (error.code !== 'ENOENT') throw error;
    }
  }
  return { files: files.length, textFiles: textFiles.length };
}
