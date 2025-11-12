// api/verify-telegram.js
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

export default async function handler(req, res) {
  // ---- Enable CORS ----
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  );

  if (req.method === 'OPTIONS') {
    return res.status(200).json({ ok: true });
  }

  // ------------------ GET (when user clicks verification link) ------------------
  if (req.method === 'GET') {
    const { token, telegram_id } = req.query; // 🔹 fixed key

    if (!token || !telegram_id) {
      return sendHtml(res, false, 'Missing verification data.');
    }

    try {
      // Find token record
      const { data: verification, error: tokenError } = await supabase
        .from('telegram_verifications')
        .select('*')
        .eq('token', token)
        .eq('telegram_id', telegram_id)
        .eq('used', false)
        .single();

      if (tokenError || !verification) {
        return sendHtml(res, false, 'Invalid or expired verification link.');
      }

      // Check expiry
      const expiresAt = new Date(verification.expires_at);
      if (expiresAt < new Date()) {
        return sendHtml(res, false, 'Verification link has expired.');
      }

      // Update publisher table
      const { error: updateError } = await supabase
        .from('publishers')
        .update({
          telegram_verified: true,
          updated_at: new Date().toISOString()
        })
        .eq('telegram_id', telegram_id);

      if (updateError) {
        console.error('Error updating publisher:', updateError);
        return sendHtml(res, false, 'Failed to link your Telegram account.');
      }

      // Mark token as used
      await supabase
        .from('telegram_verifications')
        .update({ used: true })
        .eq('token', token);

      // Fetch publisher info
      const { data: publisher } = await supabase
        .from('publishers')
        .select('first_name, brand_name')
        .eq('telegram_id', telegram_id)
        .single();

      const name = publisher?.first_name || 'User';
      const brand = publisher?.brand_name || 'Your brand';

      return sendHtml(
        res,
        true,
        `Hey ${name}!<br>Your Telegram has been successfully linked with <b>${brand}</b>.`
      );

    } catch (err) {
      console.error('GET verification error:', err);
      return sendHtml(res, false, 'Something went wrong. Please try again.');
    }
  }

  // ------------------ POST (API direct verification) ------------------
  if (req.method === 'POST') {
    const { token, telegram_id } = req.body; // 🔹 fixed key

    if (!token || !telegram_id) {
      return res.status(400).json({ success: false, error: 'Missing token or telegram_id' });
    }

    try {
      const { data: verification, error: tokenError } = await supabase
        .from('telegram_verifications')
        .select('*')
        .eq('token', token)
        .eq('telegram_id', telegram_id)
        .eq('used', false)
        .single();

      if (tokenError || !verification) {
        return res.status(400).json({ success: false, error: 'Invalid or expired verification token' });
      }

      // Check expiry
      const expiresAt = new Date(verification.expires_at);
      if (expiresAt < new Date()) {
        return res.status(400).json({
          success: false,
          error: 'Verification link has expired. Please request a new one.'
        });
      }

      // Update publisher table
      const { error: updateError } = await supabase
        .from('publishers')
        .update({
          telegram_verified: true,
          updated_at: new Date().toISOString()
        })
        .eq('telegram_id', telegram_id);

      if (updateError) {
        return res.status(500).json({ success: false, error: 'Failed to link Telegram account' });
      }

      // Mark token as used
      await supabase
        .from('telegram_verifications')
        .update({ used: true })
        .eq('token', token);

      const { data: publisher } = await supabase
        .from('publishers')
        .select('first_name, brand_name')
        .eq('telegram_id', telegram_id)
        .single();

      return res.status(200).json({
        success: true,
        message: 'Telegram account linked successfully!',
        publisher
      });
    } catch (error) {
      console.error('Verification error:', error);
      return res.status(500).json({ success: false, error: 'Internal server error' });
    }
  }

  return res.status(405).json({ error: 'Method not allowed' });
}

// ------------------ HTML Page Helper ------------------
function sendHtml(res, success, message) {
  const color = success ? '#16a34a' : '#dc2626';
  const emoji = success ? '✅' : '❌';
  const redirectLink = 'https://t.me/Hkgaming07';
  const html = `
  <html>
    <head>
      <meta charset="UTF-8" />
      <title>${success ? 'Verified!' : 'Verification Failed'}</title>
      <style>
        body {
          font-family: system-ui, sans-serif;
          background: #f9fafb;
          display: flex;
          justify-content: center;
          align-items: center;
          height: 100vh;
          text-align: center;
        }
        .card {
          background: white;
          border-radius: 12px;
          padding: 30px 40px;
          box-shadow: 0 4px 15px rgba(0,0,0,0.1);
          max-width: 400px;
        }
        h1 {
          color: ${color};
          font-size: 1.6rem;
          margin-bottom: 10px;
        }
        p {
          color: #374151;
          margin-bottom: 20px;
          line-height: 1.5;
        }
        a {
          text-decoration: none;
          background: ${color};
          color: white;
          padding: 10px 18px;
          border-radius: 6px;
          font-weight: 600;
        }
      </style>
    </head>
    <body>
      <div class="card">
        <h1>${emoji} ${success ? 'Verification Successful' : 'Verification Failed'}</h1>
        <p>${message}</p>
        <a href="${redirectLink}" target="_blank">Return to Telegram</a>
      </div>
    </body>
  </html>`;

  res.setHeader('Content-Type', 'text/html');
  res.status(success ? 200 : 400).send(html);
}
