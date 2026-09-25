import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import test from 'node:test';

import {
  maxVersionCode,
  nextFromMax,
  parseServiceAccount,
  signServiceAccountJwt,
} from './next-play-version-code.mjs';

test('max version code is the highest across every track and release', () => {
  const { max, summary } = maxVersionCode([
    {
      track: 'production',
      releases: [
        { status: 'completed', versionCodes: ['40'] },
        { status: 'draft', versionCodes: ['44'] },
      ],
    },
    {
      track: 'internal',
      releases: [{ status: 'draft', versionCodes: ['45', 'junk'] }],
    },
  ]);

  assert.equal(max, 45);
  assert.deepEqual(summary, ['production:44', 'internal:45']);
});

test('missing releases count as zero', () => {
  assert.deepEqual(maxVersionCode([{ track: 'internal' }]), {
    max: 0,
    summary: ['internal:0'],
  });
  assert.deepEqual(maxVersionCode(undefined), { max: 0, summary: [] });
});

test('next code is one above the current max', () => {
  assert.equal(nextFromMax(45), 46);
});

test('refuses to guess version 1 when Play has no codes', () => {
  assert.throws(() => nextFromMax(0), /refusing to upload version 1/);
});

test('refuses a code above the Play limit', () => {
  assert.throws(() => nextFromMax(2_100_000_000), /exceeds the Play limit/);
});

test('service account parser rejects empty and non-json without echoing the secret', () => {
  assert.throws(() => parseServiceAccount(''), /empty/);
  assert.throws(
    () => parseServiceAccount('not-json {"private_key":"secret"}'),
    (err) => {
      assert.match(err.message, /not valid JSON/);
      assert.doesNotMatch(err.message, /secret/);
      return true;
    },
  );
  assert.throws(() => parseServiceAccount('{"client_email":"a@b.c"}'), /private_key/);
});

test('jwt is an RS256 assertion for the Play scope', () => {
  const { privateKey, publicKey } = crypto.generateKeyPairSync('rsa', { modulusLength: 2048 });
  const jwt = signServiceAccountJwt(
    {
      client_email: 'play@example.com',
      private_key: privateKey.export({ type: 'pkcs8', format: 'pem' }),
    },
    1_700_000_000,
  );
  const [header, payload, signature] = jwt.split('.');
  assert.equal(
    crypto.verify(
      'RSA-SHA256',
      Buffer.from(`${header}.${payload}`),
      publicKey,
      Buffer.from(signature, 'base64url'),
    ),
    true,
  );
  assert.deepEqual(JSON.parse(Buffer.from(header, 'base64url').toString()), {
    alg: 'RS256',
    typ: 'JWT',
  });
  const claim = JSON.parse(Buffer.from(payload, 'base64url').toString());
  assert.equal(claim.iss, 'play@example.com');
  assert.equal(claim.scope, 'https://www.googleapis.com/auth/androidpublisher');
  assert.equal(claim.aud, 'https://oauth2.googleapis.com/token');
  assert.equal(claim.iat, 1_700_000_000 - 60);
  assert.equal(claim.exp, 1_700_000_000 + 3600);
});
