//import { createClient } from '@supabase/supabase-js';
//
//const SUPABASE_URL = process.env.SUPABASE_URL;
//const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
//const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
//
//export default async function handler(req, res) {
//  res.setHeader('Access-Control-Allow-Origin', '*');
//  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
//  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
//
//  if (req.method === 'OPTIONS') {
//    return res.status(200).end();
//  }
//
//  if (req.method === 'GET') {
//    const { token, telegram_id } = req.query;
//
//    if (!token || !telegram_id) {
//      return sendHtml(res, false, 'Missing verification data. Please try again from the bot.');
//    }
//
//    try {
//      // ✅ Check verification record
//      const { data: verification, error: verifyError } = await supabase
//        .from('telegram_verifications')
//        .select('*')
//        .eq('token', token)
//        .eq('telegram_id', telegram_id)
//        .eq('used', false)
//        .single();
//
//      if (verifyError || !verification) {
//        console.error('Verification not found:', verifyError);
//        return sendHtml(res, false, 'Invalid or expired verification link. Please request a new one from the bot using /link command.');
//      }
//
//      // ✅ Check if expired
//      if (new Date(verification.expires_at) < new Date()) {
//        return sendHtml(res, false, 'Verification link expired (15 minutes). Please use /link command in the bot to get a new link.');
//      }
//
//      // ✅ Get publisher by telegram_url matching
//      const { data: publisher, error: pubError } = await supabase
//        .from('publishers')
//        .select('*')
//        .eq('id', verification.publisher_id)
//        .single();
//
//      if (pubError || !publisher) {
//        console.error('Publisher not found:', pubError);
//        return sendHtml(res, false, 'Publisher account not found. Please ensure you have added your Telegram link in the DiskNova app.');
//      }
//
//      // ✅ Validate Telegram URL before verification
//      const telegramUrl = publisher.telegram_url;
//      if (!telegramUrl || telegramUrl.trim() === '') {
//        return sendHtml(res, false, 'Telegram URL not found in your profile. Please add it in the DiskNova app Social Links section first.');
//      }
//
//      // Check if URL is valid Telegram link
//      const telegramRegex = /^(https?:\/\/)?(www\.)?(t\.me|telegram\.me)\/.+$/i;
//      if (!telegramRegex.test(telegramUrl)) {
//        return sendHtml(res, false, `Invalid Telegram URL format: ${telegramUrl}. Please update it in the app.`);
//      }
//
//      // ✅ Update publisher with telegram_id and verify both telegram and telegram_url
//      const { error: updateError } = await supabase
//        .from('publishers')
//        .update({
//          telegram_id: telegram_id,
//          telegram_verified: true,
//          telegram_url_verified: true, // ✅ Also verify the URL field
//          updated_at: new Date().toISOString()
//        })
//        .eq('id', publisher.id);
//
//      if (updateError) {
//        console.error('Error updating publisher:', updateError);
//        return sendHtml(res, false, 'Failed to verify account. Please try again.');
//      }
//
//      // ✅ Mark verification token as used
//      await supabase
//        .from('telegram_verifications')
//        .update({ used: true })
//        .eq('token', token);
//
//      return sendHtml(
//        res,
//        true,
//        `Your Telegram account has been verified successfully! You can now upload videos directly from Telegram. Return to the bot to start uploading.`,
//        telegram_id
//      );
//
//    } catch (err) {
//      console.error('Verification error:', err);
//      return sendHtml(res, false, 'An error occurred during verification. Please try again.');
//    }
//  }
//
//  return res.status(405).json({ error: 'Method not allowed' });
//}
//
//function sendHtml(res, success, message, telegram_id) {
//  const color = success ? '#16a34a' : '#dc2626';
//  const emoji = success ? '✅' : '❌';
//  const bgColor = success ? '#f0fdf4' : '#fef2f2';
//  const botUsername = 'Hkgaming07'; // Replace with your bot username
//
//  const html = `
//  <!DOCTYPE html>
//  <html lang="en">
//  <head>
//    <meta charset="UTF-8" />
//    <meta name="viewport" content="width=device-width, initial-scale=1.0">
//    <title>${emoji} ${success ? 'Verified' : 'Failed'}</title>
//    <style>
//      * {
//        margin: 0;
//        padding: 0;
//        box-sizing: border-box;
//      }
//
//      body {
//        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
//        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
//        min-height: 100vh;
//        display: flex;
//        align-items: center;
//        justify-content: center;
//        padding: 20px;
//      }
//
//      .card {
//        background: white;
//        padding: 40px;
//        border-radius: 20px;
//        box-shadow: 0 20px 60px rgba(0,0,0,0.3);
//        max-width: 500px;
//        width: 100%;
//        text-align: center;
//      }
//
//      .icon {
//        width: 80px;
//        height: 80px;
//        background: ${bgColor};
//        border-radius: 50%;
//        display: flex;
//        align-items: center;
//        justify-content: center;
//        margin: 0 auto 24px;
//        font-size: 40px;
//      }
//
//      h1 {
//        color: ${color};
//        font-size: 28px;
//        margin-bottom: 16px;
//        font-weight: 700;
//      }
//
//      p {
//        color: #64748b;
//        font-size: 16px;
//        line-height: 1.6;
//        margin-bottom: 30px;
//      }
//
//      .btn {
//        display: inline-block;
//        background: ${color};
//        color: white;
//        padding: 14px 28px;
//        border-radius: 12px;
//        text-decoration: none;
//        font-weight: 600;
//        font-size: 16px;
//        transition: all 0.3s;
//      }
//
//      .btn:hover {
//        transform: translateY(-2px);
//        box-shadow: 0 10px 20px rgba(0,0,0,0.2);
//      }
//
//      .note {
//        margin-top: 24px;
//        padding: 16px;
//        background: #f8fafc;
//        border-radius: 10px;
//        font-size: 14px;
//        color: #475569;
//      }
//
//      @media (max-width: 640px) {
//        .card {
//          padding: 30px 20px;
//        }
//
//        h1 {
//          font-size: 24px;
//        }
//
//        p {
//          font-size: 15px;
//        }
//      }
//    </style>
//  </head>
//  <body>
//    <div class="card">
//      <div class="icon">${emoji}</div>
//      <h1>${success ? 'Verification Successful!' : 'Verification Failed'}</h1>
//      <p>${message}</p>
//      <a href="https://t.me/${botUsername}" class="btn">
//        ${success ? '🚀 Go to Bot' : '🔄 Try Again'}
//      </a>
//      ${success ? `
//        <div class="note">
//          <strong>Next Steps:</strong><br>
//          1. Return to the Telegram bot<br>
//          2. Send any video file to upload<br>
//          3. Get a shareable link instantly!
//        </div>
//      ` : `
//        <div class="note">
//          <strong>Troubleshooting:</strong><br>
//          1. Add your Telegram link in DiskNova app<br>
//          2. Use /link command in the bot<br>
//          3. Click the verification link within 15 minutes
//        </div>
//      `}
//    </div>
//  </body>
//  </html>`;
//
//  res.setHeader('Content-Type', 'text/html');
//  res.status(success ? 200 : 400).send(html);
//}
// api/verify-telegram.js
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method === 'GET') {
    const { token, telegram_id, bot_username } = req.query;

    if (!token || !telegram_id) {
      return sendHtml(res, false, 'Missing verification data. Please try again from the bot.', 'Hkgaming07');
    }

    try {
      // ✅ Check verification record
      const { data: verification, error: verifyError } = await supabase
        .from('telegram_verifications')
        .select('*')
        .eq('token', token)
        .eq('telegram_id', telegram_id)
        .eq('used', false)
        .single();

      if (verifyError || !verification) {
        console.error('Verification not found:', verifyError);
        return sendHtml(
          res,
          false,
          'Invalid or expired verification link. Please request a new one from the bot using /link command.',
          bot_username || 'Hkgaming07'
        );
      }

      // ✅ Check if expired
      if (new Date(verification.expires_at) < new Date()) {
        return sendHtml(
          res,
          false,
          'Verification link expired (15 minutes). Please use /link command in the bot to get a new link.',
          bot_username || verification.bot_username || 'Hkgaming07'
        );
      }

      // ✅ Get publisher by telegram_url matching
      const { data: publisher, error: pubError } = await supabase
        .from('publishers')
        .select('*')
        .eq('id', verification.publisher_id)
        .single();

      if (pubError || !publisher) {
        console.error('Publisher not found:', pubError);
        return sendHtml(
          res,
          false,
          'Publisher account not found. Please ensure you have added your Telegram link in the DiskNova app.',
          bot_username || verification.bot_username || 'Hkgaming07'
        );
      }

      // ✅ Validate Telegram URL before verification
      const telegramUrl = publisher.telegram_url;
      if (!telegramUrl || telegramUrl.trim() === '') {
        return sendHtml(
          res,
          false,
          'Telegram URL not found in your profile. Please add it in the DiskNova app Social Links section first.',
          bot_username || verification.bot_username || 'Hkgaming07'
        );
      }

      // Check if URL is valid Telegram link
      const telegramRegex = /^(https?:\/\/)?(www\.)?(t\.me|telegram\.me)\/.+$/i;
      if (!telegramRegex.test(telegramUrl)) {
        return sendHtml(
          res,
          false,
          `Invalid Telegram URL format: ${telegramUrl}. Please update it in the app.`,
          bot_username || verification.bot_username || 'Hkgaming07'
        );
      }

      // ✅ Update publisher with telegram_id and verify both telegram and telegram_url
      const { error: updateError } = await supabase
        .from('publishers')
        .update({
          telegram_id: telegram_id,
          telegram_verified: true,
          telegram_url_verified: true,
          updated_at: new Date().toISOString()
        })
        .eq('id', publisher.id);

      if (updateError) {
        console.error('Error updating publisher:', updateError);
        return sendHtml(
          res,
          false,
          'Failed to verify account. Please try again.',
          bot_username || verification.bot_username || 'Hkgaming07'
        );
      }

      // ✅ Mark verification token as used
      await supabase
        .from('telegram_verifications')
        .update({ used: true })
        .eq('token', token);

      // ✅ Use bot_username from URL or fallback to verification record
      const finalBotUsername = bot_username || verification.bot_username || 'Hkgaming07';

      return sendHtml(
        res,
        true,
        `Your Telegram account has been verified successfully! You can now upload videos directly from Telegram. Return to the bot to start uploading.`,
        finalBotUsername
      );

    } catch (err) {
      console.error('Verification error:', err);
      return sendHtml(
        res,
        false,
        'An error occurred during verification. Please try again.',
        bot_username || 'Hkgaming07'
      );
    }
  }

  return res.status(405).json({ error: 'Method not allowed' });
}

