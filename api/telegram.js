// api/telegram.js
import axios from 'axios';
import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import https from 'https';

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

// Download Telegram File
async function downloadTelegramFile(fileId) {
  const fileRes = await axios.get(
    `https://api.telegram.org/bot${BOT_TOKEN}/getFile?file_id=${fileId}`
  );
  const filePath = fileRes.data.result.file_path;
  const fileUrl = `https://api.telegram.org/file/bot${BOT_TOKEN}/${filePath}`;

  const tempPath = `/tmp/${Date.now()}_${filePath.split('/').pop()}`;
  const file = fs.createWriteStream(tempPath);

  return new Promise((resolve, reject) => {
    https.get(fileUrl, (response) => {
      response.pipe(file);
      file.on('finish', () => file.close(() => resolve(tempPath)));
    }).on('error', reject);
  });
}

export default async function handler(req, res) {
  if (req.method === 'GET') return res.status(200).json({ status: 'Bot active' });
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const update = req.body;
  const msg = update.message || update.channel_post || update.edited_message;
  if (!msg) return res.status(200).json({ ok: true });

  const chatId = msg.chat?.id;
  const tgUserId = msg.from?.id;

  try {
    // ✅ Step 1: Commands
    if (msg.text?.trim().toLowerCase() === '/start') {
      await sendMessage(chatId, '👋 Welcome to DiskNova Bot!\nUse /link to verify your account.');
      return res.status(200).json({ ok: true });
    }

    if (msg.text?.trim().toLowerCase() === '/help') {
      await sendMessage(chatId, 'Commands:\n/link - verify\n/status - check verification');
      return res.status(200).json({ ok: true });
    }

    if (msg.text?.trim().toLowerCase() === '/status') {
      const { data: publisher } = await supabase
        .from('publishers')
        .select('telegram_verified, brand_name')
        .eq('telegram_id', tgUserId)
        .single();

      if (publisher?.telegram_verified)
        await sendMessage(chatId, `✅ Verified for brand: ${publisher.brand_name}`);
      else await sendMessage(chatId, '❌ Not verified.\nUse /link to verify.');
      return res.status(200).json({ ok: true });
    }

    if (msg.text?.trim().toLowerCase() === '/link') {
      const token = Math.random().toString(36).substring(2, 15);
      const expiresAt = new Date(Date.now() + 15 * 60 * 1000).toISOString();

      await supabase.from('telegram_verifications').delete().eq('telegram_id', tgUserId);
      await supabase.from('telegram_verifications').insert({
        telegram_id: tgUserId,
        token,
        expires_at: expiresAt,
        used: false
      });

      const verifyUrl = `${WEBAPP_URL}/api/verify-telegram?token=${token}&telegram_id=${tgUserId}`;
      await sendMessage(chatId, '🔗 Click below to verify your DiskNova account', {
        reply_markup: { inline_keyboard: [[{ text: 'Verify ✅', url: verifyUrl }]] }
      });
      return res.status(200).json({ ok: true });
    }

    // ✅ Step 2: Handle video uploads
    if (msg.video || msg.document || msg.video_note) {
      const { data: publisher } = await supabase
        .from('publishers')
        .select('id, telegram_verified, brand_name')
        .eq('telegram_id', tgUserId)
        .single();

      if (!publisher?.telegram_verified) {
        await sendMessage(chatId, '⚠️ Please verify first using /link');
        return res.status(200).json({ ok: true });
      }

      const video = msg.video || msg.document || msg.video_note;
      const filePath = await downloadTelegramFile(video.file_id);

      const fileData = fs.readFileSync(filePath);
      const fileName = `${publisher.brand_name}_${Date.now()}.mp4`;

      const { data, error } = await supabase.storage
        .from('videos')
        .upload(`telegram/${fileName}`, fileData, {
          contentType: 'video/mp4',
          upsert: false,
        });

      fs.unlinkSync(filePath);

      if (error) {
        console.error('Upload error:', error);
        await sendMessage(chatId, '❌ Upload failed.');
      } else {
        const publicUrl = `${SUPABASE_URL.replace('.co', '.co/storage/v1/object/public/videos/telegram/')}${fileName}`;
        await sendMessage(chatId, `✅ Video uploaded successfully!\n\n🔗 ${publicUrl}`);
      }
    }

    res.status(200).json({ ok: true });
  } catch (error) {
    console.error('Error in handler:', error);
    res.status(200).json({ ok: true });
  }
}
