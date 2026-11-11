// Arabic, right-to-left HTML emails in the لمّه وتحدي brand.
// Inline styles only: most mail clients drop <style> blocks.

const SITE_URL = 'https://playlammh.com';
const BRAND_RED = '#E93556';
const LOGO_URL = `${SITE_URL}/icons/Icon-192.png`;

const COPY = {
  verifyEmail: {
    subject: 'فعّل حسابك في لمّه وتحدي',
    title: 'حيّاك في لمّه وتحدي!',
    body: 'باقي خطوة وحدة. اضغط الزر تحت عشان تفعّل حسابك وتبدأ التحدي مع ربعك.',
    button: 'تفعيل الحساب',
    footer: 'إذا ما سجّلت في لمّه وتحدي، تجاهل هذي الرسالة.',
  },
  resetPassword: {
    subject: 'إعادة تعيين كلمة المرور — لمّه وتحدي',
    title: 'نسيت كلمة المرور؟',
    body: 'وصلنا طلب لإعادة تعيين كلمة مرور حسابك. اضغط الزر تحت واختر كلمة مرور جديدة.',
    button: 'تعيين كلمة مرور جديدة',
    footer: 'إذا ما طلبت إعادة التعيين، تجاهل هذي الرسالة وكلمة مرورك ما راح تتغيّر.',
  },
};

/** Link to the in-app handler (lib/screens/auth_action_screen.dart). */
function actionUrl(mode, oobCode) {
  const params = new URLSearchParams({ mode, oobCode, lang: 'ar' });
  return `${SITE_URL}/?${params.toString()}`;
}

/** Pulls the one-time code out of a link from the Admin SDK. */
function oobCodeFrom(firebaseLink) {
  const code = new URL(firebaseLink).searchParams.get('oobCode');
  if (!code) throw new Error('Firebase link has no oobCode');
  return code;
}

function escapeHtml(s) {
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function buildEmail(mode, link) {
  const c = COPY[mode];
  if (!c) throw new Error(`Unknown email mode: ${mode}`);
  const href = escapeHtml(link);

  const html = `<!doctype html>
<html lang="ar" dir="rtl">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${c.subject}</title></head>
<body style="margin:0;padding:0;background:#F7F3F4;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#F7F3F4;padding:32px 12px;">
    <tr><td align="center">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:480px;background:#FFFFFF;border-radius:16px;overflow:hidden;font-family:Tahoma,Arial,sans-serif;direction:rtl;text-align:right;">
        <tr><td align="center" style="background:${BRAND_RED};padding:28px 16px;">
          <img src="${LOGO_URL}" width="72" height="72" alt="لمّه وتحدي" style="display:block;border-radius:16px;">
        </td></tr>
        <tr><td style="padding:28px 28px 8px;">
          <h1 style="margin:0 0 12px;font-size:22px;color:${BRAND_RED};">${c.title}</h1>
          <p style="margin:0;font-size:15px;line-height:1.8;color:#333333;">${c.body}</p>
        </td></tr>
        <tr><td align="center" style="padding:24px 28px;">
          <a href="${href}" style="display:inline-block;background:${BRAND_RED};color:#FFFFFF;text-decoration:none;font-size:16px;font-weight:bold;padding:14px 32px;border-radius:12px;">${c.button}</a>
        </td></tr>
        <tr><td style="padding:0 28px 24px;">
          <p style="margin:0;font-size:12px;line-height:1.7;color:#888888;">إذا ما اشتغل الزر، <a href="${href}" style="color:${BRAND_RED};">اضغط هنا</a>. الرابط صالح لمرة وحدة فقط.</p>
        </td></tr>
        <tr><td style="padding:16px 28px;border-top:1px solid #F0E0E6;">
          <p style="margin:0;font-size:12px;color:#999999;">${c.footer}<br>فريق لمّه وتحدي · <a href="${SITE_URL}" style="color:#999999;">playlammh.com</a></p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;

  const text = `${c.title}\n\n${c.body}\n\n${c.button}: ${link}\n\n${c.footer}\nفريق لمّه وتحدي — ${SITE_URL}`;

  return { subject: c.subject, html, text };
}

module.exports = { SITE_URL, actionUrl, oobCodeFrom, buildEmail };
