import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { buildWeb } from './build_web.mjs';
import { BUILD_METADATA_FILE } from './account_deletion_config.mjs';

async function writeBuildMetadata(directory, config) {
  await fs.writeFile(path.join(directory, BUILD_METADATA_FILE), JSON.stringify({
    buildEnv: config.buildEnv,
    apiOrigin: config.apiOrigin,
    privacyPolicyUrl: config.privacyPolicyUrl,
    storefrontOrigin: new URL(config.privacyPolicyUrl).origin,
  }));
}
import {
  accountDeletionConfigSource,
  applyStagingNoIndex,
  resolveBuildConfig,
  validateBuiltArtifact,
} from './account_deletion_config.mjs';

const stagingEnvironment = {
  YOMART_BUILD_ENV: 'staging',
  MAIN_URL: 'https://api.stage.yomart.test',
  YOMART_EXPECTED_API_ORIGIN: 'https://api.stage.yomart.test/',
  YOMART_PRODUCTION_API_ORIGINS: 'https://yonasmarketplace-backend.onrender.com,https://ecommerce-backend-api-jet.vercel.app',
  YOMART_PRODUCTION_SITE_ORIGINS: 'https://shop.production',
  PRIVACY_POLICY_URL: 'https://shop.stage.yomart.test/privacy-policy.html',
};

test('staging config binds account deletion to the supplied staging API origin', async () => {
  const config = resolveBuildConfig(stagingEnvironment);
  assert.equal(config.apiOrigin, 'https://api.stage.yomart.test');

  const directory = await fs.mkdtemp(path.join(os.tmpdir(), 'yomart-web-artifact-'));
  try {
    await fs.writeFile(path.join(directory, 'account-deletion-config.js'), accountDeletionConfigSource(config.apiOrigin, new URL(config.privacyPolicyUrl).origin));
    await writeBuildMetadata(directory, config);
    await fs.writeFile(path.join(directory, 'index.html'), '<!doctype html><html><head><title>YoMart</title></head><body><script src="account-deletion-config.js"></script></body></html>');
    await fs.writeFile(path.join(directory, 'account-deletion.html'), '<!doctype html><html><head><meta name="robots" content="index,follow"><title>Delete account</title></head><body></body></html>');
    await fs.mkdir(path.join(directory, 'products', 'synthetic-product'), { recursive: true });
    await fs.writeFile(path.join(directory, 'products', 'synthetic-product', 'index.html'), '<!doctype html><html><head><title>Product</title></head><body></body></html>');
    await fs.writeFile(path.join(directory, 'robots.txt'), 'User-agent: *\nAllow: /\nSitemap: https://shop.stage.yomart.test/sitemap.xml\n');
    await fs.writeFile(path.join(directory, 'sitemap.xml'), '<urlset></urlset>');
    await fs.writeFile(path.join(directory, 'main.dart.js'), `const api = "${config.apiOrigin}"; const policy = "${config.privacyPolicyUrl}"; const denied = "https://yonasmarketplace-backend.onrender.com";`);

    await applyStagingNoIndex(directory, config.buildEnv);
    const report = await validateBuiltArtifact(directory, config);
    assert.equal(report.files, 7);
    for (const pagePath of [
      path.join(directory, 'index.html'),
      path.join(directory, 'account-deletion.html'),
      path.join(directory, 'products', 'synthetic-product', 'index.html'),
    ]) {
      const page = await fs.readFile(pagePath, 'utf8');
      assert.equal((page.match(/name="robots"/g) || []).length, 1);
      assert.match(page, /name="robots" content="noindex,nofollow,noarchive"/);
    }
    assert.equal(await fs.readFile(path.join(directory, 'robots.txt'), 'utf8'), 'User-agent: *\nAllow: /\n');
    await assert.rejects(fs.access(path.join(directory, 'sitemap.xml')));
    assert.match(
      await fs.readFile(path.join(directory, 'account-deletion-config.js'), 'utf8'),
      /window\.YOMART_API_BASE_URL = "https:\/\/api\.stage\.yomart\.test";/,
    );
    assert.match(
      await fs.readFile(path.join(directory, 'account-deletion-config.js'), 'utf8'),
      /window\.YOMART_EXPECTED_SITE_ORIGIN = "https:\/\/shop\.stage\.yomart\.test";/,
    );
  } finally {
    await fs.rm(directory, { recursive: true, force: true });
  }
});

