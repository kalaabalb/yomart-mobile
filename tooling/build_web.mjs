#!/usr/bin/env node

import { spawnSync } from 'node:child_process';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath, pathToFileURL } from 'node:url';
import fs from 'node:fs/promises';
import {
  BUILD_METADATA_FILE,
  accountDeletionConfigSource,
  applyStagingNoIndex,
  resolveBuildConfig,
  validateBuiltArtifact,
} from './account_deletion_config.mjs';

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const outputDirectory = path.join(projectRoot, 'build', 'web');

export async function buildWeb(
  env = process.env,
  { runFlutter = true, outputPath = outputDirectory } = {},
) {
  // Remove any previous release artifact before validating inputs: a failed
  // release command must never leave a stale build directory looking publishable.
  await fs.rm(outputPath, { recursive: true, force: true });
  try {
    const config = resolveBuildConfig(env);
    if (runFlutter) {
      const flutterArgs = [
        'build', 'web', '--release',
        '--output', outputPath,
        `--dart-define=MAIN_URL=${config.apiOrigin}`,
        `--dart-define=PRIVACY_POLICY_URL=${config.privacyPolicyUrl}`,
        `--dart-define=YOMART_BUILD_ENV=${config.buildEnv}`,
        `--dart-define=YOMART_EXPECTED_API_ORIGIN=${config.apiOrigin}`,
        `--dart-define=YOMART_PRODUCTION_API_ORIGINS=${config.productionApiOrigins}`,
        `--dart-define=YOMART_STAGING_API_ORIGINS=${config.stagingApiOrigins}`,
        `--dart-define=YOMART_PRODUCTION_SITE_ORIGINS=${config.productionSiteOrigins}`,
        `--dart-define=YOMART_STAGING_SITE_ORIGINS=${config.stagingSiteOrigins}`,
      ];
      if (config.allowInsecureLocalApi) {
        flutterArgs.push('--dart-define=ALLOW_INSECURE_LOCAL_API=true');
      }

      const result = spawnSync('flutter', flutterArgs, {
        cwd: projectRoot,
        env,
        stdio: 'inherit',
      });
      if (result.error) throw new Error(`Could not start Flutter: ${result.error.message}`);
      if (result.status !== 0) {
        throw new Error(`Flutter web build failed with exit code ${result.status ?? 'unknown'}.`);
      }
    }

    await applyStagingNoIndex(outputPath, config.buildEnv);

    await fs.writeFile(
      path.join(outputPath, 'account-deletion-config.js'),
      accountDeletionConfigSource(config.apiOrigin, new URL(config.privacyPolicyUrl).origin),
      'utf8',
    );
    await fs.writeFile(
      path.join(outputPath, BUILD_METADATA_FILE),
      `${JSON.stringify({
        buildEnv: config.buildEnv,
        apiOrigin: config.apiOrigin,
        privacyPolicyUrl: config.privacyPolicyUrl,
        storefrontOrigin: new URL(config.privacyPolicyUrl).origin,
      }, null, 2)}\n`,
      'utf8',
    );
    const artifactReport = await validateBuiltArtifact(outputPath, config);
    return { config, artifactReport };
  } catch (error) {
    await fs.rm(outputPath, { recursive: true, force: true });
    throw error;
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  buildWeb().then(({ config, artifactReport }) => {
    console.log(`Built and validated ${config.buildEnv} Flutter web artifact for ${config.apiOrigin}.`);
    console.log(`Checked ${artifactReport.files} files (${artifactReport.textFiles} text files).`);
  }).catch((error) => {
    console.error(`YoMart web build failed: ${error.message}`);
    process.exitCode = 1;
  });
}
