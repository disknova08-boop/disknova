// api/telegram.js
import axios from 'axios';
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
const BOT_TOKEN = process.env.BOT_TOKEN;
const WEBAPP_URL = process.env.WEBAPP_URL || 'https://disknova-2cna.vercel.app';

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

async function sendMessage(chatId, text, options = {}) {
  try {
    await axios.post(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
      chat_id: chatId,
      text,
      parse_mode: 'HTML',
      ...options
    });
  } catch (e) {
    console.error('Error sending message:', e.response?.data || e.message);
  }
}

export default async function handler(req, res) {
  if (req.method === 'GET') {
    return res.status(200).json({ status: 'Webhook is running' });
  }
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const update = req.body;
    const msg = update.message || update.channel_post || update.edited_message;
    if (!msg) return res.status(200).json({ ok: true });

    const chatId = msg.chat?.id;
    const tgUserId = msg.from?.id;
    const username = msg.from?.username || msg.from?.first_name || 'User';

    // /start
    if (msg.text?.trim().toLowerCase() === '/start') {
      await sendMessage(chatId,
        `👋 <b>Welcome to DiskNova Bot!</b>\n\nUse /link to connect your Telegram account.`
      );
      return res.status(200).json({ ok: true });
    }

    // /help
    if (msg.text?.trim().toLowerCase() === '/help') {
      await sendMessage(chatId,
        `📘 <b>Commands:</b>\n/start - Welcome\n/link - Verify your account\n/status - Check status`
      );
      return res.status(200).json({ ok: true });
    }

    // /status
    if (msg.text?.trim().toLowerCase() === '/status') {
      const { data: publisher } = await supabase
        .from('publishers')
        .select('telegram_verified, first_name, brand_name')
        .eq('telegram_id', tgUserId)
        .single();

      if (publisher?.telegram_verified) {
        await sendMessage(chatId,
          `✅ Verified!\nName: ${publisher.first_name}\nBrand: ${publisher.brand_name}`
        );
      } else {
        await sendMessage(chatId, `❌ Not verified.\nUse /link to connect your account.`);
      }
      return res.status(200).json({ ok: true });
    }

    // /link
    if (msg.text?.trim().toLowerCase() === '/link') {
      // Generate token
      const token = Math.random().toString(36).substring(2, 15);
      const expiresAt = new Date(Date.now() + 15 * 60 * 1000).toISOString();

      // Delete old tokens
      await supabase.from('telegram_verifications').delete().eq('telegram_id', tgUserId);

      // Insert new token
      await supabase.from('telegram_verifications').insert({
        telegram_id: tgUserId,
        token,
        expires_at: expiresAt,
        used: false
      });

      // Link URL
      const verifyUrl = `${WEBAPP_URL}/api/verify-telegram?token=${token}&telegram_id=${tgUserId}`;

      await sendMessage(chatId,
        `🔗 <b>Verification Link Created!</b>\n\nClick the button below to verify your DiskNova account.\n\n⏱ Link expires in 15 minutes.`,
        {
          reply_markup: {
            inline_keyboard: [[{ text: 'Verify Account ✅', url: verifyUrl }]]
          }
        }
      );
      return res.status(200).json({ ok: true });
    }

    await sendMessage(chatId, `Unknown command. Use /help for options.`);
    return res.status(200).json({ ok: true });
  } catch (error) {
    console.error('Handler error:', error);
    return res.status(200).json({ ok: true });
  }
}
