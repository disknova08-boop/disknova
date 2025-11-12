// api/verify-telegram.js
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') return res.status(200).json({ ok: true });

  if (req.method === 'GET') {
    const { token, telegram_id } = req.query;
    if (!token || !telegram_id) return sendHtml(res, false, 'Missing verification data.');

    try {
      const { data: verification } = await supabase
        .from('telegram_verifications')
        .select('*')
        .eq('token', token)
        .eq('telegram_id', telegram_id)
        .eq('used', false)
        .single();

      if (!verification) return sendHtml(res, false, 'Invalid or expired verification link.');

      if (new Date(verification.expires_at) < new Date())
        return sendHtml(res, false, 'Verification link expired.');

      // Update publisher table
      const { data: existing } = await supabase
        .from('publishers')
        .select('id, telegram_id')
        .eq('telegram_id', telegram_id)
        .maybeSingle();

      // If telegram_id not set yet, update first user (or latest)
      if (!existing) {
        await supabase
          .from('publishers')
          .update({ telegram_id, telegram_verified: true })
          .order('created_at', { ascending: false })
          .limit(1);
      } else {
        await supabase
          .from('publishers')
          .update({ telegram_verified: true })
          .eq('telegram_id', telegram_id);
      }

      await supabase
        .from('telegram_verifications')
        .update({ used: true })
        .eq('token', token);

      return sendHtml(res, true, 'Your Telegram account has been verified successfully.');
    } catch (err) {
      console.error('Error verifying:', err);
      return sendHtml(res, false, 'Verification failed.');
    }
  }

  return res.status(405).json({ error: 'Method not allowed' });
}

function sendHtml(res, success, message) {
  const color = success ? '#16a34a' : '#dc2626';
  const emoji = success ? '✅' : '❌';
  const redirectLink = 'https://t.me/Hkgaming07';
  const html = `
  <html>
    <head>
      <meta charset="UTF-8" />
      <title>${emoji} ${success ? 'Verified' : 'Failed'}</title>
      <style>
        body {
          background:#f9fafb; font-family:sans-serif; height:100vh; display:flex;
          align-items:center; justify-content:center; text-align:center;
        }
        .card {
          background:white; padding:30px 40px; border-radius:12px;
          box-shadow:0 4px 10px rgba(0,0,0,0.1);
        }
        h1 { color:${color}; }
        a { display:inline-block; background:${color}; color:white;
            padding:10px 16px; border-radius:6px; margin-top:10px;
            text-decoration:none; font-weight:bold; }
      </style>
    </head>
    <body>
      <div class="card">
        <h1>${emoji} ${success ? 'Verification Successful' : 'Verification Failed'}</h1>
        <p>${message}</p>
        <a href="${redirectLink}">Return to Telegram</a>
      </div>
    </body>
  </html>`;
  res.setHeader('Content-Type', 'text/html');
  res.status(success ? 200 : 400).send(html);
}