test('release config requires an explicit environment, API, expected origin, and policy URL', () => {
  assert.throws(() => resolveBuildConfig({}), /YOMART_BUILD_ENV must be/);
  assert.throws(() => resolveBuildConfig({ ...stagingEnvironment, MAIN_URL: '' }), /MAIN_URL is required/);
  assert.throws(() => resolveBuildConfig({ ...stagingEnvironment, YOMART_EXPECTED_API_ORIGIN: '' }), /YOMART_EXPECTED_API_ORIGIN is required/);
  assert.throws(() => resolveBuildConfig({ ...stagingEnvironment, PRIVACY_POLICY_URL: '' }), /PRIVACY_POLICY_URL is required/);
});

test('staging accepts unset or empty production-origin denylists when origins are unconfirmed', () => {
  for (const env of [
    { ...stagingEnvironment, YOMART_PRODUCTION_API_ORIGINS: undefined, YOMART_PRODUCTION_SITE_ORIGINS: undefined },
    { ...stagingEnvironment, YOMART_PRODUCTION_API_ORIGINS: '', YOMART_PRODUCTION_SITE_ORIGINS: '' },
  ]) {
    const config = resolveBuildConfig(env);
    assert.equal(config.productionApiOrigins, '');
    assert.equal(config.productionSiteOrigins, '');
  }
});

test('staging validates every supplied production origin and rejects overlap', () => {
  assert.doesNotThrow(() => resolveBuildConfig(stagingEnvironment));
  for (const invalid of [
    'https://*.production.test',
    'https://shop.production.example/path',
    'https://user@shop.production.example',
    'https://shop.production.example?preview=1',
    'https://shop.production.example,',
  ]) {
    assert.throws(() => resolveBuildConfig({
      ...stagingEnvironment,
      YOMART_PRODUCTION_SITE_ORIGINS: invalid,
    }));
  }
  assert.throws(() => resolveBuildConfig({
    ...stagingEnvironment,
    YOMART_PRODUCTION_SITE_ORIGINS: 'https://shop.stage.yomart.test',
  }), /production site origin cannot be used for a staging build/);
});

test('web build wrapper fails before building when environment configuration is absent', async (t) => {
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), 'yomart-web-preflight-'));
  t.after(() => fs.rm(directory, { recursive: true, force: true }));
  await assert.rejects(buildWeb({}, { runFlutter: false, outputPath: directory }), /YOMART_BUILD_ENV must be/);
});

test('staging rejects local, placeholder, mismatched, and known production API origins', () => {
  assert.throws(() => resolveBuildConfig({
    ...stagingEnvironment,
    MAIN_URL: 'http://127.0.0.1:3000',
    YOMART_EXPECTED_API_ORIGIN: 'http://127.0.0.1:3000',
  }), /must use HTTPS/);
  assert.throws(() => resolveBuildConfig({
    ...stagingEnvironment,
    MAIN_URL: 'https://REPLACE-WITH-YOUR-API-DOMAIN',
    YOMART_EXPECTED_API_ORIGIN: 'https://REPLACE-WITH-YOUR-API-DOMAIN',
  }), /placeholder host/);
  assert.throws(() => resolveBuildConfig({
    ...stagingEnvironment,
    MAIN_URL: 'https://another.stage.yomart.test',
  }), /must exactly match/);
  assert.throws(() => resolveBuildConfig({
    ...stagingEnvironment,
    MAIN_URL: 'https://yonasmarketplace-backend.onrender.com',
    YOMART_EXPECTED_API_ORIGIN: 'https://yonasmarketplace-backend.onrender.com',
  }), /known production API host/);
});