function sendHtml(res, success, message, botUsername) {
  const color = success ? '#16a34a' : '#dc2626';
  const emoji = success ? '✅' : '❌';
  const bgColor = success ? '#f0fdf4' : '#fef2f2';

  const html = `
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${emoji} ${success ? 'Verified' : 'Failed'}</title>
    <style>
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }

      body {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 20px;
      }

      .card {
        background: white;
        padding: 40px;
        border-radius: 20px;
        box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        max-width: 500px;
        width: 100%;
        text-align: center;
        animation: slideIn 0.5s ease-out;
      }

      @keyframes slideIn {
        from {
          opacity: 0;
          transform: translateY(-20px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }

      .icon {
        width: 80px;
        height: 80px;
        background: ${bgColor};
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 24px;
        font-size: 40px;
        animation: bounce 0.6s ease-in-out;
      }

      @keyframes bounce {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.1); }
      }

      h1 {
        color: ${color};
        font-size: 28px;
        margin-bottom: 16px;
        font-weight: 700;
      }

      p {
        color: #64748b;
        font-size: 16px;
        line-height: 1.6;
        margin-bottom: 30px;
      }

      .btn {
        display: inline-block;
        background: ${color};
        color: white;
        padding: 14px 28px;
        border-radius: 12px;
        text-decoration: none;
        font-weight: 600;
        font-size: 16px;
        transition: all 0.3s;
        box-shadow: 0 4px 15px rgba(0,0,0,0.2);
      }

      .btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0,0,0,0.3);
      }

      .btn:active {
        transform: translateY(0);
      }

      .note {
        margin-top: 24px;
        padding: 16px;
        background: #f8fafc;
        border-radius: 10px;
        font-size: 14px;
        color: #475569;
        border-left: 4px solid ${color};
      }

      .note strong {
        display: block;
        margin-bottom: 8px;
        color: #1e293b;
      }

      @media (max-width: 640px) {
        .card {
          padding: 30px 20px;
        }

        h1 {
          font-size: 24px;
        }

        p {
          font-size: 15px;
        }
      }
    </style>
  </head>
  <body>
    <div class="card">
      <div class="icon">${emoji}</div>
      <h1>${success ? 'Verification Successful!' : 'Verification Failed'}</h1>
      <p>${message}</p>
      <a href="https://t.me/${botUsername}" class="btn">
        ${success ? '🚀 Go to Bot' : '🔄 Try Again'}
      </a>
      ${success ? `
        <div class="note">
          <strong>Next Steps:</strong><br>
          1. Return to @${botUsername} on Telegram<br>
          2. Send any video file to upload<br>
          3. Get a shareable link instantly!
        </div>
      ` : `
        <div class="note">
          <strong>Troubleshooting:</strong><br>
          1. Add your Telegram link in DiskNova app<br>
          2. Use /link command in @${botUsername}<br>
          3. Click the verification link within 15 minutes
        </div>
      `}
    </div>
  </body>
  </html>`;

  res.setHeader('Content-Type', 'text/html');
  res.status(success ? 200 : 400).send(html);
}