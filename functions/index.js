// Sends verification and password-reset emails ourselves, because this
// project's Firebase email templates are locked (EMAIL_TEMPLATE_UPDATE_NOT_ALLOWED)
// and Firebase's hosted action page is English-only. Links point at the
// Arabic handler on playlammh.com instead.

const crypto = require('node:crypto');
const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const logger = require('firebase-functions/logger');
const { SITE_URL, actionUrl, oobCodeFrom, buildEmail } = require('./email_template');

initializeApp();

const RESEND_API_KEY = defineSecret('RESEND_API_KEY');
const FROM = 'لمّه وتحدي <noreply@playlammh.com>';
const COOLDOWN_SECONDS = 60;

const callableOptions = {
  secrets: [RESEND_API_KEY],
  cors: true,
  maxInstances: 10,
};

/**
 * One email per address and type per minute, so the public reset endpoint
 * can't be used to flood someone's inbox.
 */
async function enforceCooldown(kind, email) {
  const id = crypto.createHash('sha256').update(`${kind}:${email}`).digest('hex');
  const ref = getFirestore().collection('email_send_log').doc(id);
  await getFirestore().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const last = snap.exists ? snap.get('last_sent') : null;
    if (last && Date.now() - last.toMillis() < COOLDOWN_SECONDS * 1000) {
      throw new HttpsError('resource-exhausted', 'Please wait before requesting another email.');
    }
    tx.set(ref, { kind, last_sent: Timestamp.now(), count: FieldValue.increment(1) }, { merge: true });
  });
}

async function sendEmail(to, { subject, html, text }) {
  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${RESEND_API_KEY.value()}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ from: FROM, to: [to], subject, html, text }),
  });
  if (!res.ok) {
    logger.error('Resend rejected the email', { status: res.status, body: await res.text() });
    throw new HttpsError('internal', 'Could not send the email.');
  }
}

function normalizeEmail(raw) {
  const email = String(raw || '').trim().toLowerCase();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || email.length > 254) {
    throw new HttpsError('invalid-argument', 'A valid email is required.');
  }
  return email;
}

/** Signed-in user asks for (another) activation link. */
exports.sendVerificationEmail = onCall(callableOptions, async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in first.');
  const user = await getAuth().getUser(request.auth.uid);
  if (!user.email) throw new HttpsError('failed-precondition', 'This account has no email.');
  if (user.emailVerified) return { alreadyVerified: true };

  const email = user.email.toLowerCase();
  await enforceCooldown('verifyEmail', email);

  const firebaseLink = await getAuth().generateEmailVerificationLink(email, { url: `${SITE_URL}/` });
  await sendEmail(email, buildEmail('verifyEmail', actionUrl('verifyEmail', oobCodeFrom(firebaseLink))));
  logger.info('Verification email sent', { uid: user.uid });
  return { sent: true };
});

/**
 * Password reset from the login screen. Always reports success so the
 * endpoint can't be used to find out which emails have accounts.
 */
exports.sendPasswordResetEmail = onCall(callableOptions, async (request) => {
  const email = normalizeEmail(request.data && request.data.email);
  await enforceCooldown('resetPassword', email);

  let firebaseLink;
  try {
    firebaseLink = await getAuth().generatePasswordResetLink(email, { url: `${SITE_URL}/` });
  } catch (e) {
    if (e.code === 'auth/user-not-found' || e.code === 'auth/email-not-found') return { sent: true };
    throw e;
  }
  await sendEmail(email, buildEmail('resetPassword', actionUrl('resetPassword', oobCodeFrom(firebaseLink))));
  logger.info('Password reset email sent');
  return { sent: true };
});
