// File: /api/telegram.js
import { createClient } from '@supabase/supabase-js';
import axios from 'axios';

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).end();

  const update = req.body;
  const msg = update.message;
  if (!msg) return res.status(200).end();

  const tgId = msg.from.id;

  // 1️⃣ Publisher check
  const { data: publisher, error } = await supabase
    .from('publishers')
    .select('*')
    .eq('telegram_id', tgId)
    .single();

  if (error || !publisher || !publisher.telegram_verified) {
    await axios.post(`https://api.telegram.org/bot${process.env.BOT_TOKEN}/sendMessage`, {
      chat_id: msg.chat.id,
      text: "❌ आप verified publisher नहीं हैं। कृपया पहले verify करें।"
    });
    return res.status(200).end();
  }

  // 2️⃣ If user sent document/file
  if (msg.document) {
    const fileId = msg.document.file_id;

    // Telegram file URL
    const fileInfo = await axios.get(`https://api.telegram.org/bot${process.env.BOT_TOKEN}/getFile?file_id=${fileId}`);
    const filePath = fileInfo.data.result.file_path;
    const fileUrl = `https://api.telegram.org/file/bot${process.env.BOT_TOKEN}/${filePath}`;

    // Download file as buffer
    const fileResp = await axios.get(fileUrl, { responseType: 'arraybuffer' });
    const buffer = Buffer.from(fileResp.data);

    // 3️⃣ Upload to Supabase Storage
    const fileName = msg.document.file_name;
    const uploadPath = `publishers/${publisher.id}/${fileName}`;
    const { error: uploadError } = await supabase.storage
      .from('publisher-files')
      .upload(uploadPath, buffer, {
        contentType: msg.document.mime_type,
        upsert: false,
      });

    const reply = uploadError
      ? `❌ Upload failed: ${uploadError.message}`
      : `✅ Uploaded successfully: ${fileName}`;

    await axios.post(`https://api.telegram.org/bot${process.env.BOT_TOKEN}/sendMessage`, {
      chat_id: msg.chat.id,
      text: reply,
    });
  }

  res.status(200).end();
}