test('local mode permits loopback HTTP only for a deliberate local build', () => {
  const config = resolveBuildConfig({
    YOMART_BUILD_ENV: 'local',
    MAIN_URL: 'http://127.0.0.1:3000',
    YOMART_EXPECTED_API_ORIGIN: 'http://127.0.0.1:3000/',
    PRIVACY_POLICY_URL: 'http://127.0.0.1:3000/privacy-policy.html',
  });
  assert.equal(config.allowInsecureLocalApi, true);
  assert.throws(() => resolveBuildConfig({
    ...stagingEnvironment,
    YOMART_BUILD_ENV: 'production',
    MAIN_URL: 'https://api.stage.yomart.test',
    YOMART_STAGING_API_ORIGINS: 'https://api.stage.yomart.test',
    YOMART_STAGING_SITE_ORIGINS: 'https://shop.stage.yomart.test',
  }), /staging API origin cannot be used for a production build/);
  assert.throws(() => resolveBuildConfig({
    ...stagingEnvironment,
    YOMART_BUILD_ENV: 'production',
    MAIN_URL: 'https://api.prod.yomart.test',
    YOMART_EXPECTED_API_ORIGIN: 'https://api.prod.yomart.test',
    YOMART_STAGING_SITE_ORIGINS: 'https://shop.stage.yomart.test',
  }), /YOMART_STAGING_API_ORIGINS is required/);
  const production = resolveBuildConfig({
    YOMART_BUILD_ENV: 'production',
    MAIN_URL: 'https://api.yomart.com',
    YOMART_EXPECTED_API_ORIGIN: 'https://api.yomart.com',
    YOMART_STAGING_API_ORIGINS: 'https://api.stage.yomart.test',
    YOMART_STAGING_SITE_ORIGINS: 'https://shop.stage.yomart.test',
    PRIVACY_POLICY_URL: 'https://shop.yomart.com/privacy-policy.html',
  });
  assert.equal(production.apiOrigin, 'https://api.yomart.com');
  for (const variable of ['YOMART_STAGING_API_ORIGINS', 'YOMART_STAGING_SITE_ORIGINS']) {
    assert.throws(() => resolveBuildConfig({
      YOMART_BUILD_ENV: 'production',
      MAIN_URL: 'https://api.yomart.com',
      YOMART_EXPECTED_API_ORIGIN: 'https://api.yomart.com',
      PRIVACY_POLICY_URL: 'https://shop.yomart.com/privacy-policy.html',
      YOMART_STAGING_API_ORIGINS: 'https://api.stage.yomart.test',
      YOMART_STAGING_SITE_ORIGINS: 'https://shop.stage.yomart.test',
      [variable]: '',
    }), new RegExp(`${variable} is required`));
  }
});

test('site origins are blocked across staging and production and validate URL edge cases', () => {
  assert.throws(() => resolveBuildConfig({
    ...stagingEnvironment,
    PRIVACY_POLICY_URL: 'https://shop.production/privacy-policy.html',
  }), /production site origin cannot be used/);
  assert.throws(() => resolveBuildConfig({
    ...stagingEnvironment,
    PRIVACY_POLICY_URL: 'https://shop.yomart.example/privacy-policy.html',
  }), /placeholder host/);
  assert.throws(() => resolveBuildConfig({
    ...stagingEnvironment,
    PRIVACY_POLICY_URL: 'https://user@shop.stage.yomart.test/privacy-policy.html',
  }), /cannot contain credentials/);
  assert.throws(() => resolveBuildConfig({
    ...stagingEnvironment,
    PRIVACY_POLICY_URL: 'https://shop.stage.yomart.test/policy?preview=1',
  }), /query string or fragment/);
  assert.throws(() => resolveBuildConfig({
    ...stagingEnvironment,
    MAIN_URL: 'https://127.0.0.2',
    YOMART_EXPECTED_API_ORIGIN: 'https://127.0.0.2',
  }), /cannot target localhost or a loopback IP/);
  for (const unsafeApi of [
    'https://user:secret@api.stage.yomart.test',
    'https://api.stage.yomart.test/path',
    'https://api.stage.yomart.test?debug=1',
    'https://api.stage.yomart.test#fragment',
    'https://api.yomart.example',
    'https://*.stage.yomart.test',
  ]) {
    assert.throws(() => resolveBuildConfig({
      ...stagingEnvironment,
      MAIN_URL: unsafeApi,
      YOMART_EXPECTED_API_ORIGIN: unsafeApi,
    }));
  }
  assert.throws(() => resolveBuildConfig({
    ...stagingEnvironment,
    YOMART_BUILD_ENV: 'production',
    MAIN_URL: 'https://api.yomart.com',
    YOMART_EXPECTED_API_ORIGIN: 'https://api.yomart.com',
    YOMART_STAGING_API_ORIGINS: 'https://api.stage.yomart.test',
    YOMART_STAGING_SITE_ORIGINS: 'https://shop.stage.yomart.test',
    PRIVACY_POLICY_URL: 'https://shop.stage.yomart.test/privacy-policy.html',
  }), /staging site origin cannot be used/);
});

