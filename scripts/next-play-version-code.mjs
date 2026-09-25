#!/usr/bin/env node
// Next Play versionCode = 1 + the highest code already on this package.
// Tracks share one sequence (including drafts). Prints the integer on stdout.

import crypto from 'node:crypto';
import { pathToFileURL } from 'node:url';

const SCOPE = 'https://www.googleapis.com/auth/androidpublisher';
const TOKEN_URL = 'https://oauth2.googleapis.com/token';
const PUBLISHER = 'https://androidpublisher.googleapis.com/androidpublisher/v3';
const PLAY_VERSION_CODE_LIMIT = 2_100_000_000;

export function parseServiceAccount(raw) {
  if (!raw || !raw.trim()) {
    throw new Error('PLAY_STORE_SERVICE_ACCOUNT_JSON is empty');
  }
  let sa;
  try {
    sa = JSON.parse(raw.replace(/^\uFEFF/, ''));
  } catch {
    throw new Error('PLAY_STORE_SERVICE_ACCOUNT_JSON is not valid JSON');
  }
  if (!sa.client_email || !sa.private_key) {
    throw new Error('service account JSON is missing client_email or private_key');
  }
  return sa;
}

export function signServiceAccountJwt(serviceAccount, nowSeconds = Math.floor(Date.now() / 1000)) {
  const header = base64url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const claim = base64url(JSON.stringify({
    iss: serviceAccount.client_email,
    scope: SCOPE,
    aud: TOKEN_URL,
    iat: nowSeconds - 60,
    exp: nowSeconds + 3600,
  }));
  const unsigned = `${header}.${claim}`;
  const signature = crypto
    .sign('RSA-SHA256', Buffer.from(unsigned), serviceAccount.private_key)
    .toString('base64url');
  return `${unsigned}.${signature}`;
}

export function maxVersionCode(tracks) {
  let max = 0;
  const summary = [];
  for (const track of tracks ?? []) {
    let trackMax = 0;
    for (const release of track.releases ?? []) {
      for (const code of release.versionCodes ?? []) {
        const n = Number(code);
        if (Number.isInteger(n) && n > trackMax) trackMax = n;
      }
    }
    if (track.track) summary.push(`${track.track}:${trackMax}`);
    if (trackMax > max) max = trackMax;
  }
  return { max, summary };
}

export function nextFromMax(max) {
  if (!Number.isInteger(max) || max < 1) {
    throw new Error('no Play versionCode found on any track; refusing to upload version 1');
  }
  const next = max + 1;
  if (next > PLAY_VERSION_CODE_LIMIT) {
    throw new Error(`versionCode ${next} exceeds the Play limit of ${PLAY_VERSION_CODE_LIMIT}`);
  }
  return next;
}

function base64url(value) {
  return Buffer.from(value).toString('base64url');
}

async function api(token, method, url, body) {
  const res = await fetch(url, {
    method,
    headers: {
      Authorization: `Bearer ${token}`,
      ...(body === undefined ? {} : { 'Content-Type': 'application/json' }),
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const text = await res.text();
  if (!res.ok) {
    throw new Error(`${method} ${url} → ${res.status} ${text.slice(0, 500)}`);
  }
  return text ? JSON.parse(text) : {};
}

async function accessToken(serviceAccount) {
  const assertion = signServiceAccountJwt(serviceAccount);
  const res = await fetch(TOKEN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });
  const text = await res.text();
  if (!res.ok) {
    throw new Error(`oauth token → ${res.status} ${text.slice(0, 500)}`);
  }
  const json = JSON.parse(text);
  if (!json.access_token) throw new Error('oauth token response has no access_token');
  return json.access_token;
}

async function main() {
  const packageName = process.env.PLAY_PACKAGE_NAME;
  if (!packageName) throw new Error('PLAY_PACKAGE_NAME is empty');

  const serviceAccount = parseServiceAccount(process.env.PLAY_STORE_SERVICE_ACCOUNT_JSON);
  const token = await accessToken(serviceAccount);
  const editsUrl = `${PUBLISHER}/applications/${encodeURIComponent(packageName)}/edits`;

  let editId;
  try {
    const edit = await api(token, 'POST', editsUrl, {});
    editId = edit.id;
    if (!editId) throw new Error('Play edit response has no id');

    const listed = await api(token, 'GET', `${editsUrl}/${editId}/tracks`);
    const { max, summary } = maxVersionCode(listed.tracks);
    const next = nextFromMax(max);
    console.error(`Play versionCode max=${max} next=${next} (${summary.join(', ') || 'no tracks'})`);
    console.log(String(next));
  } finally {
    if (editId) {
      await api(token, 'DELETE', `${editsUrl}/${editId}`).catch((err) => {
        console.error(`warning: failed to delete Play edit ${editId}: ${err.message}`);
      });
    }
  }
}

const isDirectRun = process.argv[1]
  && import.meta.url === pathToFileURL(process.argv[1]).href;

if (isDirectRun) {
  main().catch((err) => {
    console.error(err.message);
    process.exit(1);
  });
}
