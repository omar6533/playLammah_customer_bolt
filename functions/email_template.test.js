const test = require('node:test');
const assert = require('node:assert');
const { actionUrl, oobCodeFrom, buildEmail } = require('./email_template');

test('oobCodeFrom extracts the code from an Admin SDK link', () => {
  const link =
    'https://allmahgame.firebaseapp.com/__/auth/action?mode=verifyEmail&oobCode=ABC-123_x&apiKey=k&continueUrl=https%3A%2F%2Fplaylammh.com%2F&lang=en';
  assert.strictEqual(oobCodeFrom(link), 'ABC-123_x');
});

test('actionUrl points at the in-app handler with mode and code', () => {
  const url = new URL(actionUrl('resetPassword', 'C0DE'));
  assert.strictEqual(url.origin, 'https://playlammh.com');
  assert.strictEqual(url.searchParams.get('mode'), 'resetPassword');
  assert.strictEqual(url.searchParams.get('oobCode'), 'C0DE');
});

test('buildEmail renders Arabic RTL email with the link', () => {
  const link = actionUrl('verifyEmail', 'XYZ');
  const { subject, html, text } = buildEmail('verifyEmail', link);
  assert.match(subject, /فعّل حسابك/);
  assert.match(html, /dir="rtl"/);
  assert.ok(html.includes(link.replace(/&/g, '&amp;')));
  assert.ok(text.includes(link));
});

test('buildEmail rejects unknown modes', () => {
  assert.throws(() => buildEmail('recoverEmail', 'x'));
});