test('failed web build configuration removes any previous output artifact', async (t) => {
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), 'yomart-stale-output-'));
  t.after(() => fs.rm(directory, { recursive: true, force: true }));
  await fs.writeFile(path.join(directory, 'old-release.txt'), 'do not publish me');
  await assert.rejects(buildWeb({}, { runFlutter: false, outputPath: directory }));
  await assert.rejects(fs.access(directory));
});

test('artifact validation rejects leftover localhost, placeholder, and production endpoints', async (t) => {
  const config = resolveBuildConfig(stagingEnvironment);
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), 'yomart-web-invalid-artifact-'));
  t.after(() => fs.rm(directory, { recursive: true, force: true }));
  await fs.writeFile(path.join(directory, 'account-deletion-config.js'), accountDeletionConfigSource(config.apiOrigin, new URL(config.privacyPolicyUrl).origin));
  await writeBuildMetadata(directory, config);
  await fs.writeFile(path.join(directory, 'index.html'), '<!doctype html><html><head><meta name="robots" content="noindex,nofollow,noarchive"></head><body></body></html>');
  await fs.writeFile(path.join(directory, 'robots.txt'), 'User-agent: *\nAllow: /\n');

  for (const [endpoint, expectedError] of [
    ['http://localhost:3000', /localhost API endpoint/],
    ['https://REPLACE-WITH-YOUR-API-DOMAIN', /placeholder API endpoint/],
  ]) {
    await fs.writeFile(path.join(directory, 'main.dart.js'), `const api = "${config.apiOrigin}"; const policy = "${config.privacyPolicyUrl}"; const accidentalApi = "${endpoint}";`);
    await assert.rejects(validateBuiltArtifact(directory, config), expectedError);
  }

  await fs.writeFile(path.join(directory, 'main.dart.js'), `const api = "${config.apiOrigin}"; const policy = "${config.privacyPolicyUrl}";`);
  await fs.writeFile(
    path.join(directory, 'account-deletion-config.js'),
    accountDeletionConfigSource('https://ecommerce-backend-api-jet.vercel.app', new URL(config.privacyPolicyUrl).origin),
  );
  await assert.rejects(validateBuiltArtifact(directory, config), /does not match the validated API origin/);
  await fs.writeFile(path.join(directory, 'account-deletion-config.js'), accountDeletionConfigSource('https://other.stage.yomart.test', new URL(config.privacyPolicyUrl).origin));
  await assert.rejects(validateBuiltArtifact(directory, config), /does not match the validated API origin/);
});

test('staging artifact validation rejects missing, indexable, or duplicate robots directives', async (t) => {
  const config = resolveBuildConfig(stagingEnvironment);
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), 'yomart-stage-noindex-'));
  t.after(() => fs.rm(directory, { recursive: true, force: true }));
  await fs.writeFile(path.join(directory, 'account-deletion-config.js'), accountDeletionConfigSource(config.apiOrigin, new URL(config.privacyPolicyUrl).origin));
  await writeBuildMetadata(directory, config);
  await fs.writeFile(path.join(directory, 'main.dart.js'), `const api = "${config.apiOrigin}"; const policy = "${config.privacyPolicyUrl}";`);
  await fs.writeFile(path.join(directory, 'robots.txt'), 'User-agent: *\nAllow: /\n');
  await fs.writeFile(path.join(directory, 'index.html'), '<html><head><title>Stage</title></head></html>');
  await assert.rejects(validateBuiltArtifact(directory, config), /not protected by the required robots meta/);

  await fs.writeFile(path.join(directory, 'index.html'), '<html><head><meta name="robots" content="index,follow"></head></html>');
  await assert.rejects(validateBuiltArtifact(directory, config), /not protected by the required robots meta/);
  await fs.writeFile(path.join(directory, 'index.html'), '<html><head><meta name="robots" content="noindex,nofollow,noarchive"><meta name="robots" content="noindex,nofollow,noarchive"></head></html>');
  await assert.rejects(validateBuiltArtifact(directory, config), /not protected by the required robots meta/);
});
