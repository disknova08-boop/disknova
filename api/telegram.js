// api/telegram.js
import axios from 'axios';
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
const BOT_TOKEN = process.env.BOT_TOKEN;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(200).end();

  const update = req.body;
  const msg = update.message || update.channel_post || update.edited_message;
  if (!msg) return res.status(200).end();

  const chatId = msg.chat?.id;
  const tgUserId = msg.from?.id;

  // --- 1) Check publisher mapping
  const { data: publisher, error: pubErr } = await supabase
    .from('publishers')
    .select('*')
    .eq('telegram_id', tgUserId)
    .single();

  if (pubErr || !publisher || !publisher.telegram_verified) {
    await axios.post(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
      chat_id: chatId,
      text: '❌ आप verified publisher नहीं हैं। पहले verify करें: /link'
    });
    return res.status(200).end();
  }

  // --- 2) If document/file
  if (msg.document) {
    try {
      // get file path
      const getFile = await axios.get(`https://api.telegram.org/bot${BOT_TOKEN}/getFile?file_id=${msg.document.file_id}`);
      const filePath = getFile.data.result.file_path;
      const fileUrl = `https://api.telegram.org/file/bot${BOT_TOKEN}/${filePath}`;

      // download file
      const fileResp = await axios.get(fileUrl, { responseType: 'arraybuffer' });
      const buffer = Buffer.from(fileResp.data);

      // validate size/type here as needed (msg.document.mime_type, file size)
      const fileName = msg.document.file_name || `upload_${Date.now()}`;

      // upload to Supabase Storage (server-side)
      const bucket = 'publisher-files'; // create this bucket in Supabase
      const uploadPath = `publishers/${publisher.id}/${fileName}`;

      const { error: upErr } = await supabase.storage
        .from(bucket)
        .upload(uploadPath, buffer, { contentType: msg.document.mime_type });

      if (upErr) throw upErr;

      await axios.post(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
        chat_id: chatId,
        text: `✅ Uploaded: ${fileName}`
      });
      return res.status(200).end();
    } catch (e) {
      console.error(e);
      await axios.post(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, { chat_id: chatId, text: '❌ Upload failed.' });
      return res.status(200).end();
    }
  }

  // --- 3) If user sends /link (start verification flow)
  if (msg.text && msg.text.trim().toLowerCase().startsWith('/link')) {
    // generate token and store in telegram_verifications
    const token = [...Array(30)].map(() => (Math.random() * 36 | 0).toString(36)).join('');
    const expiresAt = new Date(Date.now() + 1000 * 60 * 15).toISOString(); // 15 min

    await supabase.from('telegram_verifications').insert({
      telegram_id: tgUserId,
      token,
      expires_at: expiresAt
    });

    // send verification URL to user (point to your web app verify page)
    const verifyUrl = `https://disknova-2cna.vercel.app/verify-telegram?token=${token}`;
    await axios.post(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
      chat_id: chatId,
      text: `🔗 Click to verify your account: ${verifyUrl}\n(Valid for 15 minutes)`
    });
    return res.status(200).end();
  }

  // default reply
  return res.status(200).end();
}
