#!/usr/bin/env node
/**
 * Gagal jika AAB masih membawa permission advertising ID.
 * Dipakai CI sebelum upload ke Play supaya error muncul di sini, bukan
 * saat Commit Edit di Play Console.
 *
 * Manifest di dalam AAB ter-compress (deflate); jangan scan byte mentah AAB.
 */
import { existsSync } from "node:fs";
import { spawnSync } from "node:child_process";

const aabPath =
  process.argv[2] ??
  "build/app/outputs/bundle/productionRelease/app-production-release.aab";

if (!existsSync(aabPath)) {
  console.error(`AAB not found: ${aabPath}`);
  process.exit(1);
}

const unzip = spawnSync(
  "unzip",
  ["-p", aabPath, "base/manifest/AndroidManifest.xml"],
  { encoding: "buffer", maxBuffer: 20 * 1024 * 1024 },
);

if (unzip.status !== 0) {
  console.error(unzip.stderr?.toString() || "unzip failed");
  process.exit(1);
}

const manifest = unzip.stdout;
const forbidden = [
  "com.google.android.gms.permission.AD_ID",
  "android.permission.ACCESS_ADSERVICES_AD_ID",
];

const hits = forbidden.filter((s) => manifest.includes(s));
if (hits.length > 0) {
  console.error("Advertising ID permission(s) still present in AAB:");
  for (const h of hits) console.error(`  - ${h}`);
  console.error(
    'Remove via tools:node="remove" / exclude play-services-ads-identifier.',
  );
  process.exit(1);
}

console.log(`OK: no advertising ID permissions in ${aabPath}`);
